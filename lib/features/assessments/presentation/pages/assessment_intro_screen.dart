import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_toast_listener.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/cancer/cancer_pre_screening_gate.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/intro/before_you_begin.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/intro/encouraging_fact_screen.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/intro/plain_intro_card.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_intro_skeleton.dart';

@RoutePage()
class AssessmentIntroScreen extends StatelessWidget {
  final String slug;
  final String? sessionId;

  const AssessmentIntroScreen({super.key, required this.slug, this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AssessmentsBloc>(),
      child: AssessmentToastListener(
        child: _AssessmentIntroBody(slug: slug, sessionId: sessionId),
      ),
    );
  }
}

class _AssessmentIntroBody extends StatefulWidget {
  final String slug;
  final String? sessionId;

  const _AssessmentIntroBody({required this.slug, this.sessionId});

  @override
  State<_AssessmentIntroBody> createState() => _AssessmentIntroBodyState();
}

class _AssessmentIntroBodyState extends State<_AssessmentIntroBody> {
  bool _navigatedToComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<AssessmentsBloc>();
      if (widget.sessionId != null) {
        bloc.add(
          ResumeAssessmentsEvent(
            slug: widget.slug,
            sessionId: widget.sessionId!,
          ),
        );
      } else {
        bloc.add(StartAssessmentsEvent(widget.slug));
      }
    });
  }

  void _scheduleCompleteRedirect() {
    if (_navigatedToComplete) return;
    _navigatedToComplete = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.router.replace(AssessmentCompleteRoute(slug: widget.slug));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AssessmentsBloc>().state;
    final def = state.definition;

    // Completed session — skip the intro entirely.
    if (state.session?.status == AssessmentSessionStatus.completed ||
        state.status == AssessmentStatus.completed) {
      _scheduleCompleteRedirect();
      return const Scaffold(body: SizedBox.shrink());
    }

    if (def == null ||
        state.status == AssessmentStatus.loading ||
        state.status == AssessmentStatus.initial) {
      return const Scaffold(body: SafeArea(child: AssessmentIntroSkeleton()));
    }

    if (state.status == AssessmentStatus.error) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              state.errorMessage ??
                  AppLocalizations.getString(context, 'assessment.loadFailed'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final session = state.session;

    // 1. Pre-screening gate.
    if (session != null &&
        session.status == AssessmentSessionStatus.needsPreScreening) {
      return CancerPreScreeningGate(
        slug: widget.slug,
        shortTitle: def.shortTitle,
        tagline: def.tagline,
      );
    }

    final showPlainIntro =
        session != null &&
        (session.status == AssessmentSessionStatus.awaitingPayment ||
            session.status == AssessmentSessionStatus.awaitingCall);

    if (showPlainIntro) {
      return PlainIntroCard(
        slug: widget.slug,
        session: session,
        definition: def,
        canStart: state.canStart,
      );
    }

    if (def.beforeYouBegin.isNotEmpty) {
      return BeforeYouBeginPages(
        slug: widget.slug,
        pages: def.beforeYouBegin,
        shortTitle: def.shortTitle,
        onCompleted: () => _goToQuestions(context),
      );
    }

    if (def.encouragingFact != null && def.isCancer) {
      return EncouragingFactScreen(
        slug: widget.slug,
        fact: def.encouragingFact!,
        shortTitle: def.shortTitle,
        onContinue: () => _goToQuestions(context),
      );
    }

    // 6. Session ready to answer — straight to the questions.
    if (session?.status == AssessmentSessionStatus.inProgress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.router.replace(AssessmentSessionRoute(slug: widget.slug));
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    // Fallback — nothing to render.
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.getString(context, 'assessment.loadFailed'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppPrimaryButton(
                onPressed: () => context.router.maybePop(),
                label: AppLocalizations.getString(context, 'common.back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToQuestions(BuildContext context) {
    context.router.replace(AssessmentSessionRoute(slug: widget.slug));
  }
}
