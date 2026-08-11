import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/seat_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../data/reservation_repository.dart';

class RequestReservationScreen extends ConsumerStatefulWidget {
  const RequestReservationScreen({super.key, required this.restaurantId});
  final String restaurantId;
  @override
  ConsumerState<RequestReservationScreen> createState() => _RequestState();
}

class _RequestState extends ConsumerState<RequestReservationScreen> {
  DateTime? date;
  TimeOfDay? time;
  int party = 2;
  final note = TextEditingController();
  bool loading = false;
  String? error;
  Future<void> submit() async {
    if (date == null || time == null) return;
    setState(() => loading = true);
    try {
      final value = await ref
          .read(reservationRepositoryProvider)
          .create(
            branchId: widget.restaurantId,
            date: date!,
            time:
                '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}',
            partySize: party,
            note: note.text.trim().isEmpty ? null : note.text.trim(),
          );
      if (mounted) context.go('/reservations/${value.id}');
    } on ApiFailure catch (e) {
      setState(
        () => error = e.code == 'RESERVATION_NOT_AVAILABLE'
            ? AppLocalizations.of(context).timeUnavailable
            : AppLocalizations.of(context).submissionFailed,
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.requestTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            minTileHeight: 60,
            title: Text(l.date),
            subtitle: Text(
              date == null
                  ? '—'
                  : MaterialLocalizations.of(context).formatFullDate(date!),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final value = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (value != null) setState(() => date = value);
            },
          ),
          ListTile(
            minTileHeight: 60,
            title: Text(l.preferredTime),
            subtitle: Text(time?.format(context) ?? '—'),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final value = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (value != null) setState(() => time = value);
            },
          ),
          ListTile(
            minTileHeight: 60,
            title: Text(l.partySize),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: party > 1 ? () => setState(() => party--) : null,
                  icon: const Icon(Icons.remove),
                  tooltip: 'Decrease',
                ),
                Semantics(
                  liveRegion: true,
                  label: '$party',
                  child: Text(
                    '$party',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => party++),
                  icon: const Icon(Icons.add),
                  tooltip: 'Increase',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: note,
            maxLength: 2000,
            maxLines: 3,
            decoration: InputDecoration(labelText: l.specialRequest),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: loading || date == null || time == null ? null : submit,
          child: loading
              ? const CircularProgressIndicator()
              : Text(l.requestReservation),
        ),
      ),
    );
  }
}

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(reservationsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(reservationsProvider.future),
      child: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SeatAsyncError(
          error: e,
          onRetry: () => ref.invalidate(reservationsProvider),
        ),
        data: (items) => items.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * .25),
                  Icon(
                    Icons.event_available,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Center(child: Text(l.noReservations)),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(l.findRestaurants),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (_, i) => ReservationCard(
                  reservation: items[i],
                  onTap: () => context.push('/reservations/${items[i].id}'),
                ),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
              ),
      ),
    );
  }
}

class ReservationCard extends StatelessWidget {
  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
  });
  final Reservation reservation;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation.restaurantName.isEmpty
                        ? 'SEAT'
                        : reservation.restaurantName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${reservation.requestedStartsAt.toLocal()} · ${reservation.partySize}',
                    ),
                  ),
                ],
              ),
            ),
            StatusChip(status: reservation.status),
          ],
        ),
      ),
    ),
  );
}

class ReservationDetailScreen extends ConsumerStatefulWidget {
  const ReservationDetailScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<ReservationDetailScreen> createState() => _DetailState();
}

class _DetailState extends ConsumerState<ReservationDetailScreen>
    with WidgetsBindingObserver {
  Reservation? value;
  Object? error;
  Timer? timer;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      load();
    } else {
      timer?.cancel();
    }
  }

  Future<void> load() async {
    try {
      final next = await ref
          .read(reservationRepositoryProvider)
          .detail(widget.id);
      if (!mounted) return;
      setState(() {
        value = next;
        error = null;
      });
      timer?.cancel();
      if (next.isPolling) timer = Timer(const Duration(seconds: 15), load);
    } catch (e) {
      if (mounted) setState(() => error = e);
    }
  }

  Future<void> command(Future<Reservation> Function() action) async {
    setState(() => busy = true);
    try {
      value = await action();
      if (mounted) setState(() {});
    } on ApiFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.code == 'ALTERNATIVE_NOT_AVAILABLE'
                  ? AppLocalizations.of(context).timeUnavailable
                  : e.message,
            ),
          ),
        );
      }
      await load();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (error != null) {
      return SeatPage(
        title: l.reservationDetails,
        child: SeatAsyncError(error: error!, onRetry: load),
      );
    }
    if (value == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final r = value!;
    return Scaffold(
      appBar: AppBar(title: Text(l.reservationDetails)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: StatusChip(status: r.status)),
          const SizedBox(height: 24),
          Text(
            _title(l, r.status),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          if (r.status == ReservationStatus.requested ||
              r.status == ReservationStatus.underReview)
            Text(l.notConfirmedYet, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.restaurantName.isEmpty ? 'SEAT' : r.restaurantName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('${r.requestedStartsAt.toLocal()}'),
                  ),
                  Text('${l.partySize}: ${r.partySize}'),
                  if (r.alternativeStartsAt != null) ...[
                    const Divider(height: 32),
                    Text(l.requestedTime),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('${r.requestedStartsAt.toLocal()}'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.suggestedTime,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('${r.alternativeStartsAt!.toLocal()}'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (r.status == ReservationStatus.alternativeProposed) ...[
            FilledButton(
              onPressed: busy
                  ? null
                  : () => command(
                      () => ref
                          .read(reservationRepositoryProvider)
                          .acceptAlternative(r.id),
                    ),
              child: Text(l.accept),
            ),
            TextButton(
              onPressed: busy
                  ? null
                  : () => command(
                      () => ref
                          .read(reservationRepositoryProvider)
                          .declineAlternative(r.id),
                    ),
              child: Text(l.decline),
            ),
          ],
          if (r.status == ReservationStatus.requested ||
              r.status == ReservationStatus.underReview ||
              r.status == ReservationStatus.confirmed)
            OutlinedButton(
              onPressed: busy
                  ? null
                  : () => command(
                      () =>
                          ref.read(reservationRepositoryProvider).cancel(r.id),
                    ),
              child: Text(
                r.status == ReservationStatus.confirmed
                    ? l.cancelReservation
                    : l.cancelRequest,
              ),
            ),
        ],
      ),
    );
  }

  String _title(AppLocalizations l, ReservationStatus s) => switch (s) {
    ReservationStatus.requested ||
    ReservationStatus.underReview => l.waitingRestaurant,
    ReservationStatus.alternativeProposed => l.alternativeTitle,
    ReservationStatus.confirmed => l.confirmedTitle,
    ReservationStatus.declined => l.declinedTitle,
    ReservationStatus.expired => l.expiredTitle,
    _ => statusLabel(l, s),
  };
}
