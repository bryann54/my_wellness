import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/notifications/data/notification_service.dart';
import 'package:my_wellness/features/notifications/presentation/bloc/notifications_bloc.dart';

class NotificationPermissionSheet extends StatelessWidget {
  const NotificationPermissionSheet({super.key});

  static Future<void> show(BuildContext context) {
    // Make sure what we show reflects the system right now.
    context.read<NotificationsBloc>().add(const RefreshPermissionEvent());

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<NotificationsBloc>(),
        child: const NotificationPermissionSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocBuilder<NotificationsBloc, NotificationsState>(
      buildWhen: (p, c) =>
          p.permission != c.permission ||
          p.pushOptedIn != c.pushOptedIn ||
          p.isUpdating != c.isUpdating ||
          p.status != c.status,
      builder: (context, state) {
        final bloc = context.read<NotificationsBloc>();
        final configured = state.status != NotificationsStatus.notConfigured;
        final blocked = state.permission == NotificationPermission.denied;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppLocalizations.getString(
                    context,
                    'settings.alertPreferences',
                  ),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: SwitchListTile.adaptive(
                    value: state.pushEnabled,
                    onChanged: (!configured || state.isUpdating)
                        ? null
                        : (v) => bloc.add(SetPushEnabledEvent(v)),
                    secondary: Icon(
                      state.pushEnabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_outlined,
                      color: state.pushEnabled
                          ? cs.primary
                          : cs.onSurfaceVariant,
                    ),
                    title: Text(
                      AppLocalizations.getString(
                        context,
                        'notifications.pushToggleTitle',
                      ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.getString(
                        context,
                        'notifications.pushToggleSub',
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                  ),
                ),
                if (blocked) ...[
                  const SizedBox(height: AppSpacing.md),
                  _BlockedCallout(
                    onOpenSettings: () => bloc.add(
                      // Already denied → this opens system settings.
                      const SetPushEnabledEvent(true),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(
                    AppLocalizations.getString(context, 'common.close'),
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BlockedCallout extends StatelessWidget {
  const _BlockedCallout({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.35),
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.getString(context, 'notifications.blockedTitle'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppLocalizations.getString(context, 'notifications.blockedBody'),
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.45,
              color: cs.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonal(
              onPressed: onOpenSettings,
              child: Text(
                AppLocalizations.getString(
                  context,
                  'notifications.openSystemSettings',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
