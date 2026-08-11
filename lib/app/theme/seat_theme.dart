import 'package:flutter/material.dart';

abstract final class SeatColors {
  static const cream = Color(0xFFF8F3EA);
  static const surface = Color(0xFFFFFCF7);
  static const charcoal = Color(0xFF24211F);
  static const secondary = Color(0xFF746E67);
  static const terracotta = Color(0xFFB65F45);
  static const green = Color(0xFF4F735D);
  static const warning = Color(0xFFA56B26);
  static const destructive = Color(0xFFB4473D);
  static const divider = Color(0xFFE4DDD2);
}

ThemeData seatTheme(Locale locale) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: SeatColors.cream,
    colorScheme: const ColorScheme.light(
      primary: SeatColors.terracotta,
      onPrimary: Colors.white,
      surface: SeatColors.surface,
      onSurface: SeatColors.charcoal,
      error: SeatColors.destructive,
    ),
    fontFamily: locale.languageCode == 'ar' ? 'Noto Sans Arabic' : 'Inter',
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displaySmall: const TextStyle(
        fontSize: 40,
        height: 1.1,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: const TextStyle(
        fontSize: 30,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: const TextStyle(
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: const TextStyle(fontSize: 17, height: 1.5),
      bodyMedium: const TextStyle(fontSize: 15, height: 1.45),
      labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: SeatColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: SeatColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: SeatColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: SeatColors.divider),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
