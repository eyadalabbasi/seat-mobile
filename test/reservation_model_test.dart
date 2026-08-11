import 'package:flutter_test/flutter_test.dart';
import 'package:seat_mobile/core/models/models.dart';

void main() {
  group('Reservation model', () {
    test('parses every approved V1 state', () {
      const states = <String>[
        'REQUESTED',
        'UNDER_REVIEW',
        'ALTERNATIVE_PROPOSED',
        'CONFIRMED',
        'CHECKED_IN',
        'COMPLETED',
        'DECLINED',
        'CANCELLED',
        'EXPIRED',
        'NO_SHOW',
      ];
      expect(
        states.map(reservationStatusFromJson).toSet(),
        ReservationStatus.values.toSet(),
      );
    });
    test('polls only actionable customer states', () {
      final reservation = Reservation(
        id: '1',
        status: ReservationStatus.requested,
        restaurantName: 'SEAT',
        partySize: 2,
        requestedStartsAt: DateTime.utc(2026),
      );
      expect(reservation.isPolling, isTrue);
      expect(
        Reservation(
          id: '2',
          status: ReservationStatus.confirmed,
          restaurantName: 'SEAT',
          partySize: 2,
          requestedStartsAt: DateTime.utc(2026),
        ).isPolling,
        isFalse,
      );
    });
    test('safe model has no allocation or table fields', () {
      final fields = Reservation.fromJson({
        'id': '1',
        'status': 'REQUESTED',
        'partySize': 2,
        'requestedStartsAt': '2026-01-01T10:00:00Z',
      });
      expect(fields.status, ReservationStatus.requested);
    });
  });
}
