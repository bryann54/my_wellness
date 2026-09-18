// lib/common/widgets/app_form_field.dart

import 'package:flutter/material.dart';

class AppFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Widget icon;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool readOnly;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const AppFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
      onChanged: onChanged,
      style: tt.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: tt.labelMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.55),
        ),
        hintStyle: tt.bodySmall?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.35),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: IconTheme(
            data: IconThemeData(size: 20, color: cs.primary),
            child: icon,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: cs.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }
}
