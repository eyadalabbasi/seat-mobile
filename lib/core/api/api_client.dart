import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';

class ApiFailure implements Exception {
  const ApiFailure(this.code, this.message, {this.statusCode});
  final String code;
  final String message;
  final int? statusCode;
  bool get isOffline => code == 'NETWORK_UNAVAILABLE';
}

class TokenStore {
  TokenStore(this._storage);
  final FlutterSecureStorage _storage;
  static const _access = 'seat.access_token';
  static const _refresh = 'seat.refresh_token';
  Future<String?> get accessToken => _storage.read(key: _access);
  Future<String?> get refreshToken => _storage.read(key: _refresh);
  Future<void> save(String access, String refresh) async {
    await _storage.write(key: _access, value: access);
    await _storage.write(key: _refresh, value: refresh);
  }

  Future<void> clear() async {
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
  }
}

class ApiClient {
  ApiClient(this._dio, this._tokens) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokens.accessToken;
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              error.requestOptions.extra['retried'] != true) {
            try {
              await _refresh();
              final request = error.requestOptions..extra['retried'] = true;
              request.headers['Authorization'] =
                  'Bearer ${await _tokens.accessToken}';
              return handler.resolve(await _dio.fetch<Object?>(request));
            } catch (_) {}
          }
          handler.next(error);
        },
      ),
    );
  }
  final Dio _dio;
  final TokenStore _tokens;
  Future<void>? _refreshing;

  Future<void> _refresh() async {
    if (_refreshing != null) return _refreshing;
    final completer = Completer<void>();
    _refreshing = completer.future;
    try {
      final token = await _tokens.refreshToken;
      if (token == null) {
        throw const ApiFailure('SESSION_EXPIRED', 'Session expired');
      }
      final response = await _dio.post<Map<String, Object?>>(
        '/api/v1/auth/refresh',
        data: {'refreshToken': token},
        options: Options(extra: {'retried': true}),
      );
      final data = _unwrapMap(response.data);
      await _tokens.save('${data['accessToken']}', '${data['refreshToken']}');
      completer.complete();
    } catch (error, stack) {
      await _tokens.clear();
      completer.completeError(error, stack);
      rethrow;
    } finally {
      _refreshing = null;
    }
  }

  Future<Map<String, Object?>> get(
    String path, {
    Map<String, Object?>? query,
  }) async => _request(
    () => _dio.get<Map<String, Object?>>(path, queryParameters: query),
  );
  Future<Map<String, Object?>> post(
    String path, {
    Object? data,
    String? idempotencyKey,
  }) async => _request(
    () => _dio.post<Map<String, Object?>>(
      path,
      data: data,
      options: Options(headers: {'Idempotency-Key': ?idempotencyKey}),
    ),
  );
  Future<Map<String, Object?>> patch(String path, {Object? data}) async =>
      _request(() => _dio.patch<Map<String, Object?>>(path, data: data));
  Future<void> delete(String path) async =>
      _request(() => _dio.delete<Map<String, Object?>>(path));

  Future<Map<String, Object?>> _request(
    Future<Response<Map<String, Object?>>> Function() request,
  ) async {
    try {
      return _unwrapMap((await request()).data);
    } on DioException catch (error) {
      final body = error.response?.data;
      final errorBody = body?['error'];
      final details = errorBody is Map ? errorBody : body;
      final code = details is Map
          ? '${details['code'] ?? 'SERVER_UNAVAILABLE'}'
          : 'NETWORK_UNAVAILABLE';
      final message = details is Map
          ? '${details['message'] ?? 'Request failed'}'
          : 'Network unavailable';
      throw ApiFailure(code, message, statusCode: error.response?.statusCode);
    }
  }
}

Map<String, Object?> _unwrapMap(Map<String, Object?>? body) {
  final value = body?['data'] ?? body ?? <String, Object?>{};
  return value is Map<String, Object?>
      ? value
      : Map<String, Object?>.from(value as Map);
}

List<Object?> unwrapItems(Map<String, Object?> body) {
  final value = body['items'] ?? body['data'];
  return value is List ? value : const [];
}

final tokenStoreProvider = Provider<TokenStore>(
  (ref) => TokenStore(const FlutterSecureStorage()),
);
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(
    Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl.toString(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    ),
    ref.watch(tokenStoreProvider),
  );
});
