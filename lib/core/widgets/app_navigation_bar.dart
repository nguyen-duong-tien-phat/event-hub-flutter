import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

typedef NavTab = ({IconData icon, String label});

class AppNavigationBar extends StatefulWidget {
  const new({super.key});

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const List<NavTab> tabs = [
      (icon: LucideIcons.compass, label: 'Discover'),
      (icon: LucideIcons.ticket, label: 'Tickets'),
      (icon: LucideIcons.heart, label: 'Saved'),
      (icon: LucideIcons.userRound, label: 'Profile'),
    ];

    // Material (not Container color) paints the background, so the
    // InkWell ripple shows on top of it instead of underneath.
    return Material(
      color: context.surface,
      child: Container(
        padding: EdgeInsets.only(top: 8, left: 12, right: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.line)),
        ),
        // Real home-indicator space instead of a fixed 20.
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, tab) in tabs.indexed)
                Expanded(
                  child: _Tab(
                    icon: tab.icon,
                    label: tab.label,
                    selected: i == selectedIndex,
                    onTap: () => setState(() {
                      selectedIndex = i;
                    }),
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
  final IconData icon;
  final String label;
  final bool selected;
  final GestureTapCallback onTap;

  const new({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color = selected ? context.ink : context.muted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: 4, bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            SizedBox(height: 4),
            Text(
              label,
              style: context.tabLabel.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
            SizedBox(height: 4),
            // Always present (transparent when off) so every tab is the
            // same height and the color change can animate.
            AnimatedContainer(
              duration: Duration(milliseconds: 180),
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
