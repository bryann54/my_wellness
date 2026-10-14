import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_wellness/common/res/app_spacing.dart';

class QuickActionPill extends StatelessWidget {
  const QuickActionPill({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final PageRouteInfo route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: () {
            HapticFeedback.selectionClick();
            AutoRouter.of(context).push(route);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 4,
              vertical: AppSpacing.sm + 4,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: colors.primary),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
