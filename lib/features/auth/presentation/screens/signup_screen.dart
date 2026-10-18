import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_text_field.dart';
import 'package:event_hub_mobile/features/auth/presentation/auth_validators.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:event_hub_mobile/features/auth/presentation/widgets/auth_error.dart';
import 'package:event_hub_mobile/features/auth/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = ref.read(authProvider.notifier);
    final email = _email.text.trim();

    try {
      await auth.register(_name.text.trim(), email, _password.text);
      // The backend returns no token on register, so sign in right after.
      await auth.login(email, _password.text);
      // AuthGate now shows Home underneath: drop the auth screens on top.
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
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
            const Align(
              alignment: Alignment.centerLeft,
              child: AuthBackButton(),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 24,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text('Create your account', style: context.display),
                        Text(
                          'It takes less than a minute.',
                          style: context.body.copyWith(color: context.muted),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 14,
                      children: [
                        AppTextField(
                          label: 'Full name',
                          hint: 'Your name',
                          controller: _name,
                          validator: (v) =>
                              validateRequired(v, 'Enter your name'),
                          keyboardType: TextInputType.name,
                          autofillHints: const [AutofillHints.name],
                        ),
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
                          hint: 'At least 6 characters',
                          controller: _password,
                          validator: validateNewPassword,
                          autofillHints: const [AutofillHints.newPassword],
                        ),
                        PasswordField(
                          label: 'Confirm password',
                          hint: 'Re-enter your password',
                          controller: _confirm,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Confirm your password';
                            }
                            return v == _password.text
                                ? null
                                : 'Passwords don’t match';
                          },
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onSubmitted: (_) => _submit(),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        AuthError(_error),
                        AppButton(
                          label: 'Create account',
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
                              'Already have an account? ',
                              style: context.bodySmall.copyWith(
                                color: context.muted,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context)
                                  .pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  ),
                              child: Text(
                                'Log in',
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
