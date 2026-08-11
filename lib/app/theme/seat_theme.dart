import 'package:flutter/material.dart';

abstract final class SeatColors {
  static const cream = Color(0xFFF7F2E9);
  static const secondaryBackground = Color(0xFFEEE7DB);
  static const surface = Color(0xFFFFFCF7);
  static const charcoal = Color(0xFF24211F);
  static const secondary = Color(0xFF68615B);
  static const terracotta = Color(0xFFB65F43);
  static const green = Color(0xFF47725B);
  static const warning = Color(0xFF9A651F);
  static const destructive = Color(0xFFA33D35);
  static const divider = Color(0xFFD9D1C6);
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
      secondary: SeatColors.secondary,
      onSecondary: Colors.white,
      surfaceContainer: SeatColors.secondaryBackground,
      surfaceContainerHighest: SeatColors.secondaryBackground,
      outline: SeatColors.divider,
      error: SeatColors.destructive,
    ),
    fontFamily: locale.languageCode == 'ar' ? 'Noto Sans Arabic' : 'Inter',
  );
  return base.copyWith(
    textTheme: base.textTheme
        .apply(
          bodyColor: SeatColors.charcoal,
          displayColor: SeatColors.charcoal,
        )
        .copyWith(
          displaySmall: const TextStyle(
            color: SeatColors.charcoal,
            fontSize: 40,
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
          headlineLarge: const TextStyle(
            color: SeatColors.charcoal,
            fontSize: 30,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: const TextStyle(
            color: SeatColors.charcoal,
            fontSize: 24,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: const TextStyle(
            color: SeatColors.charcoal,
            fontSize: 20,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: const TextStyle(
            color: SeatColors.charcoal,
            fontSize: 17,
            height: 1.5,
          ),
          bodyMedium: const TextStyle(
            color: SeatColors.charcoal,
            fontSize: 15,
            height: 1.45,
          ),
          bodySmall: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color: SeatColors.secondary,
          ),
          labelLarge: const TextStyle(
            color: SeatColors.charcoal,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
      labelStyle: TextStyle(color: SeatColors.secondary),
      hintStyle: TextStyle(color: SeatColors.secondary),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: SeatColors.cream,
      foregroundColor: SeatColors.charcoal,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: SeatColors.surface,
      indicatorColor: Color(0x1FB65F43),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: SeatColors.charcoal, fontWeight: FontWeight.w600),
      ),
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(color: SeatColors.terracotta),
      ),
    ),
    dividerTheme: const DividerThemeData(color: SeatColors.divider),
  );
}
