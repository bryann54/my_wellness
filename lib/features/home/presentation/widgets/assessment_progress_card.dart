import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/home/domain/entities/dashboard_session.dart';
import 'package:my_wellness/features/home/presentation/bloc/home_bloc.dart';

class AssessmentProgressCard extends StatelessWidget {
  const AssessmentProgressCard({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
    builder: (context, homeState) {
      if (homeState.sessions.isEmpty &&
          homeState.status != HomeDashboardStatus.error) {
        return const SizedBox.shrink();
      }

      final colors = Theme.of(context).colorScheme;
      final visibleSessions = homeState.sessions.take(2).toList();
      final seeAllKey = 'homeDashboard.seeAll';
      final seeAllLabel = AppLocalizations.getString(context, seeAllKey);
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Material(
          color: colors.surfaceContainerLow,
          borderRadius: AppRadius.mdAll,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: colors.outlineVariant),
            ),
            child: homeState.sessions.isEmpty
                ? _DashboardError(
                    onRetry: () {
                      context.read<HomeBloc>().add(
                        const LoadHomeDashboardEvent(),
                      );
                    },
                  )
                : BlocBuilder<AssessmentsBloc, AssessmentsState>(
                    builder: (context, assessmentState) => Column(
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
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.router.push(
                                const AssessmentsListRoute(),
                              ),
                              child: Text(
                                seeAllLabel == seeAllKey
                                    ? 'See all'
                                    : seeAllLabel,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (
                          var index = 0;
                          index < visibleSessions.length;
                          index++
                        ) ...[
                          if (index > 0) const Divider(height: AppSpacing.lg),
                          _SessionItem(
                            session: visibleSessions[index],
                            title: _titleFor(
                              visibleSessions[index],
                              assessmentState.assessments,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      );
    },
  );

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
}

class _SessionItem extends StatelessWidget {
  const _SessionItem({required this.session, required this.title});

  final DashboardSession session;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPending = session.status == DashboardSessionStatus.pending;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppLocalizations.getString(
                context,
                isPending
                    ? 'homeDashboard.pending'
                    : 'homeDashboard.inProgress',
              ),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (!isPending) ...[
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: AppLocalizations.t(
              context,
              'homeDashboard.progressPercent',
              {'percent': '${session.completionPercent}'},
            ),
            child: LinearProgressIndicator(
              value: session.completionPercent / 100,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppPrimaryButton(
            onPressed: () {
              context.read<AssessmentsBloc>().add(
                ResumeAssessmentsEvent(
                  slug: session.assessmentSlug,
                  sessionId: session.id,
                  currentIndex: session.currentIndex,
                  totalQuestions: session.totalQuestions,
                  completionPercent: session.completionPercent,
                ),
              );
              context.router.push(
                AssessmentSessionRoute(slug: session.assessmentSlug),
              );
            },
            label: AppLocalizations.getString(
              context,
              'homeDashboard.continueScreening',
            ),
            icon: Icons.arrow_forward_rounded,
            height: 44,
          ),
        ],
      ],
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        AppLocalizations.getString(
          context,
          'homeDashboard.dashboardUnavailable',
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      AppPrimaryButton(
        onPressed: onRetry,
        label: AppLocalizations.getString(context, 'common.retry'),
        height: 44,
      ),
    ],
  );
}
