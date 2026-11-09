import 'package:event_hub_mobile/core/widgets/app_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Frame of the four main tabs: the current tab's screen and the bottom bar.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.shell,
    this.tabs = AppNavigationBar.attendeeTabs,
  });

  final StatefulNavigationShell shell;

  /// The labels and icons of the bar; organizers have their own set.
  final List<NavTab> tabs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppNavigationBar(
        tabs: tabs,
        currentIndex: shell.currentIndex,
        // Tapping the tab you are on goes back to its first screen.
        onTap: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
      ),
    );
  }
}
