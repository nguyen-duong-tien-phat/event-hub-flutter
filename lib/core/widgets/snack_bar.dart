import 'package:flutter/material.dart';

import 'package:event_hub_mobile/core/theme/app_theme.dart';

/// Shared snackbar styling and behavior.
/// Keeps error/success messages consistent throughout the app.

void showErrorSnackBar(
  BuildContext context,
  String message, {
  bool showClose = true,
}) {
  _showSnackBar(
    context,
    message: message,
    icon: Icons.error_outline_rounded,
    accentColor: Colors.redAccent,
    showClose: showClose,
  );
}

void showSuccessSnackBar(
  BuildContext context,
  String message, {
  bool showClose = true,
}) {
  _showSnackBar(
    context,
    message: message,
    icon: Icons.check_circle_outline_rounded,
    accentColor: AppColors.accent,
    showClose: showClose,
  );
}

void _showSnackBar(
  BuildContext context, {
  required String message,
  required IconData icon,
  required Color accentColor,
  required bool showClose,
}) {
  final messenger = ScaffoldMessenger.of(context);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accentColor.withValues(alpha: 0.35)),
        ),

        // Controls how long the snackbar stays visible.
        duration: showClose
            ? const Duration(days: 365)
            : const Duration(seconds: 3),

        // Built-in SnackBar animation.
        animation: CurvedAnimation(
          parent: kAlwaysCompleteAnimation,
          curve: Curves.easeOutCubic,
        ),

        content: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),

            if (showClose) ...[
              const SizedBox(width: 4),
              IconButton(
                onPressed: messenger.hideCurrentSnackBar,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                splashRadius: 18,
              ),
            ],
          ],
        ),
      ),
    );
}
