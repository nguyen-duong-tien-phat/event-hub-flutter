import 'package:event_hub_mobile/core/config/env.dart';
import 'package:event_hub_mobile/core/router/app_router.dart';
import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Stripe has no web support here; elsewhere it needs the publishable key.
  if (!kIsWeb && Env.stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = Env.stripePublishableKey;
    await Stripe.instance.applySettings();
  }
  runApp(const ProviderScope(child: EventHubApp()));
}

class EventHubApp extends ConsumerWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Event Hub',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
