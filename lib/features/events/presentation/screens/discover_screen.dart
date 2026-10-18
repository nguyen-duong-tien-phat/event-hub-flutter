import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// Placeholder for the Discover screen ("See all" on Home goes here).
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Discover', style: context.headline)),
      body: Center(
        child: Text(
          'Coming soon',
          style: context.body.copyWith(color: context.muted),
        ),
      ),
    );
  }
}
