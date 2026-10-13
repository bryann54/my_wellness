import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';

class AuthBottomBar extends StatelessWidget {
  const AuthBottomBar({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onActionPressed,
    required this.heroTag,
  });

  final String promptText;
  final String actionText;
  final VoidCallback onActionPressed;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : cs.shadow).withValues(
              alpha: isDark ? 0.35 : 0.04,
            ),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                promptText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Hero(
                tag: heroTag,
                flightShuttleBuilder:
                    (_, __, direction, fromContext, toContext) {
                      return direction == HeroFlightDirection.push
                          ? toContext.widget
                          : fromContext.widget;
                    },
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onActionPressed,
                    borderRadius: AppRadius.smAll,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        actionText,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
