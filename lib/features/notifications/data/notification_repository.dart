import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/models.dart';

class NotificationRepository {
  const NotificationRepository(this._api);
  final ApiClient _api;
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
  Future<int> unreadCount() async =>
      (await _api.get('/api/v1/me/notifications/unread-count'))['count']
          as int? ??
      0;
  Future<void> markRead(String id) async => _api.patch(
    '/api/v1/me/notifications/$id/read',
    data: <String, Object?>{},
  );
}

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(apiClientProvider)),
);
final notificationsProvider = FutureProvider<List<SeatNotification>>(
  (ref) => ref.watch(notificationRepositoryProvider).list(),
);
final unreadCountProvider = FutureProvider<int>(
  (ref) => ref.watch(notificationRepositoryProvider).unreadCount(),
);
