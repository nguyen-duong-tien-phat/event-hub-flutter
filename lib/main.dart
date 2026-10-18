import 'package:event_hub_mobile/core/router/app_router.dart';
import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
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
