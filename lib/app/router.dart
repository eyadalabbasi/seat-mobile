import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_screens.dart';
import '../features/discovery/presentation/discovery_screens.dart';
import '../features/notifications/data/notification_repository.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/profile/presentation/profile_screens.dart';
import '../features/reservations/presentation/reservation_screens.dart';
import '../l10n/app_localizations.dart';

GoRouter createRouter(ValueChanged<Locale> onLocale, Locale locale) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
    GoRoute(
      path: '/language',
      builder: (_, _) => LanguageScreen(onLocale: onLocale),
    ),
    GoRoute(path: '/login', builder: (_, _) => const PhoneLoginScreen()),
    GoRoute(
      path: '/otp',
      builder: (_, state) {
        final extra = state.extra! as Map<String, String>;
        return OtpScreen(
          challengeId: extra['challengeId']!,
          phone: extra['phone']!,
        );
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => CustomerShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reservations',
              builder: (_, _) => const ReservationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              builder: (_, _) => const NotificationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          ],
        ),
      ],
    ),
    GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
    GoRoute(
      path: '/restaurants/:id',
      builder: (_, s) => RestaurantDetailScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/restaurants/:id/request',
      builder: (_, s) => RequestReservationScreen(
        restaurantId: s.uri.queryParameters['branchId']!,
      ),
    ),
    GoRoute(
      path: '/reservations/:id',
      builder: (_, s) => ReservationDetailScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (_, _) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, _) => SettingsScreen(locale: locale, onLocale: onLocale),
    ),
  ],
);

class CustomerShell extends ConsumerWidget {
  const CustomerShell({super.key, required this.shell});
  final StatefulNavigationShell shell;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event),
            label: l.reservations,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: const Icon(Icons.notifications),
            label: l.notifications,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l.profile,
          ),
        ],
      ),
    );
  }
}
