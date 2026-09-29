import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Events near', style: context.caption),
                      Text('San Francisco, US', style: context.link),
                    ],
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: context.accent.withValues(alpha: 0.07),
                    child: Text(
                      'FN',
                      style: context.link.copyWith(color: context.accent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
