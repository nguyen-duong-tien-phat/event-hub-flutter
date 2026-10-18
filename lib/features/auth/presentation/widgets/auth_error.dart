import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Server-side error shown above the submit button (e.g. wrong password).
/// Renders nothing when [message] is null.
class AuthError extends StatelessWidget {
  const AuthError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(LucideIcons.circleAlert, size: 14, color: context.danger),
        ),
        Expanded(
          child: Text(
            message!,
            style: context.caption.copyWith(color: context.danger),
          ),
        ),
      ],
    );
  }
}
