import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';

class AccountHeader extends StatelessWidget {
  const AccountHeader({
    super.key,
    required this.profile,
    required this.onLogout,
  });

  final HealthProfile profile;
  final VoidCallback onLogout;

  static const _expandedContent = 150.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final topInset = MediaQuery.paddingOf(context).top;
    final expandedHeight = _expandedContent + topInset;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
            color: cs.error,
            tooltip: 'Log out',
          ),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final collapsedHeight = kToolbarHeight + topInset;
          final range = expandedHeight - collapsedHeight;
          final progress = range <= 0
              ? 1.0
              : ((expandedHeight - constraints.biggest.height) / range).clamp(
                  0.0,
                  1.0,
                );

          return FlexibleSpaceBar(
            titlePadding: const EdgeInsetsDirectional.only(
              start: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            title: Opacity(
              opacity: progress,
              child: _buildCollapsedTitle(context),
            ),
            background: _buildExpandedHeader(context),
          );
        },
      ),
    );
  }

  Widget _buildCollapsedTitle(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: cs.primary.withValues(alpha: 0.10),
          child: Text(
            _getInitials(profile),
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profile.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 14,
                  color: cs.onSurface,
                ),
              ),
              Text(
                profile.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedHeader(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      color: cs.surface,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        topInset + AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: cs.primary.withValues(alpha: 0.10),
            child: Text(
              _getInitials(profile),
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 28,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  profile.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.email,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(HealthProfile profile) {
    final name = profile.displayName;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }
}
