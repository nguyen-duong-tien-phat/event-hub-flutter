import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Colors for the small icon chip in front of a section title.
enum SectionTone {
  accent(foreground: null, background: null),
  amber(foreground: Color(0xFF9A5B00), background: Color(0xFFFBF1E0));

  const SectionTone({required this.foreground, required this.background});

  /// Null means "use the theme accent".
  final Color? foreground;
  final Color? background;
}

/// Section title with an icon chip and a "See all" link to Discover.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    required this.icon,
    required this.tone,
  });

  final String title;
  final IconData icon;
  final SectionTone tone;

  @override
  Widget build(BuildContext context) {
    final foreground = tone.foreground ?? context.accent;
    final background =
        tone.background ?? context.accent.withValues(alpha: 0.09);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 10,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: foreground),
            ),
            Text(title, style: context.headline),
          ],
        ),
        // Accent text + chevron: reads as a link without a background.
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: context.accent,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            iconSize: 14,
          ),
          onPressed: () => context.push(AppRoutes.discover),
          iconAlignment: IconAlignment.end,
          icon: const Icon(LucideIcons.chevronRight),
          label: Text(
            'See all',
            // Theme text styles carry their own color, which would win over
            // the button's foregroundColor, so set it here too.
            style: context.fieldLabel.copyWith(color: context.accent),
          ),
        ),
      ],
    );
  }
}
