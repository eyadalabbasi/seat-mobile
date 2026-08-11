import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/seat_widgets.dart';
import '../../../core/formatting/seat_date_time.dart';
import '../../../app/theme/seat_theme.dart';
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
                  final copy = _notificationCopy(context, item.id);
                  return ColoredBox(
                    color: item.isRead
                        ? Colors.transparent
                        : SeatColors.terracotta.withValues(alpha: .055),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      minTileHeight: 88,
                      leading: CircleAvatar(
                        backgroundColor: item.isRead
                            ? SeatColors.secondaryBackground
                            : SeatColors.terracotta.withValues(alpha: .13),
                        child: Icon(
                          item.isRead
                              ? Icons.notifications_none
                              : Icons.notifications_active,
                          color: item.isRead
                              ? SeatColors.secondary
                              : SeatColors.terracotta,
                        ),
                      ),
                      title: Text(
                        copy?.$1 ?? item.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: item.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              copy?.$2 ?? item.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              SeatDateTime.relative(context, item.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
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
                    ),
                  );
                },
                separatorBuilder: (_, _) => const Divider(height: 1),
              ),
      ),
    );
  }
}

(String, String)? _notificationCopy(BuildContext context, String id) {
  if (Localizations.localeOf(context).languageCode != 'ar') return null;
  return switch (id) {
    'request' => ('تم استلام الطلب', 'استلم Saffron House طلب حجزك.'),
    'alternative' => ('يتوفر وقت آخر', 'اقترح Pearl Courtyard الساعة 8:45 م.'),
    'confirmed' => ('تم تأكيد حجزك', 'تم تأكيد حجزك في Terrace 973.'),
    'reminder' => ('تذكير بالحجز', 'موعد حجزك غداً الساعة 7:30 م.'),
    'declined' => ('تحديث الطلب', 'تعذّر على المطعم قبول هذا الوقت.'),
    _ => null,
  };
}
