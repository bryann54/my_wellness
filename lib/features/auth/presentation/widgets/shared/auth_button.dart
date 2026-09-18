// lib/features/auth/presentation/widgets/auth_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;
  final String heroTag;
  final Color? color;
  const AuthButton({
    super.key,
    required this.text,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
    required this.heroTag,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canTap = isEnabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Hero(
        tag: heroTag,
        child: ElevatedButton(
          onPressed: canTap
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? cs.primary,
            foregroundColor: color ?? cs.onPrimary,
            disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.12),
            disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                )
              : Text(
                  text,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
