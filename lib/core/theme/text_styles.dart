import 'package:event_hub_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Design text styles by their design-file names.
/// Colors are left out: add them at the call site from the colorScheme.
/// Overline and date badge month are all caps: call .toUpperCase() on the string.
extension AppTextStyles on BuildContext {
  TextTheme get _t => Theme.of(this).textTheme;

  // COLORS
  Color get background => AppColors.background;
  Color get surface => AppColors.surface;
  Color get line => AppColors.line;
  Color get ink => AppColors.ink;
  Color get muted => AppColors.muted;
  Color get accent => AppColors.accent;
  Color get success => AppColors.success;
  Color get danger => AppColors.danger;

  // TEXT STYLES
  // Mapped onto TextTheme slots (defined in AppTextTheme)
  TextStyle get display => _t.displaySmall!;
  TextStyle get title => _t.headlineSmall!;
  TextStyle get cardTitle => _t.titleLarge!;
  TextStyle get headline => _t.titleMedium!;
  TextStyle get subhead => _t.titleSmall!;
  TextStyle get body => _t.bodyLarge!;
  TextStyle get bodySmall => _t.bodyMedium!;
  TextStyle get caption => _t.bodySmall!;
  TextStyle get bodyStrong => _t.labelLarge!;
  TextStyle get control => _t.labelMedium!;
  TextStyle get fieldLabel => _t.labelSmall!;

  // Variants with no slot of their own
  TextStyle get bodyEmphasis => body.copyWith(fontWeight: FontWeight.w500);
  TextStyle get link => bodySmall.copyWith(fontWeight: FontWeight.w600);
  TextStyle get badge => caption.copyWith(fontWeight: FontWeight.w600);
  TextStyle get meta => caption.copyWith(fontSize: 13);
  TextStyle get metaStrong => meta.copyWith(fontWeight: FontWeight.w600);
  TextStyle get dateLine => badge.copyWith(letterSpacing: 0.24);
  TextStyle get tabLabel =>
      caption.copyWith(fontSize: 11, fontWeight: FontWeight.w500);
  TextStyle get overline => caption.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.88,
  );
  TextStyle get dateBadgeMonth =>
      overline.copyWith(fontSize: 10, letterSpacing: 0.8);
}
