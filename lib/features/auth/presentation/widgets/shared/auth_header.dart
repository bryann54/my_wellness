import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.heroTag,
    this.showLogo = true,
  });

  final String title;
  final String subtitle;
  final String? heroTag;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final logo = SizedBox(
      width: 96,
      height: 96,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.health_and_safety_rounded,
          size: 60,
          color: theme.colorScheme.primary,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showLogo)
          Center(
            child: heroTag == null
                ? logo
                : Hero(
                    tag: heroTag!,
                    flightShuttleBuilder: (_, _, _, _, toHero) => toHero.widget,
                    child: logo,
                  ),
          ),
        if (showLogo) const SizedBox(height: AppSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}
