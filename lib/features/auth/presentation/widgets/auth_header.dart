import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/constatnts/hero.dart';
import 'package:my_wellness/common/res/colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogo;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLogo) ...[
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: Hero(
              // Same tag as the splash logo -> hero animates splash -> auth.
              tag: hero_logo,
              child: Image.asset(
                'assets/wellness-logo.png',
                width: 140,
                height: 140,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.favorite,
                  size: 96,
                  color: colorPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOutQuad).slideY(
              begin: 0.2,
              end: 0,
              duration: 600.ms,
              curve: Curves.easeOutQuad,
            ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: theme.brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.2, end: 0, duration: 600.ms),
      ],
    );
  }
}
