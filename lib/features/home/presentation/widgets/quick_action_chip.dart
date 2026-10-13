import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_wellness/common/res/colors.dart';

class QuickActionChip extends StatelessWidget {
  static const labelGap = 8.0;
  static const verticalPadding = 4.0;

  final IconData icon;
  final String label;
  final PageRouteInfo route;
  final double width;

  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
    required this.width,
  }) : assert(width > 0);

  static double iconDiameterForWidth(double width) =>
      math.min(width, math.min(56.0, math.max(32.0, width - 8))).toDouble();

  static double preferredHeight(BuildContext context, double width) {
    final style = Theme.of(context).textTheme.labelMedium;
    final fontSize = style?.fontSize ?? 12;
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
    final diameter = iconDiameterForWidth(width);
    final iconSize = diameter * 0.42;

    return Semantics(
      button: true,
      label: label,
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
                          shape: BoxShape.circle,
                          color: AppColors.background.withValues(alpha: 0.14),
                          border: Border.all(
                            color: AppColors.background.withValues(alpha: 0.22),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            size: iconSize,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                      const SizedBox(height: labelGap),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              height: 1.15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                              color: AppColors.background.withValues(
                                alpha: 0.92,
                              ),
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
