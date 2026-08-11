import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';

/// Mutable presentation data used only by the explicitly enabled DEV preview.
class FixtureStore {
  FixtureStore() : reservations = List<Reservation>.from(seedReservations);

  bool authenticated = false;
  final List<Reservation> reservations;
  final Map<String, int> detailReads = <String, int>{};
  final Set<String> readNotificationIds = <String>{};

  static final restaurants = <Restaurant>[
    const Restaurant(
      id: 'restaurant-1',
      name: 'Saffron House',
      cuisine: 'Bahraini',
      area: 'Manama',
      description: 'A warm contemporary take on Bahraini family cooking.',
      isOpen: true,
    ),
    const Restaurant(
      id: 'restaurant-2',
      name: 'Pearl Courtyard',
      cuisine: 'Mediterranean',
      area: 'Adliya',
      description: 'Seasonal Mediterranean plates in a quiet garden setting.',
      isOpen: true,
    ),
    const Restaurant(
      id: 'restaurant-3',
      name: 'Dhow Kitchen',
      cuisine: 'Seafood',
      area: 'Muharraq',
      description:
          'Fresh Gulf seafood inspired by Bahrain’s maritime heritage.',
      isOpen: true,
    ),
    const Restaurant(
      id: 'restaurant-4',
      name: 'Terrace 973',
      cuisine: 'Modern Arabic',
      area: 'Seef',
      description:
          'Modern Arabic sharing plates with a relaxed terrace atmosphere.',
      isOpen: true,
    ),
    const Restaurant(
      id: 'restaurant-5',
      name: 'Olive & Ember',
      cuisine: 'Italian',
      area: 'Riffa',
      description: 'Wood-fired favourites, handmade pasta, and easy evenings.',
      isOpen: false,
    ),
  ];

  static final seedReservations = <Reservation>[
    _reservation('requested', ReservationStatus.requested, 1),
    _reservation('review', ReservationStatus.underReview, 2),
    _reservation(
      'alternative',
      ReservationStatus.alternativeProposed,
      3,
      alternative: true,
    ),
    _reservation('confirmed', ReservationStatus.confirmed, 4),
    _reservation('declined', ReservationStatus.declined, 5),
    _reservation('expired', ReservationStatus.expired, 6),
    _reservation('cancelled', ReservationStatus.cancelled, 7),
    _reservation('checked-in', ReservationStatus.checkedIn, 8),
    _reservation('completed', ReservationStatus.completed, 9),
    _reservation('no-show', ReservationStatus.noShow, 10),
  ];

  static Reservation _reservation(
    String id,
    ReservationStatus status,
    int day, {
    bool alternative = false,
  }) {
    final now = DateTime.now();
    final requested = DateTime(
      now.year,
      now.month,
      now.day + day,
      18 + day % 3,
      day.isEven ? 30 : 15,
    );
    return Reservation(
      id: id,
      status: status,
      restaurantName: restaurants[(day - 1) % restaurants.length].name,
      partySize: 2 + day % 4,
      requestedStartsAt: requested,
      startsAt:
          status == ReservationStatus.confirmed ||
              status == ReservationStatus.checkedIn ||
              status == ReservationStatus.completed ||
              status == ReservationStatus.noShow
          ? requested
          : null,
      requestExpiresAt: requested.subtract(const Duration(days: 1)),
      alternativeStartsAt: alternative
          ? requested.add(const Duration(minutes: 45))
          : null,
      specialRequests: day.isEven ? 'Window seat if available' : null,
    );
  }
}

final fixtureStoreProvider = Provider<FixtureStore>((ref) => FixtureStore());
