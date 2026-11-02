import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_answer.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_definition.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_question.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/domain/entities/bmi_preview.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/assessments/domain/entities/vitals_access.dart';

import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/assessments/domain/repositories/assessments_repository.dart';
import 'package:my_wellness/features/assessments/domain/usecases/assessments_usecases.dart';

part 'assessments_event.dart';
part 'assessments_state.dart';

@injectable
class AssessmentsBloc extends Bloc<AssessmentsEvent, AssessmentsState> {
  final GetVitalsAccessUseCase _getAccess;
  final ListAssessmentsUseCase _listAssessments;
  final CanStartAssessmentUseCase _canStart;
  final GetAssessmentDefinitionUseCase _getDefinition;
  final StartAssessmentSessionUseCase _startSession;
  final SubmitCancerPreScreeningUseCase _submitPreScreening;
  final GetAssessmentAnswersUseCase _getAnswers;
  final SubmitAssessmentAnswerUseCase _submitAnswer;
  final GetReferralForSessionUseCase _getReferral;
  final GetAssessmentScoreUseCase _getScore;
  final PreviewBmiUseCase _previewBmi;
  final SubmitBmiMetricsUseCase _submitBmiMetrics;
  final AlertNavigatorUseCase _alertNavigator;

  String? _activeSlug;
  String? _activeSessionId;
  int _bmiPreviewRequestId = 0;

  AssessmentsBloc(
    this._getAccess,
    this._listAssessments,
    this._canStart,
    this._getDefinition,
    this._startSession,
    this._submitPreScreening,
    this._getAnswers,
    this._submitAnswer,
    this._getReferral,
    this._getScore,
    this._previewBmi,
    this._submitBmiMetrics,
    this._alertNavigator,
  ) : super(const AssessmentsState()) {
    on<LoadAssessmentsEvent>(_onLoad, transformer: restartable());
    on<SearchAssessmentsEvent>(_onSearch);
    on<StartAssessmentsEvent>(_onStart);
    on<SubmitCancerPreScreeningEvent>(_onSubmitPreScreening);
    on<ResumeAssessmentsEvent>(_onResume);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<SubmitBmiEvent>(_onSubmitBmi, transformer: droppable());
    on<PreviewBmiEvent>(_onPreviewBmi);
    on<ClearBmiPreviewEvent>(_onClearBmiPreview);
    on<FetchScoreEvent>(_onFetchScore);
    on<AlertNavigatorEvent>(_onAlertNavigator, transformer: droppable());
    on<ResetAssessmentsEvent>((_, emit) {
      _activeSlug = null;
      _activeSessionId = null;
      _bmiPreviewRequestId++;
      emit(const AssessmentsState());
    });
  }

