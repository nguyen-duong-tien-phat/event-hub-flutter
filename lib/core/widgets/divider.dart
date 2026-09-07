import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  final bool dash;
  final Color color;
  final double height;

  const AppDivider({
    super.key,
    this.dash = false,
    this.color = AppColors.border,
    this.height = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (!dash) {
      return Divider(color: color, height: height, thickness: height);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 4.0;

        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace))
            .floor();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dashCount,
              (_) => SizedBox(
                width: dashWidth,
                height: height,
                child: DecoratedBox(decoration: BoxDecoration(color: color)),
              ),
            ),
          ),
        );
      },
    );
  }
}
