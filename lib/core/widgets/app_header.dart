import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Top bar of a screen: a round back button and a centered [title].
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.title, this.onBack});

  final String? title;

  /// Defaults to going back, or to Home when there is nothing to go back to.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Row(
          spacing: 12,
          children: [
            Material(
              color: context.surface,
              shape: CircleBorder(side: BorderSide(color: context.line)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap:
                    onBack ??
                    () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.home),
                child: Tooltip(
                  message: 'Back',
                  child: SizedBox.square(
                    dimension: 40,
                    child: Icon(
                      LucideIcons.arrowLeft,
                      size: 18,
                      color: context.ink,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: context.subhead,
              ),
            ),
            // Same width as the back button, so the title stays centered.
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
