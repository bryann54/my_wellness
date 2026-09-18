// lib/features/home/presentation/widgets/menu_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuCard extends StatelessWidget {
  /// Accepts either an [IconData] (Material) or an [FaIconData] (Font Awesome).
  final Object? icon;

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

  /// Renders Material and Font Awesome icons uniformly.
  Widget? _buildIcon(Color color, {double size = 25}) {
    final icon = this.icon;
    if (icon == null) return null;

    if (icon is FaIconData) {
      return FaIcon(icon, size: size, color: color);
    }
    if (icon is IconData) {
      return Icon(icon, size: size, color: color);
    }
    assert(false, 'Unsupported icon type: ${icon.runtimeType}');
    return null;
  }

  /// Shifts the hue-based tint to work on both light and dark backgrounds.
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = cardColor != null
        ? _resolvedBg(cardColor!, isDark)
        : cs.surfaceContainerLow;

    final iconColor = cardColor != null
        ? _resolvedIcon(cardColor!, isDark)
        : cs.primary;

    final iconBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.6);

    final iconWidget = _buildIcon(iconColor);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: iconWidget ?? const SizedBox.shrink()),
                  )
                  .animate(delay: 800.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.8, end: 0, curve: Curves.easeOut),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        )
                        .animate(delay: 600.ms)
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: 0.8, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 2),
                    Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.55),
                          ),
                        )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: 0.8, end: 0, curve: Curves.easeOut),
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
