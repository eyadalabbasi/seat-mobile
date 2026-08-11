import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/fixtures/fixture_store.dart';
import '../../../core/models/models.dart';

abstract interface class ReservationRepository {
  Future<Reservation> create({
    required String branchId,
    required DateTime date,
    required String time,
    required int partySize,
    String? note,
  });
  Future<List<Reservation>> list({int page = 1});
  Future<Reservation> detail(String id);
  Future<Reservation> cancel(String id);
  Future<Reservation> acceptAlternative(String id);
  Future<Reservation> declineAlternative(String id);
}

class ApiReservationRepository implements ReservationRepository {
  const ApiReservationRepository(this._api);
  final ApiClient _api;
  @override
  Future<Reservation> create({
    required String branchId,
    required DateTime date,
    required String time,
    required int partySize,
    String? note,
  }) async => Reservation.fromJson(
    await _api.post(
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
    ),
  );
  @override
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
  @override
  Future<Reservation> detail(String id) async =>
      Reservation.fromJson(await _api.get('/api/v1/reservations/$id'));
  @override
  Future<Reservation> cancel(String id) async => Reservation.fromJson(
    await _api.post(
      '/api/v1/reservations/$id/cancel',
      data: {'reason': 'CUSTOMER_REQUEST'},
    ),
  );
  @override
  Future<Reservation> acceptAlternative(String id) async =>
      Reservation.fromJson(
        await _api.post(
          '/api/v1/reservations/$id/accept-alternative',
          data: <String, Object?>{},
          idempotencyKey: const Uuid().v4(),
        ),
      );
  @override
  Future<Reservation> declineAlternative(String id) async =>
      Reservation.fromJson(
        await _api.post(
          '/api/v1/reservations/$id/decline-alternative',
          data: <String, Object?>{},
          idempotencyKey: const Uuid().v4(),
        ),
      );
}

class FixtureReservationRepository implements ReservationRepository {
  FixtureReservationRepository(this._store);
  final FixtureStore _store;
  @override
  Future<Reservation> create({
    required String branchId,
    required DateTime date,
    required String time,
    required int partySize,
    String? note,
  }) async {
    final parts = time.split(':');
    final requested = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final value = Reservation(
      id: 'preview-${DateTime.now().millisecondsSinceEpoch}',
      status: ReservationStatus.requested,
      restaurantName: 'Saffron House',
      partySize: partySize,
      requestedStartsAt: requested,
      requestExpiresAt: DateTime.now().add(const Duration(minutes: 10)),
      specialRequests: note,
    );
    _store.reservations.insert(0, value);
    return value;
  }

  @override
  Future<List<Reservation>> list({int page = 1}) async =>
      List.unmodifiable(_store.reservations);
  @override
  Future<Reservation> detail(String id) async {
    final index = _store.reservations.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw const ApiFailure('RESERVATION_NOT_FOUND', 'Reservation not found');
    }
    final value = _store.reservations[index];
    if (id.startsWith('preview-') &&
        value.status == ReservationStatus.requested) {
      final reads = (_store.detailReads[id] ?? 0) + 1;
      _store.detailReads[id] = reads;
      if (reads >= 3) {
        final confirmed = Reservation(
          id: value.id,
          status: ReservationStatus.confirmed,
          restaurantName: value.restaurantName,
          partySize: value.partySize,
          requestedStartsAt: value.requestedStartsAt,
          startsAt: value.requestedStartsAt,
          specialRequests: value.specialRequests,
        );
        _store.reservations[index] = confirmed;
        return confirmed;
      }
    }
    return value;
  }

  @override
  Future<Reservation> cancel(String id) async =>
      _replace(id, ReservationStatus.cancelled);
  @override
  Future<Reservation> acceptAlternative(String id) async =>
      _replace(id, ReservationStatus.confirmed, useAlternative: true);
  @override
  Future<Reservation> declineAlternative(String id) async =>
      _replace(id, ReservationStatus.cancelled);
  Reservation _replace(
    String id,
    ReservationStatus status, {
    bool useAlternative = false,
  }) {
    final index = _store.reservations.indexWhere((item) => item.id == id);
    final old = _store.reservations[index];
    final start = useAlternative ? old.alternativeStartsAt : old.startsAt;
    final value = Reservation(
      id: old.id,
      status: status,
      restaurantName: old.restaurantName,
      partySize: old.partySize,
      requestedStartsAt: old.requestedStartsAt,
      startsAt: status == ReservationStatus.confirmed
          ? (start ?? old.requestedStartsAt)
          : start,
      alternativeStartsAt: old.alternativeStartsAt,
      specialRequests: old.specialRequests,
    );
    _store.reservations[index] = value;
    return value;
  }
}

final reservationRepositoryProvider = Provider<ReservationRepository>(
  (ref) => ref.watch(appConfigProvider).useFixtures
      ? FixtureReservationRepository(ref.watch(fixtureStoreProvider))
      : ApiReservationRepository(ref.watch(apiClientProvider)),
);
final reservationsProvider = FutureProvider<List<Reservation>>(
  (ref) => ref.watch(reservationRepositoryProvider).list(),
);
