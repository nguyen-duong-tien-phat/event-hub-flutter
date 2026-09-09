import 'package:flutter/material.dart';
import 'package:event_hub_mobile/core/theme/app_theme.dart';

/// Shared text field for the whole app — search bar, auth, and forms.
///
/// Optionally takes a [validator]: a function that returns an error
/// message string for invalid input, or null when valid. The error
/// only appears once the field loses focus (blur) for the first time,
/// not while the user is still typing their first entry — but once an
/// error has been shown, it re-checks on every keystroke so it clears
/// as soon as the input becomes valid again.
class AppTextField extends StatefulWidget {
  final String? label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final String? Function(String value)? validator;

  const AppTextField({
    super.key,
    this.label,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    // Only validate the moment focus is LOST (blur) — not while
    // gaining focus, and not on every keystroke initially.
    if (!_focusNode.hasFocus) {
      _validate(widget.controller?.text ?? '');
    }
  }

  void _validate(String value) {
    final result = widget.validator?.call(value);
    if (result != _errorText) {
      setState(() => _errorText = result);
    }
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    // Once an error is showing, keep re-checking live so it clears
    // as soon as the person fixes it — no need to blur again.
    if (_errorText != null) {
      _validate(value);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? Colors.redAccent : AppColors.border,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            textInputAction: TextInputAction.next,
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            onChanged: _handleChanged,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            _errorText!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
