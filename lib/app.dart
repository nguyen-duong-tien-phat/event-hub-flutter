import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:event_hub_mobile/features/auth/presentations/provider/auth_provider.dart';
import 'package:event_hub_mobile/features/auth/presentations/screens/login_screen.dart';
import 'package:event_hub_mobile/features/auth/presentations/screens/splash_screen.dart';
import 'package:event_hub_mobile/features/events/presentation/screens/event_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventHubApp extends StatelessWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    Widget home = const LoginScreen();

    if (auth.isInitializing) {
      home = const SplashScreen();
    } else if (auth.isLoggedIn) {
      home = const EventListScreen();
    } else {
      home = const LoginScreen();
    }

    return MaterialApp(
      title: 'Event Hub',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}
