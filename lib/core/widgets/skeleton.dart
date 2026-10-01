import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class Skeleton extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const Skeleton({
    super.key,
    this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.line,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
