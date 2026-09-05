import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF0EDE6);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF2C2C2A);
  static const textMuted = Color(0xFF8B8580);
  static const accent = Color(0xFF5C3A28);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.card,
    colorScheme: const ColorScheme.light(
      primary: AppColors.textPrimary,
      surface: AppColors.card,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textMuted),
    ),
  );
}
