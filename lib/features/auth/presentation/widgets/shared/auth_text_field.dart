import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool? isPasswordVisible;
  final VoidCallback? onVisibilityToggle;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

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
  });

  static const _radius = 12.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const fieldShadow = [
      BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 1)),
    ];

    return Container(
      decoration: const BoxDecoration(
        boxShadow: fieldShadow,
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !(isPasswordVisible ?? false) : false,
        keyboardType: keyboardType,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 15.5,
          color: cs.onSurface,
        ),
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: cs.onSecondaryContainer.withValues(alpha: 0.7),
          ),
          floatingLabelStyle: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: cs.onSurface.withValues(alpha: 0.55),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: FaIcon(
                    isPasswordVisible ?? false
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    size: 15,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          filled: true,
          fillColor: cs.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: BorderSide(color: cs.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: BorderSide(color: cs.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: BorderSide(color: cs.error, width: 1.5),
          ),
          errorStyle: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12.5,
            color: cs.error,
          ),
        ),
      ),
    );
  }
}
