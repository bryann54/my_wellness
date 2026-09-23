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
      style: GoogleFonts.inter(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: cs.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffixText,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        labelStyle: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: cs.onSurface.withValues(alpha: 0.6),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: cs.onSurface.withValues(alpha: 0.4),
        ),
        suffixStyle: GoogleFonts.inter(
          fontSize: 13,
          color: cs.onSurface.withValues(alpha: 0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: _border(cs, cs.outlineVariant.withValues(alpha: 0.4)),
        enabledBorder: _border(cs, cs.outlineVariant.withValues(alpha: 0.4)),
        focusedBorder: _border(cs, cs.primary, width: 1.4),
        errorBorder: _border(cs, cs.error),
        focusedErrorBorder: _border(cs, cs.error, width: 1.4),
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
