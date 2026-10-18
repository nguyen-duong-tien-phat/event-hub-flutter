import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/check_email_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/signup_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:event_hub_mobile/features/events/presentation/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
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
        return loggedIn ? AppRoutes.home : AppRoutes.welcome;
      }
      if (!loggedIn && !_authPaths.contains(location)) return AppRoutes.welcome;
      if (loggedIn && _authPaths.contains(location)) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, _) => const WelcomeScreen(),
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
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
    ],
  );
}
