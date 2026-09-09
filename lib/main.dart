import 'package:event_hub_mobile/app.dart';
import 'package:event_hub_mobile/features/auth/presentations/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..tryAutoLogin(),
      child: const EventHubApp(),
    ),
  );
}
