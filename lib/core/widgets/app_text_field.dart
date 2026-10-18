import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// Text field with a label above it.
///
/// Validation errors are shown per field only once the user has left it
/// ("touched"), then kept live while they fix it. `Form.validate()` (e.g. on
/// submit) shows the errors of every field at once.
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  static const _radius = BorderRadius.all(Radius.circular(12));

  final _focusNode = FocusNode();
  final _fieldKey = GlobalKey<FormFieldState<String>>();

  /// True once the user has left the field (or edited it while it shows an
  /// error). From then on the field validates live.
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && !_touched) setState(() => _touched = true);
  }

  void _onChanged(String value) {
    // An error from a submit is showing: start validating live so it clears
    // as soon as the input is fixed.
    if (!_touched && _fieldKey.currentState?.hasError == true) {
      setState(() => _touched = true);
    }
    widget.onChanged?.call(value);
  }

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderSide: BorderSide(color: color, width: width),
        borderRadius: _radius,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: context.fieldLabel),
          const SizedBox(height: 6),
        ],
        TextFormField(
          key: _fieldKey,
          focusNode: _focusNode,
          controller: widget.controller,
          validator: widget.validator,
          autovalidateMode: _touched
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          onChanged: _onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: context.surface,
            enabledBorder: _border(context.line),
            focusedBorder: _border(context.accent),
            // Both error states are needed: without focusedErrorBorder the
            // field falls back to the default underline while it has focus.
            errorBorder: _border(context.danger, 1.5),
            focusedErrorBorder: _border(context.danger, 1.5),
            errorStyle: context.caption.copyWith(color: context.danger),
            errorMaxLines: 2,
            hintText: widget.hint,
            hintStyle: context.body.copyWith(
              // body's 1.5 line height pushes the hint off-centre in the field.
              height: 1.2,
              color: const Color(0xFF8A8E94),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            // Icons get exact spacing from Padding instead of the default 48px box.
            prefixIcon: widget.prefixIcon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: widget.prefixIcon,
                  ),
            prefixIconConstraints: const BoxConstraints(),
            prefixIconColor: context.muted,
            suffixIcon: widget.suffixIcon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 10, right: 14),
                    child: widget.suffixIcon,
                  ),
            suffixIconConstraints: const BoxConstraints(),
            suffixIconColor: context.muted,
          ),
        ),
      ],
    );
  }
}
