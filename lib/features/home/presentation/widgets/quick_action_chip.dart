import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_wellness/common/res/app_spacing.dart';

class QuickActionChip extends StatelessWidget {
  static const _maxDiameter = 64.0;

  final String imageAsset;
  final String label;
  final PageRouteInfo route;
  final String heroTag;
  static const _grayscale = ColorFilter.matrix(<double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);
  final IconData fallbackIcon;

  const QuickActionChip({
    super.key,
    required this.imageAsset,
    required this.label,
    required this.route,
    required this.heroTag,
    this.fallbackIcon = Icons.apps_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final displayLabel = label.isEmpty
        ? label
        : '${label[0].toUpperCase()}${label.substring(1)}';

    return Semantics(
      button: true,
      label: displayLabel,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final diameter = constraints.maxWidth.isFinite
              ? (constraints.maxWidth - AppSpacing.sm).clamp(40.0, _maxDiameter)
              : _maxDiameter;
          final inset = diameter * 0.18;
          final imageSize = diameter - inset * 2;

          // Decode at display size, not source size.
          final cacheSize = (imageSize * MediaQuery.devicePixelRatioOf(context))
              .round();

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                HapticFeedback.selectionClick();
                AutoRouter.of(context).push(route);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: diameter,
                      height: diameter,
                      padding: EdgeInsets.all(inset),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary.withValues(
                          alpha: isDark ? 0.18 : 0.08,
                        ),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.14),
                        ),
                      ),
                      child: ClipOval(
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            colors.primary.withValues(
                              alpha: isDark ? 0.45 : 0.6,
                            ),
                            BlendMode.srcATop,
                          ),
                          child: ColorFiltered(
                            colorFilter: _grayscale,
                            child: Image.asset(
                              imageAsset,
                              cacheWidth: cacheSize,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (_, _, _) => Icon(
                                fallbackIcon,
                                size: imageSize * 0.7,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Hero(
                        tag: heroTag,
                        flightShuttleBuilder: (_, _, _, _, toHero) =>
                            (toHero.widget as Hero).child,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            displayLabel,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium?.copyWith(
                              height: 1.15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                              color: colors.onSurface,
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
        },
      ),
    );
  }
}
