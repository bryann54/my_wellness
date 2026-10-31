import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/notifications/domain/entities/notification_preference.dart';
import 'package:my_wellness/features/notifications/data/notification_service.dart';
import 'package:my_wellness/features/notifications/presentation/bloc/notifications_bloc.dart';

class NotificationPermissionSheet extends StatelessWidget {
  const NotificationPermissionSheet({super.key});

  static Future<void> show(BuildContext context) {
    // Make sure what we show reflects the system right now.
    context.read<NotificationsBloc>().add(const RefreshPermissionEvent());
    context.read<NotificationsBloc>().add(
      const LoadNotificationPreferencesEvent(),
    );

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
          p.status != c.status ||
          p.preferences != c.preferences ||
          p.savedPreferences != c.savedPreferences ||
          p.preferencesLoading != c.preferencesLoading ||
          p.savingPreferences != c.savingPreferences ||
          p.preferencesSaved != c.preferencesSaved ||
          p.preferencesError != c.preferencesError,
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.82,
              ),
              child: SingleChildScrollView(
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
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Choose how you want to hear about each type of reminder.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (state.preferencesLoading)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else if (state.preferencesError != null &&
                        state.preferences.isEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.preferencesError!,
                            style: TextStyle(color: cs.error),
                          ),
                          TextButton(
                            onPressed: () => bloc.add(
                              const LoadNotificationPreferencesEvent(),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      )
                    else
                      for (final preference in state.preferences)
                        _PreferenceCard(
                          preference: preference,
                          onChannelChanged: (channel, enabled) => bloc.add(
                            SetNotificationPreferenceChannelEvent(
                              category: preference.category,
                              channel: channel,
                              enabled: enabled,
                            ),
                          ),
                        ),
                    if (state.preferencesError != null &&
                        state.preferences.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          state.preferencesError!,
                          style: TextStyle(color: cs.error),
                        ),
                      ),
                    if (state.preferencesSaved)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          'Notification choices saved.',
                          style: TextStyle(color: cs.primary),
                        ),
                      ),
                    if (state.preferences.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppPrimaryButton(
                        onPressed:
                            !state.savingPreferences && _preferencesDirty(state)
                            ? () {
                                bloc.add(
                                  const SaveNotificationPreferencesEvent(),
                                );
                              }
                            : null,
                        label: 'Save choices',
                        isLoading: state.savingPreferences,
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
            ),
          ),
        );
      },
    );
  }

  static bool _preferencesDirty(NotificationsState state) {
    if (state.preferences.length != state.savedPreferences.length) return true;
    for (var i = 0; i < state.preferences.length; i++) {
      if (state.preferences[i] != state.savedPreferences[i]) return true;
    }
    return false;
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({
    required this.preference,
    required this.onChannelChanged,
  });

  final NotificationPreference preference;
  final void Function(NotificationChannel channel, bool enabled)
  onChannelChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final channels = [
      (NotificationChannel.push, 'Push', preference.push),
      (NotificationChannel.email, 'Email', preference.email),
      (NotificationChannel.sms, 'SMS', preference.sms),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(preference.label, style: theme.textTheme.titleSmall),
            Row(
              children: [
                for (final (channel, label, enabled) in channels)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: enabled,
                          onChanged: _canChange(channel, enabled)
                              ? (value) =>
                                    onChannelChanged(channel, value ?? false)
                              : null,
                          visualDensity: VisualDensity.compact,
                        ),
                        Text(label, style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canChange(NotificationChannel channel, bool enabled) {
    if (!preference.required || !enabled) return true;
    final otherVisibleEnabled = switch (channel) {
      NotificationChannel.push => preference.email || preference.sms,
      NotificationChannel.email => preference.push || preference.sms,
      NotificationChannel.sms => preference.push || preference.email,
    };
    return otherVisibleEnabled || preference.whatsapp;
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
