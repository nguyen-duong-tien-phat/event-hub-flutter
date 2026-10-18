import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_loading.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    this.isReady = false,
    this.onFinished,
    this.iconKey,
  });

  /// True once loading is done: the animation plays out its current hop,
  /// then [onFinished] is called.
  final bool isReady;
  final VoidCallback? onFinished;

  /// Identifies the icon so a transition can grow out of its position.
  final GlobalKey? iconKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            AppLoading(
              finishing: isReady,
              onFinished: onFinished,
              iconKey: iconKey,
            ),
            Text('Event Hub', style: context.title),
          ],
        ),
      ),
    );
  }
}
