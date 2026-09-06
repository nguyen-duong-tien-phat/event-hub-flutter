import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF0EDE6);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF2C2C2A);
  static const textMuted = Color(0xFF8B8580);
  static const accent = Color(0xFF5C3A28);

  // Used specifically on the event detail screen, where the hero
  // image blends into a dark surface (rest of the app stays light).
  static const detailBackground = Color(0xFF1C1712);
  static const detailCard = Color(0xFF2A2420);
  static const detailBorder = Color(0xFF3C332C);
  static const accentOnDark = Color(0xFFE0A672); // warm tan — pops on dark
  static const textOnDark = Color(0xFFF5F1EA);
  static const textMutedOnDark = Color(0xFFA89E92);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.card,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      surface: AppColors.card,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textMuted),
    ),
  );
}
