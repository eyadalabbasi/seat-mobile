import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/seat_theme.dart';

class SeatApp extends ConsumerStatefulWidget {
  const SeatApp({super.key});
  @override
  ConsumerState<SeatApp> createState() => _SeatAppState();
}

class _SeatAppState extends ConsumerState<SeatApp> {
  Locale _locale = const Locale('en');
  bool _ready = false;
  bool _languageSelected = false;
  GoRouter? _router;
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() {
          _locale = Locale(prefs.getString('locale') ?? 'en');
          _languageSelected = prefs.getBool('language_selected') ?? false;
          _router = createRouter(
            setLocale,
            () => _locale,
            () => _languageSelected,
          );
          _ready = true;
        });
      }
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
      _languageSelected = true;
    });
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setString('locale', locale.languageCode);
      await prefs.setBool('language_selected', true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _router == null) {
      return const ColoredBox(color: SeatColors.cream);
    }
    return MaterialApp.router(
      title: 'SEAT',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: seatTheme(_locale),
      routerConfig: _router!,
    );
  }
}
