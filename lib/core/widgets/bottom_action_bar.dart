import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Fixed bar at the bottom of a screen: a summary on the left (usually a
/// [BottomBarLabel]) and the screen's main action button on the right.
///
/// Used for "Get tickets", "Continue", "Pay" and similar. Put it at the
/// bottom of a `Stack`, or in `Scaffold.bottomNavigationBar`.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.leading,
    required this.actionLabel,
    required this.onPressed,
    this.actionWidth = 190,
    this.variant = AppButtonVariant.primary,
  });

  /// Fills the space left of the button.
  final Widget leading;

  final String actionLabel;

  /// Null disables the button.
  final VoidCallback? onPressed;

  final double actionWidth;
  final AppButtonVariant variant;

  static const double _gutter = 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.line)),
      ),
      child: SafeArea(
        top: false,
        // Room for the home indicator, never less than 14.
        minimum: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(_gutter, 14, _gutter, 0),
          child: Row(
            spacing: 16,
            children: [
              Expanded(child: leading),
              SizedBox(
                width: actionWidth,
                child: AppButton(
                  label: actionLabel,
                  variant: variant,
                  size: AppButtonSize.large,
                  expand: true,
                  onPressed: onPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small caption over a larger value, e.g. "From" over "$25.00" or
/// "Total" over "$50.00". Meant for [BottomActionBar.leading].
class BottomBarLabel extends StatelessWidget {
  const BottomBarLabel({super.key, required this.caption, required this.value});

  final String caption;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: context.caption.copyWith(color: context.muted)),
        Text(value, style: context.title),
      ],
    );
  }
}
