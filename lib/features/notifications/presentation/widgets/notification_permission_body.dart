import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/notifications/data/notification_service.dart';

class NotificationPermissionBody extends StatelessWidget {
  const NotificationPermissionBody({
    super.key,
    required this.permission,
    required this.onEnable,
    required this.onManage,
    this.compact = false,
  });

  final NotificationPermission permission;
  final VoidCallback onEnable;
  final VoidCallback onManage;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final (
      IconData icon,
      String title,
      String subtitle,
      String? ctaLabel,
      VoidCallback? ctaAction,
    ) = switch (permission) {
      NotificationPermission.granted => (
        Icons.notifications_active_rounded,
        AppLocalizations.getString(context, 'notifications.emptyTitle'),
        AppLocalizations.getString(context, 'notifications.emptySubtitle'),
        null,
        null,
      ),
      NotificationPermission.denied => (
        Icons.notifications_off_rounded,
        AppLocalizations.getString(context, 'notifications.offTitle'),
        AppLocalizations.getString(context, 'notifications.offSubtitle'),
        AppLocalizations.getString(context, 'notifications.openSettings'),
        onManage,
      ),
      _ => (
        Icons.notifications_none_rounded,
        AppLocalizations.getString(context, 'notifications.optInTitle'),
        AppLocalizations.getString(context, 'notifications.optInSubtitle'),
        AppLocalizations.getString(context, 'notifications.enable'),
        onEnable,
      ),
    };

    final iconSize = compact ? 56.0 : 72.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: iconSize * 0.46, color: cs.primary),
        ),
        SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: compact ? 18 : 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.65),
            height: 1.5,
          ),
        ),
        if (ctaLabel != null) ...[
          SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: ctaAction, child: Text(ctaLabel)),
          ),
        ],
      ],
    );
  }
}
