import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _PhotoGrid(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Find what’s on\nnear you',
                      style: context.display.copyWith(height: 1.12),
                    ),
                  ),
                  Text(
                    'Concerts, food festivals and nights out — discover them '
                    'and book tickets in a few taps.',
                    style: context.body.copyWith(color: context.muted),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                spacing: 8,
                children: [
                  AppButton(
                    label: 'Get started',
                    variant: AppButtonVariant.dark,
                    size: AppButtonSize.large,
                    expand: true,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: context.ink,
                      minimumSize: const Size.fromHeight(52),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: Text(
                      'I already have an account',
                      style: context.bodyStrong,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Event photos from Unsplash (free license), loaded over the network.
/// Each tile keeps its pastel color while loading or if the image fails.
class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid();

  static String _url(String photoId) =>
      'https://images.unsplash.com/$photoId'
      '?w=600&q=70&auto=format&fit=crop';

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Expanded(
              child: _Photo(
                url: _url('photo-1666289186874-0d023fe7d002'), // crowd, stage
                height: 220,
                color: const Color(0xFFE6E0D5),
              ),
            ),
            Expanded(
              child: Column(
                spacing: 10,
                children: [
                  _Photo(
                    url: _url('photo-1555939594-58d7cb561ad1'), // grill
                    height: 130,
                    color: const Color(0xFFD9E1D8),
                  ),
                  _Photo(
                    url: _url('photo-1748302913353-90a60a1cba9b'), // lights
                    height: 80,
                    color: const Color(0xFFD9DFE7),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _Photo(
                url: _url('photo-1767371772143-de36a95b9369'), // market
                height: 80,
                color: const Color(0xFFEADDD9),
              ),
            ),
            Expanded(
              child: _Photo(
                url: _url('photo-1675674683873-1232862e3c64'), // friends
                height: 80,
                color: const Color(0xFFE2E1DB),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url, required this.height, required this.color});

  final String url;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: color,
      child: Center(
        child: Icon(
          LucideIcons.image,
          size: 28,
          color: context.ink.withValues(alpha: 0.22),
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          // Fade in once loaded instead of popping.
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return Stack(
              fit: StackFit.expand,
              children: [
                placeholder,
                AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: child,
                ),
              ],
            );
          },
          errorBuilder: (context, error, stackTrace) => placeholder,
        ),
      ),
    );
  }
}
