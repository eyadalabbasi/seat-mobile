import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/seat_theme.dart';
import '../../l10n/app_localizations.dart';
import '../api/api_client.dart';
import '../models/models.dart';

class SeatPage extends StatelessWidget {
  const SeatPage({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });
  final String title;
  final Widget child;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: action == null ? null : [action!],
    ),
    body: SafeArea(child: child),
  );
}

class SeatAsyncError extends StatelessWidget {
  const SeatAsyncError({super.key, required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = error is ApiFailure && (error as ApiFailure).isOffline
        ? l.offline
        : l.serverError;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l.retry)),
          ],
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });
  final Restaurant restaurant;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${restaurant.name}, ${restaurant.cuisine}, ${restaurant.area}',
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 190,
              width: double.infinity,
              child: restaurant.imageUrl == null
                  ? const _RestaurantPlaceholder()
                  : CachedNetworkImage(
                      imageUrl: restaurant.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: Color(0xFFE9DDD0)),
                      errorWidget: (_, _, _) => const _RestaurantPlaceholder(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: SeatColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${restaurant.cuisine} · ${restaurant.area}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SeatColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        restaurant.isOpen
                            ? Icons.check_circle_outline
                            : Icons.schedule_outlined,
                        size: 17,
                        color: restaurant.isOpen
                            ? SeatColors.green
                            : SeatColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        restaurant.isOpen
                            ? (Localizations.localeOf(context).languageCode ==
                                      'ar'
                                  ? 'يستقبل طلبات الحجز'
                                  : 'Accepting requests')
                            : (Localizations.localeOf(context).languageCode ==
                                      'ar'
                                  ? 'مغلق حالياً'
                                  : 'Currently closed'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: restaurant.isOpen
                              ? SeatColors.green
                              : SeatColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RestaurantPlaceholder extends StatelessWidget {
  const _RestaurantPlaceholder();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFDAC4AF), Color(0xFF8C5F4F)],
      ),
    ),
    child: Stack(
      children: [
        PositionedDirectional(
          start: 22,
          bottom: 20,
          child: Text(
            'SEAT',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    ),
  );
}

String statusLabel(AppLocalizations l, ReservationStatus status) =>
    switch (status) {
      ReservationStatus.requested => l.statusRequested,
      ReservationStatus.underReview => l.statusUnderReview,
      ReservationStatus.alternativeProposed => l.statusAlternative,
      ReservationStatus.confirmed => l.statusConfirmed,
      ReservationStatus.checkedIn => l.statusCheckedIn,
      ReservationStatus.completed => l.statusCompleted,
      ReservationStatus.declined => l.statusDeclined,
      ReservationStatus.cancelled => l.statusCancelled,
      ReservationStatus.expired => l.statusExpired,
      ReservationStatus.noShow => l.statusNoShow,
    };

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final ReservationStatus status;
  @override
  Widget build(BuildContext context) {
    final label = statusLabel(AppLocalizations.of(context), status);
    final color = switch (status) {
      ReservationStatus.confirmed ||
      ReservationStatus.checkedIn ||
      ReservationStatus.completed => SeatColors.green,
      ReservationStatus.declined ||
      ReservationStatus.cancelled ||
      ReservationStatus.noShow => SeatColors.destructive,
      ReservationStatus.expired => SeatColors.secondary,
      _ => SeatColors.warning,
    };
    return Semantics(
      label: label,
      child: Chip(
        backgroundColor: color.withValues(alpha: .11),
        side: BorderSide.none,
        label: Text(label, style: TextStyle(color: color)),
        avatar: Icon(
          status == ReservationStatus.confirmed
              ? Icons.check_circle
              : Icons.schedule,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}
