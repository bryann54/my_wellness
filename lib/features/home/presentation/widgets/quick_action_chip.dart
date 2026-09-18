import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionChip extends StatelessWidget {
  /// Accepts either an [IconData] (Material) or an [FaIconData] (Font Awesome).
  final Object? icon;

  final String label;
  final PageRouteInfo route;

  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
  });

  /// Renders Material and Font Awesome icons uniformly.
  Widget? _buildIcon(Color color, {double size = 20}) {
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

  @override
  Widget build(BuildContext context) {
    final iconWidget = _buildIcon(Colors.white);

    return GestureDetector(
      onTap: () => AutoRouter.of(context).push(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: Center(
              child: (iconWidget ?? const SizedBox.shrink())
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.8, end: 0, curve: Curves.easeOut),
            ),
          ),
          const SizedBox(height: 6),
          Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
              .animate(delay: 300.ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.8, end: 0, curve: Curves.easeOut),
        ],
      ),
    );
  }
}
