import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

typedef NavTab = ({IconData icon, String label});

/// Bottom bar of the main tabs. It only shows [currentIndex] and reports
/// taps; the router decides what each tab opens.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<NavTab> tabs = [
    (icon: LucideIcons.house, label: 'Home'),
    (icon: LucideIcons.ticket, label: 'Tickets'),
    (icon: LucideIcons.heart, label: 'Saved'),
    (icon: LucideIcons.userRound, label: 'Profile'),
  ];

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    // Material (not Container color) paints the background, so the
    // InkWell ripple shows on top of it instead of underneath.
    return Material(
      color: context.surface,
      child: Container(
        padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.line)),
        ),
        // Real home-indicator space instead of a fixed 20.
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, tab) in tabs.indexed)
                Expanded(
                  child: _Tab(
                    icon: tab.icon,
                    label: tab.label,
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.ink : context.muted;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.tabLabel.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
            const SizedBox(height: 4),
            // Always present (transparent when off) so every tab is the
            // same height and the color change can animate.
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? context.accent : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
