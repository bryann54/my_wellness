import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/shimmer.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/home/domain/entities/dashboard_session.dart';
import 'package:my_wellness/features/home/presentation/bloc/home_bloc.dart';

class AssessmentProgressCard extends StatelessWidget {
  const AssessmentProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {
        if (homeState.sessions.isEmpty &&
            (homeState.status == HomeDashboardStatus.initial ||
                homeState.status == HomeDashboardStatus.loading)) {
          return const _AssessmentProgressShimmer();
        }

        if (homeState.sessions.isEmpty &&
            homeState.status != HomeDashboardStatus.error) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.getString(
                      context,
                      'homeDashboard.screeningActivity',
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () =>
                      context.router.push(const AssessmentsListRoute()),
                  icon: Icon(
                      Platform.isAndroid
                          ? Icons.arrow_forward
                          : Icons.arrow_forward_ios,
                      size: 16,
                      color: colors.primary,
                    ),
                  iconAlignment: IconAlignment.end,
                  label: Text(
                    AppLocalizations.getString(context, 'homeDashboard.seeAll'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            if (homeState.sessions.isEmpty)
              _DashboardError(
                onRetry: () => context.read<HomeBloc>().add(
                  const LoadHomeDashboardEvent(),
                ),
              )
            else
              BlocBuilder<AssessmentsBloc, AssessmentsState>(
                builder: (context, assessmentState) => _SessionList(
                  sessions: homeState.sessions.take(2).toList(),
                  assessments: assessmentState.assessments,
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }
}

class _AssessmentProgressShimmer extends StatelessWidget {
  const _AssessmentProgressShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = colors.onPrimary.withValues(alpha: 0.18);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.getString(
                    context,
                    'homeDashboard.screeningActivity',
                  ),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    context.router.push(const AssessmentsListRoute()),
                icon: const Icon(Icons.arrow_forward_rounded),
                iconAlignment: IconAlignment.end,
                label: Text(
                  AppLocalizations.getString(context, 'homeDashboard.seeAll'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Shimmer(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: AppRadius.lgAll,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: placeholder, width: 5),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PlaceholderBlock(
                              width: 150,
                              height: 18,
                              color: placeholder,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _PlaceholderBlock(
                              width: 110,
                              height: 14,
                              color: placeholder,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PlaceholderBlock(
                    width: double.infinity,
                    height: 44,
                    radius: AppRadius.md,
                    color: colors.onPrimary.withValues(alpha: 0.22),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderBlock extends StatelessWidget {
  const _PlaceholderBlock({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 6,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.sessions, required this.assessments});

  final List<DashboardSession> sessions;
  final List<AssessmentSummary> assessments;

  @override
  Widget build(BuildContext context) {
    final featured = sessions
        .where((s) => s.status == DashboardSessionStatus.inProgress)
        .firstOrNull;
    final rest = sessions.where((s) => s != featured).toList();

    return Column(
      children: [
        if (featured != null)
          _FeaturedSession(
            session: featured,
            title: _titleFor(featured, assessments),
          ),
        for (var i = 0; i < rest.length; i++) ...[
          if (featured != null || i > 0) const SizedBox(height: AppSpacing.sm),
          _SessionRow(session: rest[i], title: _titleFor(rest[i], assessments)),
        ],
      ],
    );
  }
}

class _FeaturedSession extends StatelessWidget {
  const _FeaturedSession({required this.session, required this.title});

  final DashboardSession session;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final notStarted = session.completionPercent == 0;
    final fg = colors.onPrimary;

    final subtitle = notStarted
        ? AppLocalizations.getString(context, 'homeDashboard.notStarted')
        : AppLocalizations.t(context, 'homeDashboard.questionsAnswered', {
            'current': '${session.currentIndex}',
            'total': '${session.totalQuestions}',
          });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProgressRing(percent: session.completionPercent, color: fg),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: fg.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: fg,
              foregroundColor: colors.primary,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _resume(context, session),
            icon:   Icon(
              Platform.isAndroid
                  ? Icons.arrow_forward
                  : Icons.arrow_forward_ios,
              size: 16,
              color: colors.primary,
            ),
            iconAlignment: IconAlignment.end,
            label: Text(
              AppLocalizations.getString(
                context,
                notStarted
                    ? 'homeDashboard.startScreening'
                    : 'homeDashboard.continueScreening',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.percent, required this.color});

  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.t(context, 'homeDashboard.progressPercent', {
        'percent': '$percent',
      }),
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: percent / 100),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => SizedBox.square(
            dimension: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session, required this.title});

  final DashboardSession session;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isPending = session.status == DashboardSessionStatus.pending;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: isPending ? null : () => _resume(context, session),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    isPending
                        ? AppLocalizations.getString(
                            context,
                            'homeDashboard.pending',
                          )
                        : '${session.completionPercent}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  if (!isPending)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    ),
                ],
              ),
              if (!isPending) ...[
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: session.completionPercent / 100,
                    minHeight: 4,
                    backgroundColor: colors.primary.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.getString(
              context,
              'homeDashboard.dashboardUnavailable',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(AppLocalizations.getString(context, 'common.retry')),
          ),
        ],
      ),
    );
  }
}

void _resume(BuildContext context, DashboardSession session) {
  context.read<AssessmentsBloc>().add(
    ResumeAssessmentsEvent(
      slug: session.assessmentSlug,
      sessionId: session.id,
      currentIndex: session.currentIndex,
      totalQuestions: session.totalQuestions,
      completionPercent: session.completionPercent,
    ),
  );
  context.router.push(AssessmentSessionRoute(slug: session.assessmentSlug));
}

String _titleFor(
  DashboardSession session,
  List<AssessmentSummary> availableAssessments,
) {
  for (final assessment in availableAssessments) {
    if (assessment.slug == session.assessmentSlug) {
      return assessment.shortTitle;
    }
  }
  return session.assessmentSlug
      .replaceAll(RegExp(r'[-_]'), ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
