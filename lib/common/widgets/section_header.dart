import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionHeader extends StatelessWidget {
  /// Accepts an [IconData].
  final IconData? icon;

  final String label;
  final double fontSize;

  const SectionHeader({
    super.key,
    this.icon,
    required this.label,
    this.fontSize = 14,
  });

  Widget? _buildIcon(Color color, {double size = 14}) {
    final icon = this.icon;
    if (icon == null) return null;
    return Icon(icon, size: size, color: color);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconWidget = _buildIcon(cs.primary);

    return Row(
      children: [
        if (iconWidget != null) ...[
          iconWidget
              .animate(delay: 500.ms)
              .fadeIn(duration: 500.ms)
              .slideX(begin: -0.8, end: 0, curve: Curves.easeOut),
          const SizedBox(width: 5),
        ],
        Text(
              label,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            )
            .animate(delay: 500.ms)
            .fadeIn(duration: 500.ms)
            .slideX(begin: 0.8, end: 0, curve: Curves.easeOut),
      ],
    );
  }
}
