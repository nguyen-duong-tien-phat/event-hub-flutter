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

    return Container(
      padding: EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 20),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.line)),
      ),
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
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            SizedBox(height: 4),
            Text(
              label,
              style: context.caption.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
            SizedBox(height: 4),
            if (selected)
              AnimatedContainer(
                duration: Duration(milliseconds: 180),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
