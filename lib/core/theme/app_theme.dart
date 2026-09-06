import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF1C1712);
  static const card = Color(0xFF2A2420);
  static const border = Color(0xFF3C332C);
  static const textPrimary = Color(0xFFF5F1EA);
  static const textMuted = Color(0xFFA89E92);

  // Warm tan — text/icon color for anything sitting directly on a
  // dark background or card (pin icon, price text, cursor, etc.).
  static const accent = Color(0xFFE0A672);

  // Dark brown — used only as a SOLID fill behind white text or
  // dark text on a light chip (buttons, selected pill background).
  // Do not use as text color on a dark surface — too low contrast.
  static const accentStrong = Color(0xFF5C3A28);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.card,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.card,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textMuted),
    ),
  );
}
