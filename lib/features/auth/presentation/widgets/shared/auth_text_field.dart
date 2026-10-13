import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.isPasswordVisible,
    this.onVisibilityToggle,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.autofillHints,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool? isPasswordVisible;
  final VoidCallback? onVisibilityToggle;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final obscured = isPassword && !(isPasswordVisible ?? false);

    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscured,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(fontSize: 15.5, color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 20,
          color: cs.onSurface.withValues(alpha: 0.55),
        ),
        suffixIcon: isPassword
            ? IconButton(
                tooltip: isPasswordVisible ?? false
                    ? 'Hide password'
                    : 'Show password',
                icon: Icon(
                  isPasswordVisible ?? false
                      ? PhosphorIconsRegular.eyeSlash
                      : PhosphorIconsRegular.eye,
                  size: 15,
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
      ),
    );
  }
}
