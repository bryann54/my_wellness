import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/offline_sync/presentation/bloc/sync_bloc.dart';

class SyncBanner extends StatelessWidget {
  final Widget child;
  final bool showBanner;

  const SyncBanner({super.key, required this.child, this.showBanner = true});

  @override
  Widget build(BuildContext context) {
    if (!showBanner) return child;

    return BlocBuilder<SyncBloc, SyncState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.pendingCount != current.pendingCount,
      builder: (context, state) {
        final visible =
            state.status != SyncStatus.idle || state.pendingCount > 0;
        if (!visible) return child;

        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final (background, foreground, message, icon) = switch (state.status) {
          SyncStatus.offline => (
            colors.surfaceContainerHighest,
            colors.onSurfaceVariant,
            AppLocalizations.getString(context, 'offline.youAreOffline'),
            Icons.cloud_off_rounded,
          ),
          SyncStatus.restored => (
            const Color(0xFFE7F5EC),
            const Color(0xFF176B3A),
            AppLocalizations.getString(context, 'offline.connectionRestored'),
            Icons.cloud_done_rounded,
          ),
          SyncStatus.syncing => (
            colors.primaryContainer,
            colors.onPrimaryContainer,
            AppLocalizations.t(context, 'offline.syncing', {
              'count': '${state.pendingCount}',
            }),
            Icons.sync_rounded,
          ),
          SyncStatus.error => (
            colors.errorContainer,
            colors.onErrorContainer,
            AppLocalizations.getString(context, 'offline.syncFailed'),
            Icons.error_outline_rounded,
          ),
          SyncStatus.idle => (
            colors.surfaceContainerHighest,
            colors.onSurfaceVariant,
            AppLocalizations.t(context, 'offline.pendingSync', {
              'count': '${state.pendingCount}',
            }),
            Icons.cloud_queue_rounded,
          ),
        };

        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      widthFactor: 0.76,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Material(
                          elevation: 8,
                          color: background,
                          shadowColor: Colors.black.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 18, color: foreground),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    message,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: foreground,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                if (state.status == SyncStatus.error) ...[
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => context
                                        .read<SyncBloc>()
                                        .add(const TriggerSyncEvent()),
                                    style: TextButton.styleFrom(
                                      foregroundColor: foreground,
                                      minimumSize: const Size(0, 32),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      AppLocalizations.getString(
                                        context,
                                        'common.retry',
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
