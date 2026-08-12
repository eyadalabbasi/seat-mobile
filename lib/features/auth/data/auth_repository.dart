import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/fixtures/fixture_store.dart';

abstract interface class AuthRepository {
  Future<String> requestOtp(String phone);
  Future<void> verifyOtp(String challengeId, String code);
  Future<bool> restore();
  Future<void> logout();
}

class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository(this._api, this._tokens);
  final ApiClient _api;
  final TokenStore _tokens;
  @override
  Future<String> requestOtp(String phone) async =>
      '${(await _api.post('/api/v1/auth/otp/request', data: {'phone': phone, 'purpose': 'LOGIN'}))['challengeId']}';
  @override
  Future<void> verifyOtp(String challengeId, String code) async {
    final data = await _api.post(
      '/api/v1/auth/otp/verify',
      data: {'challengeId': challengeId, 'code': code},
    );
    final tokens = Map<String, Object?>.from(data['tokens'] as Map);
    await _tokens.save('${tokens['accessToken']}', '${tokens['refreshToken']}');
  }

  @override
  Future<bool> restore() async {
    if (await _tokens.refreshToken == null) return false;
    try {
      await _api.get('/api/v1/auth/me');
      return true;
    } on ApiFailure {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _api.post('/api/v1/auth/logout');
    } finally {
      await _tokens.clear();
    }
  }
}

class FixtureAuthRepository implements AuthRepository {
  FixtureAuthRepository(this._store);
  final FixtureStore _store;
  static const previewPhone = '+97330000000';
  static const previewOtp = '123456';
  @override
  Future<String> requestOtp(String phone) async {
    if (phone != previewPhone) {
      throw const ApiFailure(
        'INVALID_PHONE',
        'Use the development preview phone.',
      );
    }
    return 'development-preview-challenge';
  }

  @override
  Future<void> verifyOtp(String challengeId, String code) async {
    if (challengeId != 'development-preview-challenge' || code != previewOtp) {
      throw const ApiFailure(
        'INVALID_OTP',
        'Invalid development preview code.',
      );
    }
    _store.authenticated = true;
  }

  @override
  Future<bool> restore() async => _store.authenticated;
  @override
  Future<void> logout() async => _store.authenticated = false;
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ref.watch(appConfigProvider).useFixtures
      ? FixtureAuthRepository(ref.watch(fixtureStoreProvider))
      : ApiAuthRepository(
          ref.watch(apiClientProvider),
          ref.watch(tokenStoreProvider),
        ),
);

class SessionController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(authRepositoryProvider).restore();
  Future<void> signedIn() async => state = const AsyncData(true);
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(false);
  }
}

final sessionProvider = AsyncNotifierProvider<SessionController, bool>(
  SessionController.new,
);
