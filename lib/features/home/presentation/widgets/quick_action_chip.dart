import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickActionChip extends StatelessWidget {
  static const labelGap = 8.0;
  static const verticalPadding = 4.0;

  final IconData icon;
  final String label;
  final PageRouteInfo route;
  final double width;
  final String heroTag;

  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
    required this.width,
    required this.heroTag,
  }) : assert(width > 0);

  static double iconDiameterForWidth(double width) =>
      math.min(width, math.min(56.0, math.max(32.0, width - 8))).toDouble();

  static double preferredHeight(BuildContext context, double width) {
    final fontSize = Theme.of(context).textTheme.labelMedium?.fontSize ?? 12;
    final labelHeight = MediaQuery.textScalerOf(context).scale(fontSize) * 1.15;
    final height =
        iconDiameterForWidth(width) +
        labelGap +
        labelHeight +
        verticalPadding * 2;
    return math.max(48.0, height).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final diameter = iconDiameterForWidth(width);
    final iconSize = diameter * 0.46;
    final displayLabel = label.isEmpty
        ? label
        : '${label[0].toUpperCase()}${label.substring(1)}';

    return Semantics(
      button: true,
      label: displayLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          width: width,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                HapticFeedback.selectionClick();
                AutoRouter.of(context).push(route);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Ink(
                        width: diameter,
                        height: diameter,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(diameter * 0.34),
                          color: colors.primary.withValues(alpha: 0.14),
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            size: iconSize,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: labelGap),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Hero(
                          tag: heroTag,
                          flightShuttleBuilder: (_, __, ___, ____, toHero) =>
                              (toHero.widget as Hero).child,
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              displayLabel,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    height: 1.15,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.1,
                                    color: colors.onSurface,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
