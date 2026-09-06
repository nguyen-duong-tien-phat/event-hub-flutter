import 'package:event_hub_mobile/features/events/presentation/screens/event_list_screen.dart';
import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EventHubApp extends StatelessWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Hub',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const EventListScreen(),
    );
  }
}
