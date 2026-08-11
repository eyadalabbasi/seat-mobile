import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final reservationRepository = File(
    'lib/features/reservations/data/reservation_repository.dart',
  ).readAsStringSync();
  final reservationScreens = File(
    'lib/features/reservations/presentation/reservation_screens.dart',
  ).readAsStringSync();
  final router = File('lib/app/router.dart').readAsStringSync();
  final customerModel = File('lib/core/models/models.dart').readAsStringSync();

  group('mobile API contract guards', () {
    final requiredPaths = <String>[
      '/api/v1/reservations',
      '/api/v1/me/reservations',
      '/api/v1/reservations/\$id',
      '/accept-alternative',
      '/decline-alternative',
      '/cancel',
    ];
    for (final path in requiredPaths) {
      test(
        'reservation repository includes $path',
        () => expect(reservationRepository, contains(path)),
      );
    }
    test(
      'creation sends no customer user id',
      () => expect(reservationRepository, isNot(contains("'userId'"))),
    );
    test(
      'creation sends no table id',
      () => expect(reservationRepository, isNot(contains("'tableId'"))),
    );
    test(
      'customer model has no allocation model',
      () => expect(customerModel, isNot(contains('allocationIds'))),
    );
    test(
      'waiting polling interval is 15 seconds',
      () => expect(reservationScreens, contains('Duration(seconds: 15)')),
    );
    test(
      'polling observes app lifecycle',
      () => expect(reservationScreens, contains('WidgetsBindingObserver')),
    );
    test(
      'shell has exactly four customer destinations',
      () => expect(
        RegExp(r'NavigationDestination\(').allMatches(router).length,
        4,
      ),
    );
    test(
      'customer shell has no staff navigation',
      () => expect(router, isNot(contains('Inbox'))),
    );
  });

  group('localization contract guards', () {
    final en =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
            as Map<String, Object?>;
    final ar =
        jsonDecode(File('lib/l10n/app_ar.arb').readAsStringSync())
            as Map<String, Object?>;
    test(
      'English and Arabic expose the same keys',
      () => expect(en.keys.toSet(), ar.keys.toSet()),
    );
    test(
      'Arabic waiting copy does not claim confirmation',
      () => expect(ar['waitingRestaurant'], 'بانتظار رد المطعم'),
    );
    test(
      'English uses request terminology',
      () => expect(en['requestReservation'], 'Request Reservation'),
    );
    test(
      'pre-confirm cancellation says Cancel Request',
      () => expect(en['cancelRequest'], 'Cancel Request'),
    );
    test(
      'post-confirm cancellation says Cancel Reservation',
      () => expect(en['cancelReservation'], 'Cancel Reservation'),
    );
  });
}
