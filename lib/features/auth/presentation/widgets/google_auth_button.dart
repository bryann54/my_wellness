import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleAuthButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const GoogleAuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
          backgroundColor: theme.colorScheme.surface,
        ),
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              )
            : Image.asset(
                'assets/google.png',
                height: 20,
                width: 20,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.g_mobiledata,
                  size: 24,
                ),
              ),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color:
                theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
