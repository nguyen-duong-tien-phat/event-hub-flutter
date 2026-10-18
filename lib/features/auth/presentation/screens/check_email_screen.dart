import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: AuthBackButton(),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.accent.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          LucideIcons.mail,
                          size: 28,
                          color: context.accent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Check your inbox', style: context.title),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text.rich(
                          TextSpan(
                            text: 'We sent a reset link to ',
                            children: [
                              TextSpan(
                                text: email,
                                style: TextStyle(
                                  color: context.ink,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(
                                text: '. It expires in 30 minutes.',
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          style: context.bodySmall.copyWith(
                            color: context.muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Back to log in',
                        variant: AppButtonVariant.dark,
                        size: AppButtonSize.large,
                        expand: true,
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
