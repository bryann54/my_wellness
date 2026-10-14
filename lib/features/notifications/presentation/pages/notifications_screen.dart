import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/notifications/data/notification_service.dart';
import 'package:my_wellness/features/notifications/presentation/bloc/notifications_bloc.dart';

@RoutePage()
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              CustomAppBar(
                title: AppLocalizations.getString(
                  context,
                  'settings.notifications',
                ),
                isHome: false,
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: _PermissionBody(state: state),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PermissionBody extends StatelessWidget {
  final NotificationsState state;
  const _PermissionBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Three visible cases. `unknown` is the initial state before OneSignal
    // has reported anything, so it reads as "ask the user".
    final (
      icon,
      title,
      subtitle,
      ctaLabel,
      ctaAction,
    ) = switch (state.permission) {
      NotificationPermission.granted => (
        Icons.notifications_active_rounded,
        'Notifications are on',
        'You will receive alerts for appointments, medications, and '
            'health updates.',
        null,
        null,
      ),
      NotificationPermission.denied => (
        Icons.notifications_off_rounded,
        'Notifications are off',
        'Enable them in system settings to receive alerts about your '
            'appointments and medications.',
        'Open settings',
        () => context.read<NotificationsBloc>().add(
          const RequestPermissionEvent(),
        ),
      ),
      _ => (
        Icons.notifications_none_rounded,
        'Stay in the loop',
        'Enable notifications to receive appointment reminders, '
            'medication alerts, and health updates.',
        'Enable notifications',
        () => context.read<NotificationsBloc>().add(
          const RequestPermissionEvent(),
        ),
      ),
    };

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: HeroTags.homeNotifications,
            child: Icon(icon, size: 64, color: cs.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.65),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (ctaLabel != null) ...[
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: ctaAction, child: Text(ctaLabel)),
            ),
          ],
        ],
      ),
    );
  }
}
