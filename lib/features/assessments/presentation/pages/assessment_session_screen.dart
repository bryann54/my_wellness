import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_question.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/pages/assessment_terminated_screen.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_bmi_step.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_progress_bar.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_question_view.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_toast_listener.dart';

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

    if (state.status == AssessmentStatus.completed) {
      _scheduleCompleteRedirect();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (session == null || def == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
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
                child: q.type == AssessmentQuestionType.bmi
                    ? AssessmentBmiStep(
                        submitting: state.status == AssessmentStatus.submitting,
                        onContinue: _submitBmi,
                      )
                    : AssessmentQuestionView(
                        key: ValueKey(q.key),
                        question: q,
                        initialValue: _pendingAnswer,
                        onChanged: (v) => setState(() => _pendingAnswer = v),
                      ),
              ),
            ),
            _buildBottomBar(context, q),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AssessmentQuestion q) {
    final cs = Theme.of(context).colorScheme;
    final submitting = context.select<AssessmentsBloc, bool>(
      (b) => b.state.status == AssessmentStatus.submitting,
    );

    if (q.type == AssessmentQuestionType.bmi) {
      return const SizedBox.shrink();
    }

    final canProceed = _pendingAnswer != null && _pendingAnswer!.isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.chevron_left, size: 18),
            label: Text(
              AppLocalizations.getString(context, 'common.back'),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
              foregroundColor: cs.onSurface,
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: (canProceed && !submitting) ? _submitAnswer : null,
            iconAlignment: IconAlignment.end,
            icon: submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.chevron_right, size: 18),
            label: Text(
              AppLocalizations.getString(context, 'common.next'),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
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

  void _submitBmi() {
    context.read<AssessmentsBloc>().add(const FetchScoreEvent());
  }
}
