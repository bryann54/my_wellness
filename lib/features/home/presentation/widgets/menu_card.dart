import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/colors.dart';

class MenuCard extends StatelessWidget {
  final IconData? icon;

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? cardColor;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.cardColor,
  });

  Widget? _buildIcon(Color color, {double size = 25}) {
    final icon = this.icon;
    if (icon == null) return null;
    return Icon(icon, size: size, color: color);
  }

  Color _resolvedBg(Color base, bool isDark) {
    final hsl = HSLColor.fromColor(base);
    return isDark
        ? hsl
              .withSaturation((hsl.saturation * 0.5).clamp(0.0, 1.0))
              .withLightness(0.18)
              .toColor()
        : base;
  }

  Color _resolvedIcon(Color base, bool isDark) {
    final hsl = HSLColor.fromColor(base);
    return isDark
        ? hsl
              .withSaturation((hsl.saturation * 0.8).clamp(0.0, 1.0))
              .withLightness(0.65)
              .toColor()
        : hsl.withSaturation(0.6).withLightness(0.35).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = cardColor != null
        ? _resolvedBg(cardColor!, isDark)
        : cs.surfaceContainerLow;

    final iconColor = cardColor != null
        ? _resolvedIcon(cardColor!, isDark)
        : cs.primary;

    final iconBg = isDark
        ? AppColors.background.withValues(alpha: 0.08)
        : AppColors.background.withValues(alpha: 0.6);

    return Material(
      color: bgColor,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _buildIcon(iconColor) ?? const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: cs.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
