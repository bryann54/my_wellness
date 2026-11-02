import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_question.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/pages/assessment_terminated_screen.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_bmi_step.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_blocked_view.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_intro_skeleton.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_progress_bar.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_question_view.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_card.dart';
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
  Object? _pendingAnswer;
  bool? _priorCancerHistory;
  String? _priorCancerType;
  final TextEditingController _priorCancerYear = TextEditingController();
  int _lastIndex = -1;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _priorCancerYear.addListener(_onYearChanged);
  }

  @override
  void dispose() {
    _priorCancerYear.removeListener(_onYearChanged);
    _priorCancerYear.dispose();
    super.dispose();
  }

  void _onYearChanged() {
    if (mounted) setState(() {});
  }

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

    if (state.block != AssessmentBlockKind.none) {
      return AssessmentBlockedView(
        state: state,
        onResumeBlocking: state.blockingSlug == null
            ? null
            : () => context.router.push(
                AssessmentIntroRoute(slug: state.blockingSlug!),
              ),
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
                  AppLocalizations.getString(
                    context,
                    state.errorMessage ?? 'assessment.loadFailed',
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
      return const Scaffold(body: SafeArea(child: AssessmentIntroSkeleton()));
    }

    if (session == null || def == null) {
      return const Scaffold(body: SafeArea(child: AssessmentIntroSkeleton()));
    }

    if (session.status != AssessmentSessionStatus.inProgress) {
      if (session.status == AssessmentSessionStatus.needsPreScreening) {
        return _CancerGateBody(
          definition: def,
          submitting: state.status == AssessmentStatus.submitting,
          priorCancerHistory: _priorCancerHistory,
          priorCancerType: _priorCancerType,
          priorCancerYearController: _priorCancerYear,
          onHistoryChanged: (v) => setState(() {
            _priorCancerHistory = v;
            if (v == false) {
              _priorCancerType = null;
              _priorCancerYear.clear();
            }
          }),
          onTypeChanged: (v) => setState(() => _priorCancerType = v),
          onSubmit: () {
            final hasHistory = _priorCancerHistory;
            final year = int.tryParse(_priorCancerYear.text.trim());
            context.read<AssessmentsBloc>().add(
              SubmitCancerPreScreeningEvent(
                priorCancerHistory: hasHistory == true ? 'yes' : 'no',
                priorCancerType: hasHistory == true
                    ? (_priorCancerType ?? '')
                    : '',
                priorCancerYear: hasHistory == true ? year : null,
              ),
            );
          },
        );
      }

      if (session.status == AssessmentSessionStatus.awaitingCall) {
        return _AwaitingCallBody(
          session: session,
          submitting: state.status == AssessmentStatus.submitting,
        );
      }

      final message = session.status == AssessmentSessionStatus.awaitingPayment
          ? AppLocalizations.getString(context, 'assessment.awaitingPayment')
          : AppLocalizations.getString(context, 'assessment.notReady');
      return Scaffold(
        appBar: AppBar(title: Text(def.shortTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
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
      return const Scaffold(body: SafeArea(child: AssessmentIntroSkeleton()));
    }

    final isBmi = q.type == AssessmentQuestionType.bmi;
    final isSubmitting = state.status == AssessmentStatus.submitting;
    final optionalText = q.optional && q.type == AssessmentQuestionType.text;
    final canProceed =
        optionalText ||
        (_pendingAnswer != null && !_isEmptyAnswer(_pendingAnswer));
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
          headerSliverBuilder: (_, _) => [
            CustomAppBar(
              title: def.shortTitle,
              titleHeroTag: assessmentTitleTag(widget.slug),
              isHome: false,
            ),
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
                          initialValue: _pendingAnswer is String
                              ? _pendingAnswer as String
                              : null,
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

  static bool _isEmptyAnswer(Object? a) {
    if (a == null) return true;
    if (a is String) return a.isEmpty;
    if (a is List) return a.isEmpty;
    return false;
  }

  void _submitAnswer() {
    final state = context.read<AssessmentsBloc>().state;
    final session = state.session;
    final def = state.definition;
    if (session == null || def == null) return;

    final q = def.questionByIndex(session.currentIndex);
    if (q == null) return;

    final optionalText = q.optional && q.type == AssessmentQuestionType.text;
    final answer = _pendingAnswer ?? (optionalText ? '' : null);
    if (answer == null) return;

    context.read<AssessmentsBloc>().add(
      SubmitAnswerEvent(
        questionKey: q.key,
        questionIndex: q.index,
        answer: answer,
      ),
    );
  }
}

class _CancerGateBody extends StatelessWidget {
  final dynamic definition;
  final bool submitting;
  final bool? priorCancerHistory;
  final String? priorCancerType;
  final TextEditingController priorCancerYearController;
  final ValueChanged<bool?> onHistoryChanged;
  final ValueChanged<String?> onTypeChanged;
  final VoidCallback onSubmit;

  const _CancerGateBody({
    required this.definition,
    required this.submitting,
    required this.priorCancerHistory,
    required this.priorCancerType,
    required this.priorCancerYearController,
    required this.onHistoryChanged,
    required this.onTypeChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final hasHistory = priorCancerHistory;
    final yearText = priorCancerYearController.text.trim();
    final year = int.tryParse(yearText);
    final yearOk =
        yearText.isEmpty ||
        (year != null && year >= 1900 && year <= DateTime.now().year);
    final typeChoices = <String>[
      'breast',
      'cervical',
      'prostate',
      'esophageal',
      'colorectal',
      'other',
    ];
    final valid =
        hasHistory != null &&
        (hasHistory == false ||
            (priorCancerType != null && priorCancerType!.isNotEmpty)) &&
        yearOk;

    return Scaffold(
      appBar: AppBar(title: Text(definition.shortTitle as String)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              AppLocalizations.getString(
                context,
                'assessment.cancerGate.question',
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.getString(
                context,
                'assessment.cancerGate.helper',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            RadioListTile<bool>(
              value: true,
              groupValue: hasHistory,
              title: Text(
                AppLocalizations.getString(
                  context,
                  'assessment.cancerGate.yes',
                ),
              ),
              onChanged: submitting ? null : onHistoryChanged,
            ),
            RadioListTile<bool>(
              value: false,
              groupValue: hasHistory,
              title: Text(
                AppLocalizations.getString(context, 'assessment.cancerGate.no'),
              ),
              onChanged: submitting ? null : onHistoryChanged,
            ),
            if (hasHistory == true) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: priorCancerType,
                decoration: InputDecoration(
                  labelText: AppLocalizations.getString(
                    context,
                    'assessment.cancerGate.typeQuestion',
                  ),
                  border: const OutlineInputBorder(),
                ),
                items: typeChoices
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t == 'other'
                              ? AppLocalizations.getString(
                                  context,
                                  'assessment.cancerGate.typeOther',
                                )
                              : t[0].toUpperCase() + t.substring(1),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: submitting ? null : onTypeChanged,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priorCancerYearController,
                enabled: !submitting,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.getString(
                    context,
                    'assessment.cancerGate.yearQuestion',
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            AppPrimaryButton(
              onPressed: (!valid || submitting) ? null : onSubmit,
              label: submitting
                  ? AppLocalizations.getString(
                      context,
                      'assessment.cancerGate.submitting',
                    )
                  : AppLocalizations.getString(
                      context,
                      'assessment.cancerGate.continue',
                    ),
              height: 52,
            ),
          ],
        ),
      ),
    );
  }
}

class _AwaitingCallBody extends StatelessWidget {
  final AssessmentSession session;
  final bool submitting;

  const _AwaitingCallBody({required this.session, required this.submitting});

  @override
  Widget build(BuildContext context) {
    final alerted = session.navigatorAlertedAt != null;
    return Scaffold(
      appBar: AppBar(title: Text(session.assessmentSlug)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_in_talk_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                alerted
                    ? AppLocalizations.getString(
                        context,
                        'assessment.awaitingCall.bodyAlerted',
                      )
                    : AppLocalizations.getString(
                        context,
                        'assessment.awaitingCall.bodyNotAlerted',
                      ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              if (!alerted)
                AppPrimaryButton(
                  onPressed: submitting
                      ? null
                      : () => context.read<AssessmentsBloc>().add(
                          const AlertNavigatorEvent(),
                        ),
                  label: submitting
                      ? AppLocalizations.getString(
                          context,
                          'assessment.awaitingCall.alerting',
                        )
                      : AppLocalizations.getString(
                          context,
                          'assessment.awaitingCall.alertAction',
                        ),
                  height: 52,
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.router.maybePop(),
                child: Text(AppLocalizations.getString(context, 'common.back')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
