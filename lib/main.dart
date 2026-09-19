import 'package:event_hub_mobile/app.dart';
import 'package:event_hub_mobile/features/auth/presentations/provider/auth_provider.dart';
import 'package:event_hub_mobile/features/events/data/repositories/event_repository.dart';
import 'package:event_hub_mobile/features/events/presentation/provider/event_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryAutoLogin()),
        ChangeNotifierProvider(
          create: (_) => EventListProvider(eventRepository: EventRepository()),
        ),
      ],
      child: const EventHubApp(),
    ),
  );
}
