import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/shimmer.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_card.dart';
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
                  child: Hero(
                    tag: HeroTags.homeScreeningActivity,
                    child: Material(
                      color: Colors.transparent,
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
                  sessions: homeState.sessions,
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
                child: Hero(
                  tag: HeroTags.homeScreeningActivity,
                  child: Material(
                    color: Colors.transparent,
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
  static const _pinnedSlugs = ['ebola-screening'];

  @override
  Widget build(BuildContext context) {
    final sorted =
        sessions
            .where(
              (session) =>
                  session.status == DashboardSessionStatus.inProgress &&
                  !_isWellbeingSession(session, assessments),
            )
            .toList()
          ..sort((a, b) {
            final ai = _pinnedSlugs.indexOf(a.assessmentSlug);
            final bi = _pinnedSlugs.indexOf(b.assessmentSlug);
            if (ai != -1 && bi != -1) return ai.compareTo(bi);
            if (ai != -1) return -1;
            if (bi != -1) return 1;
            final aInProgress = a.status == DashboardSessionStatus.inProgress;
            final bInProgress = b.status == DashboardSessionStatus.inProgress;
            if (aInProgress != bInProgress) return aInProgress ? -1 : 1;
            return a.assessmentSlug.compareTo(b.assessmentSlug);
          });

    final items = sorted.take(4).toList(growable: false);
    if (items.isEmpty) return const SizedBox.shrink();
    return _SessionCarousel(sessions: items, assessments: assessments);
  }
}

bool _isWellbeingSession(
  DashboardSession session,
  List<AssessmentSummary> assessments,
) {
  final summary = assessments.where((a) => a.slug == session.assessmentSlug);
  final title = summary.isEmpty ? '' : summary.first.shortTitle;
  final searchable = '${session.assessmentSlug} $title'.toLowerCase();
  return searchable.contains('wellbeing') || searchable.contains('well-being');
}

class _SessionCarousel extends StatefulWidget {
  const _SessionCarousel({required this.sessions, required this.assessments});

  final List<DashboardSession> sessions;
  final List<AssessmentSummary> assessments;

  @override
  State<_SessionCarousel> createState() => _SessionCarouselState();
}

class _SessionCarouselState extends State<_SessionCarousel> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.94);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 202,
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.sessions.length,
          onPageChanged: (index) => setState(() => _index = index),
          itemBuilder: (context, index) {
            final session = widget.sessions[index];
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _FeaturedSession(
                session: session,
                title: _titleFor(session, widget.assessments),
              ),
            );
          },
        ),
      ),
      if (widget.sessions.length > 1) ...[
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.sessions.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
          ],
        ),
      ],
    ],
  );
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
                    Hero(
                      tag: assessmentTitleTag(session.assessmentSlug),
                      flightShuttleBuilder: textShuttleBuilder,
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
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
            onPressed: () => _openSession(context, session),
            icon: Icon(
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

void _openSession(BuildContext context, DashboardSession session) {
  if (session.completionPercent == 0) {
    context.router.push(AssessmentIntroRoute(slug: session.assessmentSlug));
    return;
  }

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
