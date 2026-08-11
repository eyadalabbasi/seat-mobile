import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/seat_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(profileProvider);
    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => SeatAsyncError(
        error: e,
        onRetry: () => ref.invalidate(profileProvider),
      ),
      data: (user) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 38,
            child: Text(
              (user.displayName?.isNotEmpty == true ? user.displayName! : 'S')
                  .substring(0, 1)
                  .toUpperCase(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName ?? user.phone,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(user.phone, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 28),
          ListTile(
            minTileHeight: 56,
            leading: const Icon(Icons.edit_outlined),
            title: Text(l.editProfile),
            onTap: () => context.push('/profile/edit'),
          ),
          ListTile(
            minTileHeight: 56,
            leading: const Icon(Icons.settings_outlined),
            title: Text(l.settings),
            onTap: () => context.push('/settings'),
          ),
          const Divider(),
          ListTile(
            minTileHeight: 56,
            leading: const Icon(Icons.logout),
            title: Text(l.logout),
            textColor: Theme.of(context).colorScheme.error,
            iconColor: Theme.of(context).colorScheme.error,
            onTap: () async {
              await ref.read(sessionProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditState();
}

class _EditState extends ConsumerState<EditProfileScreen> {
  final name = TextEditingController(), email = TextEditingController();
  bool initialized = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(profileProvider);
    return SeatPage(
      title: l.editProfile,
      child: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SeatAsyncError(
          error: e,
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (user) {
          if (!initialized) {
            name.text = user.displayName ?? '';
            email.text = user.email ?? '';
            initialized = true;
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l.displayName),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l.email),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(profileRepositoryProvider)
                      .update(
                        displayName: name.text,
                        email: email.text.isEmpty ? null : email.text,
                      );
                  ref.invalidate(profileProvider);
                  if (context.mounted) context.pop();
                },
                child: Text(l.save),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    required this.locale,
    required this.onLocale,
  });
  final Locale locale;
  final ValueChanged<Locale> onLocale;
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<SettingsScreen> {
  bool reminders = true;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SeatPage(
      title: l.settings,
      child: ListView(
        children: [
          ListTile(
            minTileHeight: 64,
            leading: const Icon(Icons.language),
            title: Text(l.language),
            subtitle: Text(
              widget.locale.languageCode == 'ar' ? l.arabic : l.english,
            ),
            onTap: () {
              final next = Locale(
                widget.locale.languageCode == 'ar' ? 'en' : 'ar',
              );
              widget.onLocale(next);
              ref
                  .read(profileRepositoryProvider)
                  .update(language: next.languageCode);
            },
          ),
          SwitchListTile(
            value: reminders,
            onChanged: (value) {
              setState(() => reminders = value);
              ref.read(profileRepositoryProvider).updateReminders(value);
            },
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l.notificationPreferences),
          ),
          const Divider(),
          ListTile(
            title: Text(l.logout),
            leading: const Icon(Icons.logout),
            onTap: () async {
              await ref.read(sessionProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
