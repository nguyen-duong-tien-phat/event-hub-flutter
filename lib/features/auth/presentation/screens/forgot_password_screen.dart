import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_text_field.dart';
import 'package:event_hub_mobile/features/auth/presentation/auth_validators.dart';
import 'package:event_hub_mobile/features/auth/presentation/screens/check_email_screen.dart';
import 'package:event_hub_mobile/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: call the backend once it has a password-reset endpoint.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckEmailScreen(email: _email.text.trim()),
      ),
    );
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text('Reset your password', style: context.display),
                          Text(
                            'Enter the email you signed up with and we’ll send '
                            'you a link to set a new password.',
                            style: context.body.copyWith(color: context.muted),
                          ),
                        ],
                      ),
                      AppTextField(
                        label: 'Email',
                        hint: 'you@example.com',
                        controller: _email,
                        validator: validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.email],
                        onSubmitted: (_) => _submit(),
                      ),
                      AppButton(
                        label: 'Send reset link',
                        variant: AppButtonVariant.dark,
                        size: AppButtonSize.large,
                        expand: true,
                        onPressed: _submit,
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
