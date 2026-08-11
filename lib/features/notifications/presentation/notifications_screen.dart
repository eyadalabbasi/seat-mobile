import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/seat_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../data/notification_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(notificationsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(notificationsProvider.future),
      child: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SeatAsyncError(
          error: e,
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (items) => items.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * .3),
                  const Icon(Icons.notifications_none, size: 48),
                  Center(child: Text(l.noNotifications)),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  return ListTile(
                    minTileHeight: 72,
                    leading: Icon(
                      item.isRead
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: item.isRead
                          ? null
                          : Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(item.title),
                    subtitle: Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: item.isRead
                        ? null
                        : () async {
                            await ref
                                .read(notificationRepositoryProvider)
                                .markRead(item.id);
                            ref.invalidate(notificationsProvider);
                            ref.invalidate(unreadCountProvider);
                          },
                  );
                },
                separatorBuilder: (_, _) => const Divider(height: 1),
              ),
      ),
    );
  }
}
