// lib/common/widgets/soft_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SoftInput extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? suffixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final int minLines;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  const SoftInput({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.suffixText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.minLines = 1,
    this.prefixIcon,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: cs.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffixText,
        prefixIcon: prefixIcon,

        // ── The fix ─────────────────────────────────────────────────
        // Always float the label so it sits on the border, never inside
        // the fill. Makes it readable against surfaceContainerHighest
        // and keeps the field height stable whether or not it has text.
        floatingLabelBehavior: FloatingLabelBehavior.always,

        filled: true,
        fillColor: cs.surfaceContainerHighest,

        labelStyle: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: cs.onSurface.withValues(alpha: 0.7),
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: cs.primary,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14.5,
          fontWeight: FontWeight.w400,
          color: cs.onSurface.withValues(alpha: 0.35),
        ),
        suffixStyle: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: cs.onSurface.withValues(alpha: 0.55),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: _border(cs, cs.outlineVariant.withValues(alpha: 0.5)),
        enabledBorder: _border(cs, cs.outlineVariant.withValues(alpha: 0.5)),
        focusedBorder: _border(cs, cs.primary, width: 1.6),
        errorBorder: _border(cs, cs.error),
        focusedErrorBorder: _border(cs, cs.error, width: 1.6),
      ),
    );
  }

  OutlineInputBorder _border(ColorScheme cs, Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
