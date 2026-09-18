// lib/features/account/presentation/widgets/menu_item_tile.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.onSurface;
    final effectiveTitleColor = titleColor ?? theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            _buildIcon(effectiveIconColor),
            const SizedBox(width: 16),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildTitleSection(ThemeData theme, Color titleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: titleColor.withValues(alpha: 0.8),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChevron(ThemeData theme) {
    if (onTap == null) return const SizedBox.shrink();

    return Icon(
      Icons.chevron_right,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      size: 20,
    );
  }
}
