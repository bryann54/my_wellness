// lib/features/auth/presentation/widgets/auth_text_field.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !(isPasswordVisible ?? false) : false,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 15),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: theme.disabledColor),
        suffixStyle: GoogleFonts.inter(
          fontSize: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: FaIcon(
                  isPasswordVisible ?? false
                      ? FontAwesomeIcons.eyeSlash
                      : FontAwesomeIcons.eye,
                  size: 15,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        // Default Border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
        // Focused Border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        // Error Borders
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 15,
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
