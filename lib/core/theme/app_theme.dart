import 'package:event_hub_mobile/core/theme/app_colors.dart';
import 'package:event_hub_mobile/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
    textTheme: AppTextTheme.base,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Geist',
  );
}
