import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionTile extends StatelessWidget {
  /// Accepts either an [IconData] (Material) or an [FaIconData] (Font Awesome).
  final Object? icon;

  final String label;
  final VoidCallback onTap;
  final bool disabled;
  final bool wide;

  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.disabled = false,
    this.wide = false,
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
    final cs = Theme.of(context).colorScheme;
    final contentColor = disabled
        ? cs.onSurface.withValues(alpha: 0.3)
        : cs.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: wide ? 20 : 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: disabled
                  ? cs.outlineVariant.withValues(alpha: 0.2)
                  : cs.primary.withValues(alpha: 0.2),
            ),
            color: disabled
                ? cs.surface.withValues(alpha: 0.5)
                : cs.primary.withValues(alpha: 0.03),
          ),
          child: wide ? _buildWide(contentColor) : _buildSquare(contentColor),
        ),
      ),
    );
  }

  Widget _buildWide(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcon(color, size: 14) ?? const SizedBox.shrink(),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.syne(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSquare(Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(color) ?? const SizedBox.shrink(),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
