import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_empty_state.dart';

@RoutePage()
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          final statusLabel = switch (state.status) {
            NotificationsStatus.idle => 'Not set up yet',
            NotificationsStatus.syncing => 'Setting up…',
            NotificationsStatus.connected => 'Notifications are on',
            NotificationsStatus.permissionDenied =>
              'Notifications are disabled in system settings',
            NotificationsStatus.notConfigured =>
              'Notifications are not available in this build',
            NotificationsStatus.error =>
              state.message ?? 'Something went wrong',
          };

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
                child: VitalsEmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: AppLocalizations.getString(
                    context,
                    'notifications.emptyTitle',
                  ),
                  subtitle: statusLabel,
                  ctaLabel: state.status == NotificationsStatus.permissionDenied
                      ? 'Enable notifications'
                      : null,
                  onCta: state.status == NotificationsStatus.permissionDenied
                      ? () => context.read<NotificationsBloc>().add(
                          const RequestPermissionEvent(),
                        )
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
