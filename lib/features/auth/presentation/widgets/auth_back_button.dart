import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Round back button shown at the top left of auth screens.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: context.surface,
          shape: CircleBorder(side: BorderSide(color: context.line)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).maybePop(),
            child: Tooltip(
              message: 'Back',
              child: SizedBox.square(
                dimension: 40,
                child: Icon(LucideIcons.arrowLeft, size: 18, color: context.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
