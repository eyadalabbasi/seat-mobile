import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() => _locale = Locale(prefs.getString('locale') ?? 'en'));
      }
    });
  }

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString('locale', locale.languageCode),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
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
    routerConfig: createRouter(setLocale, _locale),
  );
}
