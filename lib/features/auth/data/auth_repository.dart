import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

class AuthRepository {
  const AuthRepository(this._api, this._tokens);
  final ApiClient _api;
  final TokenStore _tokens;
  Future<String> requestOtp(String phone) async {
    final data = await _api.post(
      '/api/v1/auth/otp/request',
      data: {'phone': phone, 'purpose': 'LOGIN'},
    );
    return '${data['challengeId']}';
  }

  Future<void> verifyOtp(String challengeId, String code) async {
    final data = await _api.post(
      '/api/v1/auth/otp/verify',
      data: {'challengeId': challengeId, 'code': code},
    );
    await _tokens.save('${data['accessToken']}', '${data['refreshToken']}');
  }

  Future<bool> restore() async {
    if (await _tokens.refreshToken == null) return false;
    try {
      await _api.get('/api/v1/auth/me');
      return true;
    } on ApiFailure {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/api/v1/auth/logout');
    } finally {
      await _tokens.clear();
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
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
