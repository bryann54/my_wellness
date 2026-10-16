import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';

class MenuItemTile extends StatelessWidget {
  const MenuItemTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final effectiveIconColor = iconColor ?? cs.onSurface;
    final effectiveTitleColor = titleColor ?? cs.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            _buildIcon(effectiveIconColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _buildTitleSection(theme, effectiveTitleColor)),
            if (trailing != null) trailing! else _buildChevron(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.smAll,
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildTitleSection(ThemeData theme, Color titleColor) {
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: titleColor.withValues(alpha: 0.9),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChevron(ThemeData theme) {
    if (onTap == null) return const SizedBox.shrink();
    return Icon(
      Icons.chevron_right_rounded,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      size: 20,
    );
  }
}
