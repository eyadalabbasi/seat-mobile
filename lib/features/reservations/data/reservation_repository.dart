import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/models.dart';

class ReservationRepository {
  const ReservationRepository(this._api);
  final ApiClient _api;
  Future<Reservation> create({
    required String branchId,
    required DateTime date,
    required String time,
    required int partySize,
    String? note,
  }) async {
    final body = await _api.post(
      '/api/v1/reservations',
      data: {
        'branchId': branchId,
        'date': date.toIso8601String().substring(0, 10),
        'time': time,
        'partySize': partySize,
        'preferences': <Object?>[],
        'specialRequests': note,
      },
      idempotencyKey: const Uuid().v4(),
    );
    return Reservation.fromJson(body);
  }

  Future<List<Reservation>> list({int page = 1}) async =>
      unwrapItems(
            await _api.get(
              '/api/v1/me/reservations',
              query: {'page': page, 'limit': 20},
            ),
          )
          .map(
            (item) =>
                Reservation.fromJson(Map<String, Object?>.from(item! as Map)),
          )
          .toList();
  Future<Reservation> detail(String id) async =>
      Reservation.fromJson(await _api.get('/api/v1/reservations/$id'));
  Future<Reservation> cancel(String id) async => Reservation.fromJson(
    await _api.post(
      '/api/v1/reservations/$id/cancel',
      data: {'reason': 'CUSTOMER_REQUEST'},
    ),
  );
  Future<Reservation> acceptAlternative(String id) async =>
      Reservation.fromJson(
        await _api.post(
          '/api/v1/reservations/$id/accept-alternative',
          data: <String, Object?>{},
          idempotencyKey: const Uuid().v4(),
        ),
      );
  Future<Reservation> declineAlternative(String id) async =>
      Reservation.fromJson(
        await _api.post(
          '/api/v1/reservations/$id/decline-alternative',
          data: <String, Object?>{},
          idempotencyKey: const Uuid().v4(),
        ),
      );
}

final reservationRepositoryProvider = Provider<ReservationRepository>(
  (ref) => ReservationRepository(ref.watch(apiClientProvider)),
);
final reservationsProvider = FutureProvider<List<Reservation>>(
  (ref) => ref.watch(reservationRepositoryProvider).list(),
);
