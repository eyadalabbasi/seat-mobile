import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/models.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> get();
  Future<UserProfile> update({
    String? displayName,
    String? email,
    String? language,
  });
  Future<Map<String, Object?>> preferences();
  Future<void> updateReminders(bool value);
}

class ApiProfileRepository implements ProfileRepository {
  const ApiProfileRepository(this._api);
  final ApiClient _api;
  @override
  Future<UserProfile> get() =>
      _api.get('/api/v1/me/profile').then(UserProfile.fromJson);
  @override
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
  @override
  Future<Map<String, Object?>> preferences() =>
      _api.get('/api/v1/me/notification-preferences');
  @override
  Future<void> updateReminders(bool value) => _api.patch(
    '/api/v1/me/notification-preferences',
    data: {'eventType': 'RESERVATION_REMINDER', 'pushEnabled': value},
  );
}

class FixtureProfileRepository implements ProfileRepository {
  String _name = 'Noor Al Khalifa';
  String? _email = 'noor@example.test';
  String _language = 'en';
  bool _reminders = true;
  @override
  Future<UserProfile> get() async => UserProfile(
    id: 'fixture-customer',
    phone: '+97330000000',
    language: _language,
    displayName: _name,
    email: _email,
  );
  @override
  Future<UserProfile> update({
    String? displayName,
    String? email,
    String? language,
  }) async {
    _name = displayName ?? _name;
    _email = email ?? _email;
    _language = language ?? _language;
    return get();
  }

  @override
  Future<Map<String, Object?>> preferences() async => {
    'reservationReminders': _reminders,
    'marketingEnabled': false,
  };
  @override
  Future<void> updateReminders(bool value) async => _reminders = value;
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ref.watch(appConfigProvider).useFixtures
      ? FixtureProfileRepository()
      : ApiProfileRepository(ref.watch(apiClientProvider)),
);
final profileProvider = FutureProvider<UserProfile>(
  (ref) => ref.watch(profileRepositoryProvider).get(),
);