  Future<void> _onLoad(
    LoadAssessmentsEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.loading, clearError: true));

    final accessRes = await _getAccess(NoParams());
    final listRes = await _listAssessments(NoParams());

    final failure =
        accessRes.fold<Failure?>((f) => f, (_) => null) ??
        listRes.fold<Failure?>((f) => f, (_) => null);

    if (failure != null) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(failure),
        ),
      );
      return;
    }

    final access = accessRes.getOrElse(
      () => const VitalsAccess(hasAccess: false),
    );
    final all = listRes.getOrElse(() => const <AssessmentSummary>[]);
    final userGender = event.userGender;

    final visible = all
        .where((a) => a.isVisibleFor(userGender))
        .toList(growable: false);

    emit(
      state.copyWith(
        status: AssessmentStatus.ready,
        access: access,
        assessments: visible,
        filteredAssessments: visible,
        searchQuery: '',
      ),
    );
  }

  void _onSearch(SearchAssessmentsEvent event, Emitter<AssessmentsState> emit) {
    final query = event.query.trim();
    final normalized = query.toLowerCase();

    final filtered = normalized.isEmpty
        ? state.assessments
        : state.assessments
              .where((a) {
                final title = a.title.toLowerCase();
                final short = a.shortTitle.toLowerCase();
                final tagline = a.tagline.toLowerCase();
                final category = a.category.toLowerCase();
                return title.contains(normalized) ||
                    short.contains(normalized) ||
                    tagline.contains(normalized) ||
                    category.contains(normalized);
              })
              .toList(growable: false);

    emit(state.copyWith(searchQuery: query, filteredAssessments: filtered));
  }

  bool _isWarmForSlug(String slug) {
    return state.status == AssessmentStatus.ready &&
        state.definition?.slug == slug &&
        state.session?.assessmentSlug == slug &&
        !state.alreadyCompleted;
  }

  Future<void> _onStart(
    StartAssessmentsEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    if (_isWarmForSlug(event.slug)) return;

    _bmiPreviewRequestId++;
    emit(
      state.copyWith(
        status: AssessmentStatus.loading,
        clearError: true,
        clearBlock: true,
        terminated: false,
        terminationReference: null,
        clearBmiPreview: true,
        bmiPreviewLoading: false,
        clearBmiPreviewInputKey: true,
        completionHandled: false,
        alreadyCompleted: false,
        clearCanStart: true,
      ),
    );

    _activeSlug = event.slug;

    final canStartRes = await _canStart(event.slug);
    final canStart = canStartRes.fold(
      (_) => const CanStartResult(allowed: false),
      (r) => r,
    );

    final defRes = await _getDefinition(event.slug);
    final sessionRes = await _startSession(event.slug);

    final sessionFailure = sessionRes.fold<Failure?>((f) => f, (_) => null);
    if (sessionFailure is AssessmentValidationFailure) {
      _emitBranch(emit, sessionFailure);
      return;
    }

    final failure =
        defRes.fold<Failure?>((f) => f, (_) => null) ?? sessionFailure;
    if (failure != null) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(failure),
        ),
      );
      return;
    }

    final def = defRes.getOrElse(() => throw StateError('definition missing'));
    final session = sessionRes.getOrElse(
      () => throw StateError('session missing'),
    );
    _activeSessionId = session.id;

    final alreadyDone = !canStart.allowed && canStart.lastCompletedAt != null;

    if (alreadyDone) {
      emit(
        state.copyWith(
          status: AssessmentStatus.ready,
          definition: def,
          session: session,
          canStart: canStart,
          alreadyCompleted: true,
        ),
      );
      await _loadScoreAndReferral(emit);
      return;
    }

    if (session.status == AssessmentSessionStatus.terminated) {
      emit(
        state.copyWith(
          status: AssessmentStatus.ready,
          definition: def,
          session: session,
          canStart: canStart,
          terminated: true,
          terminationReference: session.referenceNumber,
        ),
      );
      return;
    }

    if (session.status == AssessmentSessionStatus.completed) {
      emit(
        state.copyWith(
          status: AssessmentStatus.completed,
          definition: def,
          session: session,
          canStart: canStart,
        ),
      );
      await _loadScoreAndReferral(emit);
      return;
    }

    if (!canStart.allowed) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: 'assessment.notEligible',
          definition: def,
          session: session,
          canStart: canStart,
        ),
      );
      return;
    }

    if (session.status != AssessmentSessionStatus.inProgress) {
      emit(
        state.copyWith(
          status: AssessmentStatus.ready,
          definition: def,
          session: session,
          canStart: canStart,
          answers: const <AssessmentAnswer>[],
        ),
      );
      return;
    }

    final answersRes = await _getAnswers((
      slug: event.slug,
      sessionId: session.id,
    ));
    final answers = answersRes.getOrElse(() => const <AssessmentAnswer>[]);

    emit(
      state.copyWith(
        status: AssessmentStatus.ready,
        definition: def,
        session: session,
        canStart: canStart,
        answers: answers,
      ),
    );
  }

  void _emitBranch(
    Emitter<AssessmentsState> emit,
    AssessmentValidationFailure failure,
  ) {
    final block = switch (failure.code) {
      'age_ineligible' => AssessmentBlockKind.ageIneligible,
      'gender_ineligible' => AssessmentBlockKind.genderIneligible,
      'cancer_diagnosed_blocked' => AssessmentBlockKind.cancerDiagnosedBlocked,
      'dependant_consent_required' =>
        AssessmentBlockKind.dependantConsentRequired,
      'assessment_in_progress' => AssessmentBlockKind.assessmentInProgress,
      _ => AssessmentBlockKind.none,
    };
    emit(
      state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: failure.error,
        block: block,
        blockingSlug: failure.blockingSlug,
        blockingTitle: failure.blockingTitle,
        dependantVariantSlug: failure.dependantVariantSlug,
      ),
    );
  }

  Future<void> _onResume(
    ResumeAssessmentsEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    if (state.status == AssessmentStatus.ready &&
        state.session?.id == event.sessionId &&
        state.definition?.slug == event.slug) {
      return;
    }

    _bmiPreviewRequestId++;
    emit(
      state.copyWith(
        status: AssessmentStatus.loading,
        clearError: true,
        clearBlock: true,
        clearBmiPreview: true,
        bmiPreviewLoading: false,
        clearBmiPreviewInputKey: true,
        terminated: false,
        alreadyCompleted: false,
        completionHandled: false,
        clearSession: true,
        clearReferral: true,
      ),
    );
    _activeSlug = event.slug;
    _activeSessionId = event.sessionId;

    final sessionRes = await _startSession(event.slug);
    final sessionFailure = sessionRes.fold<Failure?>((f) => f, (_) => null);
    if (sessionFailure is AssessmentValidationFailure) {
      _emitBranch(emit, sessionFailure);
      return;
    }
    if (sessionFailure != null) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(sessionFailure),
        ),
      );
      return;
    }
    final session = sessionRes.getOrElse(
      () => throw StateError('session missing'),
    );
    _activeSessionId = session.id;
    final defRes = await _getDefinition(event.slug);

    final answersRes =
        session.status == AssessmentSessionStatus.inProgress ||
            session.status == AssessmentSessionStatus.completed
        ? await _getAnswers((slug: event.slug, sessionId: session.id))
        : null;

    final definitionFailure = defRes.fold<Failure?>((f) => f, (_) => null);
    final answersFailure = answersRes?.fold<Failure?>((f) => f, (_) => null);

    if (definitionFailure != null || answersFailure != null) {
      final failure = definitionFailure ?? answersFailure;
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(failure!),
        ),
      );
      return;
    }

    final definition = defRes.getOrElse(
      () => throw StateError('definition missing'),
    );
    final answers =
        answersRes?.getOrElse(() => const <AssessmentAnswer>[]) ??
        const <AssessmentAnswer>[];
    final firstUnanswered = session.status == AssessmentSessionStatus.inProgress
        ? _firstUnansweredQuestion(definition, answers)
        : null;
    final currentIndex =
        firstUnanswered != null && firstUnanswered.index > session.currentIndex
        ? firstUnanswered.index
        : session.currentIndex;
    final resumedSession = session.status == AssessmentSessionStatus.inProgress
        ? AssessmentSession(
            id: session.id,
            assessmentSlug: session.assessmentSlug,
            status: session.status,
            currentIndex: currentIndex,
            totalQuestions: session.totalQuestions,
            completionPct: session.totalQuestions == 0
                ? session.completionPct
                : ((currentIndex / session.totalQuestions) * 100)
                      .round()
                      .clamp(0, 100)
                      .toInt(),
            referenceNumber: session.referenceNumber,
            paidAt: session.paidAt,
            startedAt: session.startedAt,
            completedAt: session.completedAt,
            navigatorAlertedAt: session.navigatorAlertedAt,
          )
        : session;

    emit(
      state.copyWith(
        status: session.status == AssessmentSessionStatus.completed
            ? AssessmentStatus.completed
            : AssessmentStatus.ready,
        session: resumedSession,
        definition: definition,
        answers: answers,
      ),
    );
    if (session.status == AssessmentSessionStatus.completed) {
      await _loadScoreAndReferral(emit);
    }
  }

  Future<void> _onSubmitPreScreening(
    SubmitCancerPreScreeningEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    final session = state.session;
    final slug = _activeSlug;
    if (session == null ||
        slug == null ||
        session.status != AssessmentSessionStatus.needsPreScreening) {
      return;
    }

    emit(state.copyWith(status: AssessmentStatus.submitting, clearError: true));
    final result = await _submitPreScreening(
      slug: slug,
      sessionId: session.id,
      priorCancerHistory: event.priorCancerHistory,
      priorCancerType: event.priorCancerType,
      priorCancerYear: event.priorCancerYear,
    );
    await result.fold<Future<void>>(
      (failure) async {
        if (failure is AssessmentValidationFailure) {
          _emitBranch(emit, failure);
          return;
        }
        emit(
          state.copyWith(
            status: AssessmentStatus.error,
            errorMessage: mapFailure(failure),
          ),
        );
      },
      (updatedSession) async {
        emit(
          state.copyWith(
            status: updatedSession.status == AssessmentSessionStatus.completed
                ? AssessmentStatus.completed
                : AssessmentStatus.ready,
            session: updatedSession,
          ),
        );
        if (updatedSession.status == AssessmentSessionStatus.completed) {
          await _loadScoreAndReferral(emit);
        }
      },
    );
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    final slug = _activeSlug;
    final sessionId = _activeSessionId;
    if (slug == null || sessionId == null) return;

    emit(state.copyWith(status: AssessmentStatus.submitting, clearError: true));

    final res = await _submitAnswer((
      slug: slug,
      sessionId: sessionId,
      questionKey: event.questionKey,
      questionIndex: event.questionIndex,
      answer: event.answer,
    ));

    await res.fold(
      (f) async {
        final definition = state.definition;
        final session = state.session;
        if (f is ValidationFailure &&
            f.error.toLowerCase().contains(
              'please answer the previous question first',
            ) &&
            definition != null &&
            session != null) {
          final expectedQuestion = _firstUnansweredQuestion(
            definition,
            state.answers,
          );
          if (expectedQuestion != null &&
              expectedQuestion.index < event.questionIndex) {
            emit(
              state.copyWith(
                status: AssessmentStatus.ready,
                clearError: true,
                session: session.applyResult(
                  SubmitAnswerResult(
                    nextIndex: expectedQuestion.index,
                    terminate: false,
                    completed: false,
                  ),
                ),
                toastType: ToastType.info,
                toastMessage: 'assessment.previousQuestionFirstToast',
                toastNonce: state.toastNonce + 1,
              ),
            );
            return;
          }
        }
        final message = mapFailure(f);
        emit(
          state.copyWith(
            status: AssessmentStatus.error,
            errorMessage: message,
            toastType: ToastType.error,
            toastMessage: message,
            toastNonce: state.toastNonce + 1,
          ),
        );
      },
      (result) async {
        final recordedAnswers = _recordAnswer(state.answers, event);
        final isDone = result.terminate || result.completed;

        if (isDone) {
          emit(
            state.copyWith(
              status: AssessmentStatus.completed,
              session: state.session?.applyResult(result),
              answers: recordedAnswers,
            ),
          );
          await _loadScoreAndReferral(emit);
          return;
        }

        emit(
          state.copyWith(
            status: AssessmentStatus.ready,
            session: state.session?.applyResult(result),
            answers: recordedAnswers,
          ),
        );
      },
    );
  }

  Future<void> _onSubmitBmi(
    SubmitBmiEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    final slug = _activeSlug;
    final sessionId = _activeSessionId;
    if (slug == null || sessionId == null) return;

    emit(state.copyWith(status: AssessmentStatus.submitting));

    final weightKg = double.tryParse(event.weightKg);
    final heightCm = double.tryParse(event.heightCm);
    if (weightKg == null ||
        heightCm == null ||
        weightKg <= 0 ||
        heightCm <= 0) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: 'assessment.bmiInvalid',
          toastType: ToastType.error,
          toastMessage: 'assessment.bmiInvalid',
          toastNonce: state.toastNonce + 1,
        ),
      );
      return;
    }

    final bmiPreview = state.bmiPreview;
    if (bmiPreview == null ||
        state.bmiPreviewInputKey != _bmiPreviewInputKey(weightKg, heightCm) ||
        state.bmiPreviewLoading) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: 'assessment.bmiNotReady',
          toastType: ToastType.error,
          toastMessage: 'assessment.bmiNotReady',
          toastNonce: state.toastNonce + 1,
        ),
      );
      return;
    }

    final session = state.session;
    final definition = state.definition;
    if (session == null || definition == null) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: 'assessment.sessionUnavailable',
          toastType: ToastType.error,
          toastMessage: 'assessment.sessionUnavailable',
          toastNonce: state.toastNonce + 1,
        ),
      );
      return;
    }

    final bmiQuestion = definition.questionByIndex(session.currentIndex);
    if (bmiQuestion?.type != AssessmentQuestionType.bmi) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: 'assessment.bmiOutOfSequence',
          toastType: ToastType.error,
          toastMessage: 'assessment.bmiOutOfSequence',
          toastNonce: state.toastNonce + 1,
        ),
      );
      return;
    }

    final currentBmiQuestion = bmiQuestion!;

    final latestAnswersResult = await _getAnswers((
      slug: slug,
      sessionId: sessionId,
    ));
    final latestAnswers = latestAnswersResult.getOrElse(() => state.answers);

    final previousUnanswered = _firstUnansweredQuestion(
      definition,
      latestAnswers,
      beforeIndex: currentBmiQuestion.index,
      skipBmi: true,
    );
    if (previousUnanswered != null) {
      emit(
        state.copyWith(
          status: AssessmentStatus.ready,
          answers: latestAnswers,
          session: session.applyResult(
            SubmitAnswerResult(
              nextIndex: previousUnanswered.index,
              terminate: false,
              completed: false,
            ),
          ),
          clearBmiPreview: true,
          clearBmiPreviewInputKey: true,
        ),
      );
      return;
    }

    final bmiMetricsResult = await _submitBmiMetrics(
      slug: slug,
      sessionId: sessionId,
      weightKg: weightKg,
      heightCm: heightCm,
    );
    final bmiMetricsFailure = bmiMetricsResult.fold<Failure?>(
      (f) => f,
      (_) => null,
    );
    if (bmiMetricsFailure != null) {
      final message = mapFailure(bmiMetricsFailure);
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: message,
          toastType: ToastType.error,
          toastMessage: message,
          toastNonce: state.toastNonce + 1,
        ),
      );
      return;
    }

    final answerValue = double.parse(bmiPreview.bmi.toStringAsFixed(1));
    final answerResult = await _submitAnswer((
      slug: slug,
      sessionId: sessionId,
      questionKey: currentBmiQuestion.key,
      questionIndex: currentBmiQuestion.index,
      answer: answerValue,
    ));

    await answerResult.fold(
      (failure) async {
        final message = mapFailure(failure);
        emit(
          state.copyWith(
            status: AssessmentStatus.error,
            errorMessage: message,
            toastType: ToastType.error,
            toastMessage: message,
            toastNonce: state.toastNonce + 1,
          ),
        );
      },
      (result) async {
        final updatedSession = session.applyResult(result);
        final recordedAnswers = _recordAnswerValue(
          state.answers,
          questionKey: currentBmiQuestion.key,
          questionIndex: currentBmiQuestion.index,
          answer: answerValue,
        );

        final isDone = result.terminate || result.completed;

        if (isDone) {
          emit(
            state.copyWith(
              status: AssessmentStatus.completed,
              session: updatedSession,
              answers: recordedAnswers,
              clearBmiPreview: true,
              clearBmiPreviewInputKey: true,
            ),
          );
          await _loadScoreAndReferral(emit);
          return;
        }

        emit(
          state.copyWith(
            status: AssessmentStatus.ready,
            session: updatedSession,
            answers: recordedAnswers,
            clearBmiPreview: true,
            clearBmiPreviewInputKey: true,
          ),
        );
      },
    );
  }

  List<AssessmentAnswer> _recordAnswer(
    List<AssessmentAnswer> answers,
    SubmitAnswerEvent event,
  ) => _recordAnswerValue(
    answers,
    questionKey: event.questionKey,
    questionIndex: event.questionIndex,
    answer: event.answer,
  );

  List<AssessmentAnswer> _recordAnswerValue(
    List<AssessmentAnswer> answers, {
    required String questionKey,
    required int questionIndex,
    required Object answer,
  }) {
    final updated = answers
        .where((existing) => existing.questionKey != questionKey)
        .toList(growable: true);
    updated.add(
      AssessmentAnswer(
        questionKey: questionKey,
        questionIndex: questionIndex,
        answer: answer,
      ),
    );
    return updated;
  }

  AssessmentQuestion? _firstUnansweredQuestion(
    AssessmentDefinition definition,
    List<AssessmentAnswer> answers, {
    int? beforeIndex,
    bool skipBmi = false,
  }) {
    final answeredKeys = answers.map((answer) => answer.questionKey).toSet();
    final questions = [...definition.questions]
      ..sort((a, b) => a.index.compareTo(b.index));
    for (final question in questions) {
      if (beforeIndex != null && question.index >= beforeIndex) continue;
      if (question.type == AssessmentQuestionType.unknown) continue;
      if (skipBmi && question.type == AssessmentQuestionType.bmi) continue;
      if (!answeredKeys.contains(question.key)) return question;
    }
    return null;
  }

  Future<void> _onPreviewBmi(
    PreviewBmiEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    final weightKg = double.tryParse(event.weightKg);
    final heightCm = double.tryParse(event.heightCm);
    if (weightKg == null ||
        heightCm == null ||
        !weightKg.isFinite ||
        !heightCm.isFinite ||
        weightKg <= 0 ||
        heightCm <= 0) {
      _onClearBmiPreview(const ClearBmiPreviewEvent(), emit);
      return;
    }

    final requestId = ++_bmiPreviewRequestId;
    final inputKey = _bmiPreviewInputKey(weightKg, heightCm);
    emit(
      state.copyWith(
        clearBmiPreview: true,
        bmiPreviewLoading: true,
        bmiPreviewInputKey: inputKey,
      ),
    );

    final res = await _previewBmi((
      weightKg: weightKg.toString(),
      heightCm: heightCm.toString(),
    ));
    if (requestId != _bmiPreviewRequestId || emit.isDone) return;

    res.fold(
      (failure) => emit(
        state.copyWith(
          clearBmiPreview: true,
          bmiPreviewLoading: false,
          clearBmiPreviewInputKey: true,
          toastType: ToastType.error,
          toastMessage: mapFailure(failure),
          toastNonce: state.toastNonce + 1,
        ),
      ),
      (preview) => emit(
        state.copyWith(
          bmiPreview: preview,
          bmiPreviewLoading: false,
          bmiPreviewInputKey: inputKey,
        ),
      ),
    );
  }

  void _onClearBmiPreview(
    ClearBmiPreviewEvent event,
    Emitter<AssessmentsState> emit,
  ) {
    _bmiPreviewRequestId++;
    emit(
      state.copyWith(
        clearBmiPreview: true,
        bmiPreviewLoading: false,
        clearBmiPreviewInputKey: true,
      ),
    );
  }

  Future<void> _onFetchScore(
    FetchScoreEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    if (state.completionHandled && state.score != null) return;

    emit(state.copyWith(status: AssessmentStatus.loading));
    await _loadScoreAndReferral(emit);
  }

  Future<void> _onAlertNavigator(
    AlertNavigatorEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    final slug = _activeSlug ?? state.definition?.slug;
    final sessionId = _activeSessionId ?? state.session?.id;
    if (slug == null || sessionId == null) return;

    emit(state.copyWith(status: AssessmentStatus.submitting, clearError: true));
    final res = await _alertNavigator(slug: slug, sessionId: sessionId);
    res.fold(
      (failure) => emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(failure),
          toastType: ToastType.error,
          toastMessage: mapFailure(failure),
          toastNonce: state.toastNonce + 1,
        ),
      ),
      (session) => emit(
        state.copyWith(
          status: AssessmentStatus.ready,
          session: session,
          toastType: ToastType.success,
          toastMessage: 'assessment.awaitingCall.alertedToast',
          toastNonce: state.toastNonce + 1,
        ),
      ),
    );
  }

  String _bmiPreviewInputKey(double weightKg, double heightCm) =>
      '${weightKg.toString()}|${heightCm.toString()}';

  Future<void> _loadScoreAndReferral(Emitter<AssessmentsState> emit) async {
    final slug = _activeSlug;
    final sessionId = _activeSessionId;
    if (slug == null || sessionId == null) return;

    final scoreFut = _getScore((slug: slug, sessionId: sessionId));
    final referralFut = _getReferral(sessionId);

    final scoreRes = await scoreFut;
    final referralRes = await referralFut;

    scoreRes.fold(
      (f) => emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (score) {
        final referral = referralRes.fold((_) => null, (r) => r);
        emit(
          state.copyWith(
            status: AssessmentStatus.completed,
            score: score,
            referral: referral,
            completionHandled: true,
          ),
        );
      },
    );
  }
}
