import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final bool disabled;
  final bool bordered;
  final Widget child;

  const new({
    super.key,
    this.disabled = false,
    this.bordered = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.card,
          border: Border.all(
            color: bordered
                ? AppColors.accent.withValues(alpha: 0.5)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: bordered
                  ? AppColors.accent.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
