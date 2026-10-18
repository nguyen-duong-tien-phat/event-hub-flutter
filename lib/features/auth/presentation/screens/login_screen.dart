import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_text_field.dart';
import 'package:event_hub_mobile/features/auth/presentation/auth_validators.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/auth/presentation/widgets/auth_error.dart';
import 'package:event_hub_mobile/features/auth/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .login(_email.text.trim(), _password.text);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 28,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text('Welcome back', style: context.display),
                        Text(
                          'Log in to see your tickets and saved events.',
                          style: context.body.copyWith(color: context.muted),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        AppTextField(
                          label: 'Email',
                          hint: 'you@example.com',
                          controller: _email,
                          validator: validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                        ),
                        PasswordField(
                          label: 'Password',
                          hint: 'Your password',
                          controller: _password,
                          validator: (v) =>
                              validateRequired(v, 'Enter your password'),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: context.ink,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () =>
                                context.push(AppRoutes.forgotPassword),
                            child: Text(
                              'Forgot password?',
                              style: context.fieldLabel.copyWith(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        AuthError(_error),
                        AppButton(
                          label: 'Log in',
                          variant: AppButtonVariant.dark,
                          size: AppButtonSize.large,
                          expand: true,
                          isLoading: _isLoading,
                          onPressed: _submit,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New to Event Hub? ',
                              style: context.bodySmall.copyWith(
                                color: context.muted,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.pushReplacement(AppRoutes.signup),
                              child: Text(
                                'Create an account',
                                style: context.link.copyWith(
                                  color: context.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
