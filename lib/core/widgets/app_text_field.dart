import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: context.fieldLabel),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          obscureText: obscureText,
          enabled: enabled,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: context.surface,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.line),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.accent),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.danger),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            hintText: hint,
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
            prefixIcon: prefixIcon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: prefixIcon,
                  ),
            prefixIconConstraints: const BoxConstraints(),
            prefixIconColor: context.muted,
            suffixIcon: suffixIcon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 10, right: 14),
                    child: suffixIcon,
                  ),
            suffixIconConstraints: const BoxConstraints(),
            suffixIconColor: context.muted,
          ),
        ),
      ],
    );
  }
}
