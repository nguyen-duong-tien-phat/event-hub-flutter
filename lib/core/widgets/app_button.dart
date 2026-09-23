import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// How the button is painted. Filled for a stronger call to action,
/// outline for a secondary one (e.g. "Retry" next to an error).
enum AppButtonVariant { filled, outline }

/// Preset heights/paddings so buttons stay consistent without every
/// call site picking its own numbers.
enum AppButtonSize {
  small(height: 36, fontSize: 13, horizontalPadding: 16),
  medium(height: 44, fontSize: 14, horizontalPadding: 20),
  large(height: 52, fontSize: 16, horizontalPadding: 24);

  final double height;
  final double fontSize;
  final double horizontalPadding;

  const AppButtonSize({
    required this.height,
    required this.fontSize,
    required this.horizontalPadding,
  });
}

/// A configurable button — unlike [PrimaryButton] (always full-width,
/// always large, always filled), this one lets the call site pick
/// [width] (null = hug its content), [size] and [variant].
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Fixed width, or null to size to the label (e.g. for a small
  /// inline "Retry" button instead of a full-width one).
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.size = AppButtonSize.medium,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == AppButtonVariant.filled;

    final button = isFilled
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentStrong,
              disabledBackgroundColor: AppColors.border,
              padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _label(Colors.white),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentStrong,
              disabledForegroundColor: AppColors.textMuted,
              side: const BorderSide(color: AppColors.border),
              padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _label(
              onPressed == null ? AppColors.textMuted : AppColors.accentStrong,
            ),
          );

    return SizedBox(width: width, height: size.height, child: button);
  }

  Text _label(Color color) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: size.fontSize,
      ),
    );
  }
}
