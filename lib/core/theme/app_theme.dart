import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF7F7F5);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE7E7E3);

  static const textPrimary = Color(0xFF17191C);
  static const textMuted = Color(0xFF73777D);

  // Vibrant event accent
  static const accent = Color(0xFF7C3AED);
  static const accentStrong = Color(0xFF6D28D9);

  static const pink = Color(0xFFEC4899);
  static const gold = Color(0xFFF59E0B);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
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
