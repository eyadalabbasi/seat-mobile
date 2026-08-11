import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/models.dart';

class ProfileRepository {
  const ProfileRepository(this._api);
  final ApiClient _api;
  Future<UserProfile> get() =>
      _api.get('/api/v1/me/profile').then(UserProfile.fromJson);
  Future<UserProfile> update({
    String? displayName,
    String? email,
    String? language,
  }) => _api
      .patch(
        '/api/v1/me/profile',
        data: {
          'displayName': ?displayName,
          'email': ?email,
          'preferredLanguage': ?language,
        },
      )
      .then(UserProfile.fromJson);
  Future<Map<String, Object?>> preferences() =>
      _api.get('/api/v1/me/notification-preferences');
  Future<void> updateReminders(bool value) => _api.patch(
    '/api/v1/me/notification-preferences',
    data: {'eventType': 'RESERVATION_REMINDER', 'pushEnabled': value},
  );
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(apiClientProvider)),
);
final profileProvider = FutureProvider<UserProfile>(
  (ref) => ref.watch(profileRepositoryProvider).get(),
);
