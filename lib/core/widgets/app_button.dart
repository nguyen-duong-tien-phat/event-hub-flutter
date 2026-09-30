import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// - primary: solid accent, the main action ("Book now")
/// - secondary: neutral grey border, ink text ("Cancel")
/// - outline: accent border and text, no fill ("Follow", "Add to calendar")
/// - ghost: text only ("See all")
/// - danger: solid danger, destructive actions ("Delete account")
enum AppButtonVariant { primary, secondary, outline, ghost, danger }

/// Preset heights and paddings so call sites don't pick their own numbers.
enum AppButtonSize {
  small(height: 36, horizontalPadding: 14, iconSize: 16),
  medium(height: 48, horizontalPadding: 18, iconSize: 18),
  large(height: 52, horizontalPadding: 22, iconSize: 20);

  final double height;
  final double horizontalPadding;
  final double iconSize;

  const AppButtonSize({
    required this.height,
    required this.horizontalPadding,
    required this.iconSize,
  });
}

/// The app's button. Picks the right Material button for [variant] and
/// styles it, so ripple, focus, disabled state and accessibility still work.
///
/// - Pass `onPressed: null` to disable it.
/// - [isLoading] shows a spinner and blocks taps but keeps the button's
///   width and colors, so the layout doesn't jump.
/// - [expand] makes it full width. Don't use it inside a Row without
///   wrapping the button in Expanded — a Row gives unlimited width.
/// - [AppButton.icon] makes a square, icon-only button.
class AppButton extends StatelessWidget {
  /// Null for icon-only buttons.
  final String? label;

  /// Shown on long press and read by screen readers. Required for
  /// icon-only buttons, since there's no text to describe them.
  final String? tooltip;

  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  const AppButton({
    super.key,
    required String this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.tooltip,
  });

  /// Square button with only an icon, e.g. favorite, share, close.
  const AppButton.icon({
    super.key,
    required IconData this.icon,
    required String this.tooltip,
    required this.onPressed,
    this.variant = AppButtonVariant.secondary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
  }) : label = null,
       expand = false;

  bool get _isIconOnly => label == null;

  bool get _isFilled =>
      variant == AppButtonVariant.primary || variant == AppButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final foreground = _foreground(context);
    final style = _style(context, foreground);
    final child = _content(foreground);

    final button = switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.danger => FilledButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.secondary || AppButtonVariant.outline => OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    };

    final result = IgnorePointer(ignoring: isLoading, child: button);
    if (tooltip == null) return result;
    return Tooltip(message: tooltip!, child: result);
  }

  Color _foreground(BuildContext context) => switch (variant) {
    AppButtonVariant.primary || AppButtonVariant.danger => Colors.white,
    AppButtonVariant.secondary => context.ink,
    AppButtonVariant.outline || AppButtonVariant.ghost => context.accent,
  };

  Color? _background(BuildContext context) => switch (variant) {
    AppButtonVariant.primary => context.accent,
    AppButtonVariant.danger => context.danger,
    AppButtonVariant.secondary => context.surface,
    AppButtonVariant.outline || AppButtonVariant.ghost => null, // transparent
  };

  ButtonStyle _style(BuildContext context, Color foreground) {
    final background = _background(context);
    // Ghost reads like a link, so it stays 14px at every size.
    final textStyle = switch (variant) {
      AppButtonVariant.ghost => context.link,
      _ when size == AppButtonSize.small => context.metaStrong,
      _ => context.bodyStrong,
    };

    // Text and icon share one color, greyed out when disabled.
    final foregroundColor = WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.disabled) ? context.muted : foreground,
    );

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled) && _isFilled) {
          return context.line;
        }
        return background;
      }),
      foregroundColor: foregroundColor,
      iconColor: foregroundColor,
      side: switch (variant) {
        AppButtonVariant.secondary => WidgetStatePropertyAll(
          BorderSide(color: context.line),
        ),
        // Accent border, back to the neutral line color when disabled.
        AppButtonVariant.outline => WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.disabled)
                ? context.line
                : context.accent,
          ),
        ),
        _ => null,
      },
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(textStyle),
      padding: WidgetStatePropertyAll(
        _isIconOnly
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: size.horizontalPadding),
      ),
      // Icon-only: width = height, so the button is square.
      minimumSize: WidgetStatePropertyAll(
        Size(
          _isIconOnly ? size.height : (expand ? double.infinity : 0),
          size.height,
        ),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  Widget _content(Color foreground) {
    final Widget content = _isIconOnly
        ? Icon(icon, size: size.iconSize)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: size.iconSize),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    if (!isLoading) return content;

    // Keep the invisible label in place so the button keeps its width.
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: 0, child: content),
        SizedBox.square(
          dimension: size.iconSize,
          child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
        ),
      ],
    );
  }
}
