// lib/features/auth/presentation/widgets/shared/auth_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  /// Optional hero tag. When null, the logo is rendered without a Hero.
  ///
  /// Do NOT give two simultaneously-mounted screens the same tag —
  /// Flutter will assert "multiple heroes share the same tag".
  final String? heroTag;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final logo = SizedBox(
      width: 100,
      height: 100,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.health_and_safety_rounded,
          size: 64,
          color: theme.colorScheme.primary,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          // Only wrap in Hero when a tag is provided, so we never
          // accidentally fly between two auth screens with the same tag.
          child: heroTag == null ? logo : Hero(tag: heroTag!, child: logo),
        ),

        const SizedBox(height: 16),

        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ).animate().slideY(duration: 800.ms).fadeIn(duration: 800.ms),

        const SizedBox(height: 8),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
