import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/splash_provider.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:event_hub_mobile/features/events/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The page behind the `/splash` route.
///
/// Shows the Splash while auth is checked. It always plays out its current
/// hop, even if the check finishes instantly. Then the next page bursts out
/// of the icon: a dark rounded square grows from the icon to the whole
/// screen, with the page revealed inside it just behind. When that is done,
/// [SplashDone] is set and the router swaps in the real page.
class SplashRoute extends ConsumerStatefulWidget {
  const SplashRoute({super.key});

  @override
  ConsumerState<SplashRoute> createState() => _SplashRouteState();
}

class _SplashRouteState extends ConsumerState<SplashRoute>
    with SingleTickerProviderStateMixin {
  static const _iconRadius = 10.0;

  final _iconKey = GlobalKey();
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  bool _revealing = false;
  Rect _iconRect = Rect.zero;

  @override
  void initState() {
    super.initState();
    _reveal.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        ref.read(splashDoneProvider.notifier).finish();
      }
    });
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  void _startReveal() {
    final box = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.attached) {
      _iconRect = box.localToGlobal(Offset.zero) & box.size;
    }
    setState(() => _revealing = true);
    _reveal.forward();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    // What the router will show next.
    final Widget target = auth.value != null
        ? const HomeScreen()
        : const WelcomeScreen();

    // Splash and overlay share one Stack so the Splash keeps animating
    // underneath instead of restarting when the reveal begins.
    return Stack(
      fit: StackFit.expand,
      children: [
        SplashScreen(
          iconKey: _iconKey,
          isReady: !auth.isLoading,
          onFinished: _startReveal,
        ),
        if (_revealing)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _reveal,
              builder: (context, _) => _buildReveal(context, target),
            ),
          ),
      ],
    );
  }

  Widget _buildReveal(BuildContext context, Widget page) {
    final size = MediaQuery.sizeOf(context);
    final screen = Offset.zero & size;

    // The dark square leads; the page follows a beat behind, which leaves a
    // thin dark edge around it while it grows.
    final inkT = Curves.easeInOutCubic.transform(
      const Interval(0, 0.85).transform(_reveal.value),
    );
    final pageT = Curves.easeInOutCubic.transform(
      const Interval(0.12, 1).transform(_reveal.value),
    );

    RRect shape(double t) => RRect.fromRectAndRadius(
      Rect.lerp(_iconRect, screen, t)!,
      Radius.circular(_iconRadius * (1 - t)),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(
          clipper: _ShapeClipper(shape(inkT)),
          child: ColoredBox(color: context.ink),
        ),
        ClipPath(clipper: _ShapeClipper(shape(pageT)), child: page),
      ],
    );
  }
}

class _ShapeClipper extends CustomClipper<Path> {
  const _ShapeClipper(this.shape);

  final RRect shape;

  @override
  Path getClip(Size size) => Path()..addRRect(shape);

  @override
  bool shouldReclip(_ShapeClipper oldClipper) => oldClipper.shape != shape;
}
