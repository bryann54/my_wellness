import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';

class QuickActionChip extends StatefulWidget {
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

  @override
  State<QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<QuickActionChip> {
  bool _pressed = false;

  Widget? _buildIcon(Color color, {double size = 20}) {
    final icon = widget.icon;
    if (icon == null) return null;
    if (icon is FaIconData) return FaIcon(icon, size: size, color: color);
    if (icon is IconData) return Icon(icon, size: size, color: color);
    assert(false, 'Unsupported icon type: ${icon.runtimeType}');
    return null;
  }

  void _onTapDown(_) => setState(() => _pressed = true);
  void _onTapUp(_) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  void _onTap() {
    HapticFeedback.selectionClick();
    AutoRouter.of(context).push(widget.route);
  }

  @override
  Widget build(BuildContext context) {
    final iconWidget = _buildIcon(AppColors.background);

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: SizedBox(
            width: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon tile ─────────────────────────────────────────
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Soft glass surface instead of a flat white blob.
                    color: AppColors.background.withValues(alpha: 0.14),
                    border: Border.all(
                      color: AppColors.background.withValues(alpha: 0.22),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(child: iconWidget ?? const SizedBox.shrink()),
                ),
                const SizedBox(height: 8),
                // ── Label ──────────────────────────────────────────────
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    color: AppColors.background.withValues(alpha: 0.92),
                  ),
                  textAlign: TextAlign.center,
                  // Prefer "Medication" / "My Health" / "Vitals" — one line.
                  // For longer words use a soft ellipsis instead of wrapping.
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
