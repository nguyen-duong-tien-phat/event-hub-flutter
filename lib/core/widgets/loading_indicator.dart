import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      strokeWidth: 2,
      color: AppColors.accent,
    );
  }
}
