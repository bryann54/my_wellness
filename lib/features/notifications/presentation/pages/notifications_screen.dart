import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:my_wellness/features/notifications/presentation/notifications_empty_state.dart';

@RoutePage()
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const MarkAllReadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listenWhen: (p, c) => c.unreadCount > p.unreadCount,
      listener: (context, _) =>
          context.read<NotificationsBloc>().add(const MarkAllReadEvent()),
      child: Scaffold(
        body: CustomScrollView(
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
                  onPressed: () => context.router.push(const SettingsRoute()),
                  icon: const Icon(Icons.tune_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<NotificationsBloc, NotificationsState>(
                buildWhen: (p, c) =>
                    p.pushEnabled != c.pushEnabled || p.status != c.status,
                builder: (context, state) {
                  final showBanner =
                      state.status == NotificationsStatus.connected &&
                      !state.pushEnabled;
                  if (!showBanner) return const SizedBox.shrink();
                  return const _PushOffBanner();
                },
              ),
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: NotificationsEmptyState()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PushOffBanner extends StatelessWidget {
  const _PushOffBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_off_outlined, color: cs.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.getString(
                      context,
                      'notifications.pushOffTitle',
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.getString(
                      context,
                      'notifications.pushOffBody',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.router.push(const SettingsRoute()),
              child: Text(
                AppLocalizations.getString(
                  context,
                  'notifications.manageInSettings',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
