import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/fixtures/fixture_store.dart';
import '../../../core/models/models.dart';

abstract interface class NotificationRepository {
  Future<List<SeatNotification>> list();
  Future<int> unreadCount();
  Future<void> markRead(String id);
}

class ApiNotificationRepository implements NotificationRepository {
  const ApiNotificationRepository(this._api);
  final ApiClient _api;
  @override
  Future<List<SeatNotification>> list() async =>
      unwrapItems(
            await _api.get(
              '/api/v1/me/notifications',
              query: {'page': 1, 'limit': 20},
            ),
          )
          .map(
            (item) => SeatNotification.fromJson(
              Map<String, Object?>.from(item! as Map),
            ),
          )
          .toList();
  @override
  Future<int> unreadCount() async =>
      (await _api.get('/api/v1/me/notifications/unread-count'))['count']
          as int? ??
      0;
  @override
  Future<void> markRead(String id) async => _api.patch(
    '/api/v1/me/notifications/$id/read',
    data: <String, Object?>{},
  );
}

class FixtureNotificationRepository implements NotificationRepository {
  FixtureNotificationRepository(this._store);
  final FixtureStore _store;
  static final _items = <SeatNotification>[
    SeatNotification(
      id: 'request',
      title: 'Request received',
      body: 'Saffron House received your reservation request.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      isRead: false,
    ),
    SeatNotification(
      id: 'alternative',
      title: 'Another time is available',
      body: 'Pearl Courtyard suggested 8:45 PM.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    SeatNotification(
      id: 'confirmed',
      title: 'You’re confirmed',
      body: 'Your reservation at Terrace 973 is confirmed.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
    ),
    SeatNotification(
      id: 'reminder',
      title: 'Reservation reminder',
      body: 'Your table is tomorrow at 7:30 PM.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    SeatNotification(
      id: 'declined',
      title: 'Request update',
      body: 'The restaurant could not accept this time.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];
  @override
  Future<List<SeatNotification>> list() async => _items
      .map(
        (item) => SeatNotification(
          id: item.id,
          title: item.title,
          body: item.body,
          createdAt: item.createdAt,
          isRead: item.isRead || _store.readNotificationIds.contains(item.id),
        ),
      )
      .toList();
  @override
  Future<int> unreadCount() async =>
      (await list()).where((item) => !item.isRead).length;
  @override
  Future<void> markRead(String id) async => _store.readNotificationIds.add(id);
}

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => ref.watch(appConfigProvider).useFixtures
      ? FixtureNotificationRepository(ref.watch(fixtureStoreProvider))
      : ApiNotificationRepository(ref.watch(apiClientProvider)),
);
final notificationsProvider = FutureProvider<List<SeatNotification>>(
  (ref) => ref.watch(notificationRepositoryProvider).list(),
);
final unreadCountProvider = FutureProvider<int>(
  (ref) => ref.watch(notificationRepositoryProvider).unreadCount(),
);
