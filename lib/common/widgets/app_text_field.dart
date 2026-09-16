import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// One global text field used everywhere in the app.
///
/// Supports:
///  * single field          -> [fields] with one entry
///  * paired field          -> [fields] with two entries (side by side)
///  * password visibility   -> [AppFieldSpec.isPassword] + [AppFieldSpec.obscure]
///  * read-only / pickers   -> [AppFieldSpec.readOnly] + [AppFieldSpec.onTap]
///  * multi-line            -> [AppFieldSpec.maxLines]
class AppTextField extends StatelessWidget {
  /// Optional label rendered above the field(s).
  final String? label;

  /// One or two field specifications.
  final List<AppFieldSpec> fields;

  /// Optional helper / hint shown below the field(s).
  final String? helperText;

  /// Whether the whole group is enabled.
  final bool enabled;

  const AppTextField({
    super.key,
    required this.fields,
    this.label,
    this.helperText,
    this.enabled = true,
  });

  /// Convenience constructor for the common single-field case.
  factory AppTextField.single({
    Key? key,
    String? label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onVisibilityToggle,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    String? helperText,
    bool enabled = true,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
  }) {
    return AppTextField(
      key: key,
      label: label,
      helperText: helperText,
      enabled: enabled,
      fields: [
        AppFieldSpec(
          controller: controller,
          hint: hint,
          icon: icon,
          isPassword: isPassword,
          isPasswordVisible: isPasswordVisible,
          onVisibilityToggle: onVisibilityToggle,
          validator: validator,
          keyboardType: keyboardType,
          onChanged: onChanged,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          textInputAction: textInputAction,
          focusNode: focusNode,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPair = fields.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: isPair
              ? Row(
                  children: [
                    Expanded(child: _buildField(context, fields[0])),
                    Container(
                      width: 1,
                      height: 28,
                      color: theme.dividerColor.withValues(alpha: 0.2),
                    ),
                    Expanded(child: _buildField(context, fields[1])),
                  ],
                )
              : _buildField(context, fields.first),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              helperText!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: theme.hintColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildField(BuildContext context, AppFieldSpec spec) {
    final theme = Theme.of(context);
    final isPair = fields.length > 1;

    final field = TextFormField(
      controller: spec.controller,
      focusNode: spec.focusNode,
      enabled: enabled,
      readOnly: spec.readOnly,
      onTap: spec.onTap,
      obscureText: spec.isPassword ? !(spec.isPasswordVisible ?? false) : false,
      keyboardType: spec.keyboardType,
      textInputAction: spec.textInputAction,
      maxLines: spec.maxLines,
      style: GoogleFonts.poppins(fontSize: 15),
      decoration: InputDecoration(
        hintText: spec.hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: theme.hintColor.withValues(alpha: 0.6),
        ),
        prefixIcon: spec.icon != null ? Icon(spec.icon, size: 20) : null,
        suffixIcon: spec.isPassword
            ? IconButton(
                icon: Icon(
                  (spec.isPasswordVisible ?? false)
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 20,
                ),
                onPressed: spec.onVisibilityToggle,
              )
            : null,
        border: isPair
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isPair ? 12 : 16,
          vertical: 14,
        ),
        errorStyle: GoogleFonts.poppins(fontSize: 12),
      ),
      validator: spec.validator,
      onChanged: spec.onChanged,
    );

    if (!isPair) return field;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: field,
    );
  }
}

/// Spec for a single field inside [AppTextField].
class AppFieldSpec {
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final bool isPassword;
  final bool? isPasswordVisible;
  final VoidCallback? onVisibilityToggle;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const AppFieldSpec({
    this.controller,
    this.hint,
    this.icon,
    this.isPassword = false,
    this.isPasswordVisible,
    this.onVisibilityToggle,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.textInputAction,
    this.focusNode,
  });
}
