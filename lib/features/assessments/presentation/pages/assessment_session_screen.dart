// lib/features/assessments/presentation/pages/assessment_session_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_question.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/pages/assessment_terminated_screen.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_bmi_step.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_progress_bar.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_question_view.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_session_bottom_bar.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_toast_listener.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';

@RoutePage()
class AssessmentSessionScreen extends StatelessWidget {
  final String slug;

  const AssessmentSessionScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AssessmentsBloc>(),
      child: AssessmentToastListener(child: _AssessmentSessionBody(slug: slug)),
    );
  }
}

class _AssessmentSessionBody extends StatefulWidget {
  final String slug;

  const _AssessmentSessionBody({required this.slug});

  @override
  State<_AssessmentSessionBody> createState() => _AssessmentSessionBodyState();
}

class _AssessmentSessionBodyState extends State<_AssessmentSessionBody> {
  String? _pendingAnswer;
  int _lastIndex = -1;
  bool _navigated = false;

  void _scheduleCompleteRedirect() {
    if (_navigated) return;
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.router.replace(AssessmentCompleteRoute(slug: widget.slug));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AssessmentsBloc>().state;
    final session = state.session;
    final def = state.definition;

    if (state.terminated) {
      return AssessmentTerminatedRouteView(
        reference: state.terminationReference,
      );
    }

    if (state.status == AssessmentStatus.error) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.getString(context, 'assessment.title')),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage ??
                      AppLocalizations.getString(
                        context,
                        'assessment.loadFailed',
                      ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                AppPrimaryButton(
                  onPressed: () => context.router.maybePop(),
                  label: AppLocalizations.getString(context, 'common.back'),
                  height: 48,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.status == AssessmentStatus.completed) {
      _scheduleCompleteRedirect();
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (session == null || def == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (session.currentIndex != _lastIndex) {
      _lastIndex = session.currentIndex;
      _pendingAnswer = null;
    }

    final q = def.questionByIndex(session.currentIndex);
    if (q == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final bloc = context.read<AssessmentsBloc>();
        if (!bloc.state.completionHandled) {
          bloc.add(const FetchScoreEvent());
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final isBmi = q.type == AssessmentQuestionType.bmi;
    final isSubmitting = state.status == AssessmentStatus.submitting;
    final canProceed = _pendingAnswer != null && _pendingAnswer!.isNotEmpty;
    final profile = context.watch<AccountBloc>().state.profile;

    return BlocListener<AssessmentsBloc, AssessmentsState>(
      listenWhen: (previous, current) {
        final previousQuestion = previous.definition?.questionByIndex(
          previous.session?.currentIndex ?? -1,
        );
        return previous.status == AssessmentStatus.submitting &&
            (current.status == AssessmentStatus.ready ||
                current.status == AssessmentStatus.completed) &&
            previousQuestion?.type == AssessmentQuestionType.bmi;
      },
      listener: (context, state) {
        context.read<AccountBloc>().add(const FetchProfileEvent());
      },
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            CustomAppBar(title: def.shortTitle, isHome: false),
          ],
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: AssessmentProgressBar(
                  current: session.currentIndex,
                  total: session.totalQuestions,
                  section: q.section,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: isBmi
                      ? AssessmentBmiStep(
                          initialWeightKg: profile?.weightKg?.toString(),
                          initialHeightCm: profile?.heightCm?.toString(),
                          submitting: isSubmitting,
                        )
                      : AssessmentQuestionView(
                          key: ValueKey(q.key),
                          question: q,
                          initialValue: _pendingAnswer,
                          onChanged: (v) => setState(() => _pendingAnswer = v),
                        ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: isBmi
            ? null
            : AssessmentSessionBottomBar(
                canProceed: canProceed,
                submitting: isSubmitting,
                onBack: () => Navigator.of(context).maybePop(),
                onNext: _submitAnswer,
              ),
      ),
    );
  }

  void _submitAnswer() {
    final state = context.read<AssessmentsBloc>().state;
    final session = state.session;
    final def = state.definition;
    if (session == null || def == null || _pendingAnswer == null) return;

    final q = def.questionByIndex(session.currentIndex);
    if (q == null) return;

    context.read<AssessmentsBloc>().add(
      SubmitAnswerEvent(
        questionKey: q.key,
        questionIndex: q.index,
        answer: _pendingAnswer!,
      ),
    );
  }
}
