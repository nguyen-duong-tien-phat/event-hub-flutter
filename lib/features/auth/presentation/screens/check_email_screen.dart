import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_text_field.dart';
import 'package:event_hub_mobile/features/auth/data/auth_repository.dart';
import 'package:event_hub_mobile/features/auth/presentation/auth_validators.dart';
import 'package:event_hub_mobile/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:event_hub_mobile/features/auth/presentation/widgets/auth_error.dart';
import 'package:event_hub_mobile/features/auth/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The second step of "forgot password": type the 6-digit code from the email
/// and choose a new password.
class CheckEmailScreen extends ConsumerStatefulWidget {
  const CheckEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends ConsumerState<CheckEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _info = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(widget.email, _code.text.trim(), _password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated. Log in with your new password.'),
        ),
      );
      context.go(AppRoutes.login);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _isResending = true;
      _error = null;
      _info = null;
    });

    try {
      await ref.read(authRepositoryProvider).forgotPassword(widget.email);
      if (mounted) {
        setState(
          () => _info = 'We sent you a new code. The old one no longer works.',
        );
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isResending = false);
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 24,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text('Check your inbox', style: context.display),
                          Text.rich(
                            TextSpan(
                              text: 'We sent a 6-digit code to ',
                              children: [
                                TextSpan(
                                  text: widget.email,
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
                            style: context.body.copyWith(color: context.muted),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          AppTextField(
                            label: 'Code',
                            hint: '123456',
                            controller: _code,
                            validator: validateResetCode,
                            keyboardType: TextInputType.number,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                          ),
                          PasswordField(
                            label: 'New password',
                            hint: 'At least 8 characters',
                            controller: _password,
                            validator: validateResetPassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            onSubmitted: (_) => _submit(),
                          ),
                          AuthError(_error),
                          if (_info != null)
                            Text(
                              _info!,
                              style: context.caption.copyWith(
                                color: context.muted,
                              ),
                            ),
                          AppButton(
                            label: 'Reset password',
                            variant: AppButtonVariant.dark,
                            size: AppButtonSize.large,
                            expand: true,
                            isLoading: _isLoading,
                            onPressed: _submit,
                          ),
                          Center(
                            child: TextButton(
                              onPressed: _isResending ? null : _resend,
                              child: Text(
                                _isResending ? 'Sending...' : 'Send a new code',
                                style: context.fieldLabel.copyWith(
                                  color: context.ink,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
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
