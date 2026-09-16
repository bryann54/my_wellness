import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Divider(
              thickness: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              endIndent: 12,
            ),
          ),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ).animate(delay: 800.ms).fadeIn(duration: 600.ms),
          Expanded(
            child: Divider(
              thickness: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              indent: 12,
            ),
          ),
        ],
      ),
    );
  }
}
