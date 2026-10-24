import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/check_email_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/signup_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/splash_provider.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/splash_route.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:event_hub_mobile/features/bookings/presentation/screens/checkout_screen.dart';
import 'package:event_hub_mobile/features/bookings/presentation/screens/order_success_screen.dart';
import 'package:event_hub_mobile/features/bookings/presentation/screens/payment_failed_screen.dart';
import 'package:event_hub_mobile/features/bookings/presentation/screens/payment_screen.dart';
import 'package:event_hub_mobile/features/bookings/presentation/screens/select_tickets_screen.dart';
import 'package:event_hub_mobile/core/router/app_shell.dart';
import 'package:event_hub_mobile/features/bookings/presentation/screens/my_tickets_screen.dart';
import 'package:event_hub_mobile/features/bookings/presentation/screens/ticket_detail_screen.dart';
import 'package:event_hub_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:event_hub_mobile/features/saved/presentation/screens/saved_screen.dart';
import 'package:event_hub_mobile/features/events/presentation/screens/discover_screen.dart';
import 'package:event_hub_mobile/features/events/presentation/screens/event_detail_screen.dart';
import 'package:event_hub_mobile/features/events/presentation/screens/home_screen.dart';
import 'package:event_hub_mobile/features/events/presentation/screens/search_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';

part 'app_router.g.dart';

const _authPaths = {
  AppRoutes.welcome,
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.forgotPassword,
  AppRoutes.checkEmail,
};

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.listen(splashDoneProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final location = state.matchedLocation;

      if (auth.isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final loggedIn = auth.value != null;
      if (location == AppRoutes.splash) {
        // Stay until the Splash has finished its hop and the reveal.
        if (!ref.read(splashDoneProvider)) return null;
        return loggedIn ? AppRoutes.home : AppRoutes.welcome;
      }
      if (!loggedIn && !_authPaths.contains(location)) return AppRoutes.welcome;
      if (loggedIn && _authPaths.contains(location)) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashRoute()),
      // Welcome and Home have no transition of their own: the Splash has
      // already revealed them, so swapping in the real page must look the same.
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (_, state) =>
            NoTransitionPage(key: state.pageKey, child: const WelcomeScreen()),
      ),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: AppRoutes.signup, builder: (_, _) => const SignupScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkEmail,
        builder: (_, state) =>
            CheckEmailScreen(email: (state.extra as String?) ?? ''),
      ),
      // The four main tabs share one bottom bar and keep their own state.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          for (final (path, screen) in <(String, Widget)>[
            (AppRoutes.home, const HomeScreen()),
            (AppRoutes.tickets, const MyTicketsScreen()),
            (AppRoutes.saved, const SavedScreen()),
            (AppRoutes.profile, const ProfileScreen()),
          ])
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: path,
                  // Switching tabs should not slide.
                  pageBuilder: (_, state) =>
                      NoTransitionPage(key: state.pageKey, child: screen),
                ),
              ],
            ),
        ],
      ),
      GoRoute(
        path: AppRoutes.ticketDetailPattern,
        builder: (_, state) =>
            TicketDetailScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.selectTicketsPattern,
        builder: (_, state) =>
            SelectTicketsScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.checkoutPattern,
        builder: (_, state) =>
            CheckoutScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.paymentPattern,
        builder: (_, state) =>
            PaymentScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.orderSuccessPattern,
        builder: (_, state) =>
            OrderSuccessScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.paymentFailedPattern,
        builder: (_, state) => PaymentFailedScreen(
          bookingId: state.pathParameters['id']!,
          reason: state.extra as String?,
        ),
      ),
      GoRoute(
        path: AppRoutes.discover,
        builder: (_, _) => const DiscoverScreen(),
      ),
      GoRoute(path: AppRoutes.search, builder: (_, _) => const SearchScreen()),
      GoRoute(
        path: AppRoutes.eventDetailPattern,
        builder: (_, state) =>
            EventDetailScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
}
