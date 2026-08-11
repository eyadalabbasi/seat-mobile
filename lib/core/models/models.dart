enum ReservationStatus {
  requested,
  underReview,
  alternativeProposed,
  confirmed,
  checkedIn,
  completed,
  declined,
  cancelled,
  expired,
  noShow,
}

ReservationStatus reservationStatusFromJson(String value) =>
    ReservationStatus.values.firstWhere(
      (item) =>
          item.name
              .replaceAllMapped(
                RegExp(r'[A-Z]'),
                (m) => '_${m[0]!.toLowerCase()}',
              )
              .toUpperCase() ==
          value,
      orElse: () => ReservationStatus.requested,
    );

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.area,
    this.description = '',
    this.imageUrl,
    this.isOpen = true,
  });
  final String id;
  final String name;
  final String cuisine;
  final String area;
  final String description;
  final String? imageUrl;
  final bool isOpen;
  factory Restaurant.fromJson(Map<String, Object?> json) => Restaurant(
    id: '${json['id']}',
    name: '${json['name'] ?? json['nameEn'] ?? ''}',
    cuisine: '${json['cuisine'] ?? ''}',
    area: '${json['area'] ?? json['city'] ?? ''}',
    description: '${json['description'] ?? ''}',
    imageUrl: json['coverImageUrl'] as String?,
    isOpen: json['isOpen'] as bool? ?? true,
  );
}

class Reservation {
  const Reservation({
    required this.id,
    required this.status,
    required this.restaurantName,
    required this.partySize,
    required this.requestedStartsAt,
    this.startsAt,
    this.requestExpiresAt,
    this.alternativeStartsAt,
    this.specialRequests,
  });
  final String id;
  final ReservationStatus status;
  final String restaurantName;
  final int partySize;
  final DateTime requestedStartsAt;
  final DateTime? startsAt;
  final DateTime? requestExpiresAt;
  final DateTime? alternativeStartsAt;
  final String? specialRequests;
  factory Reservation.fromJson(Map<String, Object?> json) => Reservation(
    id: '${json['id'] ?? json['reservationId']}',
    status: reservationStatusFromJson('${json['status']}'),
    restaurantName: '${json['restaurantName'] ?? ''}',
    partySize: (json['partySize'] as num?)?.toInt() ?? 2,
    requestedStartsAt: DateTime.parse(
      '${json['requestedStartsAt'] ?? json['startsAt']}',
    ),
    startsAt: DateTime.tryParse('${json['startsAt'] ?? ''}'),
    requestExpiresAt: DateTime.tryParse('${json['requestExpiresAt'] ?? ''}'),
    alternativeStartsAt: DateTime.tryParse(
      '${json['alternativeStartsAt'] ?? ''}',
    ),
    specialRequests: json['specialRequests'] as String?,
  );
  bool get isPolling =>
      status == ReservationStatus.requested ||
      status == ReservationStatus.underReview ||
      status == ReservationStatus.alternativeProposed;
}

class SeatNotification {
  const SeatNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  factory SeatNotification.fromJson(Map<String, Object?> json) =>
      SeatNotification(
        id: '${json['id']}',
        title: '${json['title'] ?? ''}',
        body: '${json['body'] ?? ''}',
        createdAt: DateTime.parse('${json['createdAt']}'),
        isRead: json['readAt'] != null || json['isRead'] == true,
      );
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.phone,
    required this.language,
    this.displayName,
    this.email,
  });
  final String id;
  final String phone;
  final String language;
  final String? displayName;
  final String? email;
  factory UserProfile.fromJson(Map<String, Object?> json) => UserProfile(
    id: '${json['id']}',
    phone: '${json['phoneE164'] ?? ''}',
    language: '${json['preferredLanguage'] ?? 'en'}',
    displayName: json['displayName'] as String?,
    email: json['email'] as String?,
  );
}
