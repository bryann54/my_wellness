import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:my_wellness/features/notifications/presentation/widgets/notification_permission_body.dart';
import 'package:my_wellness/features/notifications/presentation/widgets/notification_permission_sheet.dart';

@RoutePage()
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        buildWhen: (previous, current) =>
            previous.permission != current.permission,
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              CustomAppBar(
                title: AppLocalizations.getString(
                  context,
                  'settings.notifications',
                ),
                isHome: false,
                actions: [
                  IconButton(
                    tooltip: AppLocalizations.getString(
                      context,
                      'notifications.manageTooltip',
                    ),
                    onPressed: () => NotificationPermissionSheet.show(context),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: NotificationPermissionBody(
                        permission: state.permission,
                        onEnable: () {
                          context.read<NotificationsBloc>().add(
                            const RequestPermissionEvent(),
                          );
                        },
                        onManage: () {
                          context.read<NotificationsBloc>().add(
                            const RequestPermissionEvent(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
