import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.ink,
      ),
      child: Center(
        child: Icon(LucideIcons.ticket, color: context.surface, size: 22),
      ),
    );
  }
}
