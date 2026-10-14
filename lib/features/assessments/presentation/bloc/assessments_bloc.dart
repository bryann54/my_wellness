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
import 'package:my_wellness/features/account/domain/usecases/update_profile_usecase.dart';

part 'assessments_event.dart';
part 'assessments_state.dart';

@injectable
class AssessmentsBloc extends Bloc<AssessmentsEvent, AssessmentsState> {
  final GetVitalsAccessUseCase _getAccess;
  final ListAssessmentsUseCase _listAssessments;
  final CanStartAssessmentUseCase _canStart;
  final GetAssessmentDefinitionUseCase _getDefinition;
  final StartAssessmentSessionUseCase _startSession;
  final GetAssessmentAnswersUseCase _getAnswers;
  final SubmitAssessmentAnswerUseCase _submitAnswer;
  final GetReferralForSessionUseCase _getReferral;
  final GetAssessmentScoreUseCase _getScore;
  final PreviewBmiUseCase _previewBmi;
  final UpdateProfileUseCase _updateProfile;

  String? _activeSlug;
  String? _activeSessionId;
  int _bmiPreviewRequestId = 0;

  AssessmentsBloc(
    this._getAccess,
    this._listAssessments,
    this._canStart,
    this._getDefinition,
    this._startSession,
    this._getAnswers,
    this._submitAnswer,
    this._getReferral,
    this._getScore,
    this._previewBmi,
    this._updateProfile,
  ) : super(const AssessmentsState()) {
    // Each event registered exactly once.
    on<LoadAssessmentsEvent>(_onLoad, transformer: restartable());
    on<SearchAssessmentsEvent>(_onSearch);
    on<StartAssessmentsEvent>(_onStart);
    on<ResumeAssessmentsEvent>(_onResume);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<SubmitBmiEvent>(_onSubmitBmi, transformer: droppable());
    on<PreviewBmiEvent>(_onPreviewBmi);
    on<ClearBmiPreviewEvent>(_onClearBmiPreview);
    on<FetchScoreEvent>(_onFetchScore);
    on<ResetAssessmentsEvent>((_, emit) {
      _activeSlug = null;
      _activeSessionId = null;
      _bmiPreviewRequestId++;
      emit(const AssessmentsState());
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // List + search
  // ─────────────────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────
  // Session lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onStart(
    StartAssessmentsEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    _bmiPreviewRequestId++;
    emit(
      state.copyWith(
        status: AssessmentStatus.loading,
        clearError: true,
        terminated: false,
        terminationReference: null,
        clearBmiPreview: true,
        bmiPreviewLoading: false,
        clearBmiPreviewInputKey: true,
        completionHandled: false,
        alreadyCompleted: false,
      ),
    );

    _activeSlug = event.slug;

    // 1. can-start is the source of truth for "already done".
    final canStartRes = await _canStart(event.slug);
    final canStart = canStartRes.fold(
      (_) => const CanStartResult(allowed: false),
      (r) => r,
    );

    final alreadyDone = !canStart.allowed && canStart.lastCompletedAt != null;

    final defRes = await _getDefinition(event.slug);
    final sessionRes = await _startSession(event.slug);

    final failure =
        defRes.fold<Failure?>((f) => f, (_) => null) ??
        sessionRes.fold<Failure?>((f) => f, (_) => null);
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

    // 2. Already completed -> land on complete; kick score + referral fetch.
    if (alreadyDone) {
      emit(
        state.copyWith(
          status: AssessmentStatus.ready,
          definition: def,
          session: session,
          alreadyCompleted: true,
        ),
      );
      await _loadScoreAndReferral(emit);
      return;
    }

    // 3. Terminated -> show terminated screen.
    if (session.status == AssessmentSessionStatus.terminated) {
      emit(
        state.copyWith(
          status: AssessmentStatus.ready,
          definition: def,
          session: session,
          terminated: true,
          terminationReference: session.referenceNumber,
        ),
      );
      return;
    }

    // 4. Not allowed for any other reason.
    if (!canStart.allowed) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: 'You are not eligible to start this assessment yet.',
          definition: def,
          session: session,
        ),
      );
      return;
    }

    // 5. Fresh session: load any saved answers and enter.
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
        answers: answers,
      ),
    );
  }

  Future<void> _onResume(
    ResumeAssessmentsEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    _bmiPreviewRequestId++;
    emit(
      state.copyWith(
        status: AssessmentStatus.loading,
        clearError: true,
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

    final defRes = await _getDefinition(event.slug);
    final answersRes = await _getAnswers((
      slug: event.slug,
      sessionId: event.sessionId,
    ));

    final failure =
        defRes.fold<Failure?>((f) => f, (_) => null) ??
        answersRes.fold<Failure?>((f) => f, (_) => null);

    if (failure != null) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(failure),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AssessmentStatus.ready,
        session: AssessmentSession(
          id: event.sessionId,
          assessmentSlug: event.slug,
          status: AssessmentSessionStatus.inProgress,
          currentIndex: event.currentIndex,
          totalQuestions: event.totalQuestions,
          completionPct: event.completionPercent,
        ),
        definition: defRes.getOrElse(
          () => throw StateError('definition missing'),
        ),
        answers: answersRes.getOrElse(() => const <AssessmentAnswer>[]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Answer / BMI submission
  // ─────────────────────────────────────────────────────────────────────────

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
                toastMessage: 'Please complete the earlier question first.',
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
        if (result.terminate) {
          emit(
            state.copyWith(
              status: AssessmentStatus.ready,
              terminated: true,
              terminationReference: result.reference,
              session: state.session?.applyResult(result),
              answers: recordedAnswers,
            ),
          );
          return;
        }

        final updatedSession = state.session?.applyResult(result);

        if (result.completed) {
          emit(
            state.copyWith(
              status: AssessmentStatus.completed,
              session: updatedSession,
              answers: recordedAnswers,
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
          errorMessage: 'Enter a valid weight and height.',
          toastType: ToastType.error,
          toastMessage: 'Enter a valid weight and height.',
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
          errorMessage: 'BMI result is not ready. Re-enter your measurements.',
          toastType: ToastType.error,
          toastMessage: 'BMI result is not ready. Re-enter your measurements.',
          toastNonce: state.toastNonce + 1,
        ),
      );
      return;
    }

    // Keep the member's health profile in sync before recording the BMI
    // answer. Do not continue if PATCH fails.
    final profileResult = await _updateProfile({
      'weight_kg': weightKg,
      'height_cm': heightCm,
    });
    final profileFailure = profileResult.fold<Failure?>((f) => f, (_) => null);
    if (profileFailure != null) {
      final message = mapFailure(profileFailure);
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

    final session = state.session;
    final definition = state.definition;
    if (session == null || definition == null) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: 'Assessment session is no longer available.',
          toastType: ToastType.error,
          toastMessage: 'Assessment session is no longer available.',
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
          errorMessage: 'BMI question is out of sequence. Please try again.',
          toastType: ToastType.error,
          toastMessage: 'BMI question is out of sequence. Please try again.',
          toastNonce: state.toastNonce + 1,
        ),
      );
      return;
    }

    final currentBmiQuestion = bmiQuestion!;

    // Refresh the answer list before this ordered submission. A session can
    // be resumed or the server can reject an earlier answer, so the list
    // loaded when the screen opened may no longer reflect server state.
    final latestAnswersResult = await _getAnswers((
      slug: slug,
      sessionId: sessionId,
    ));
    final latestAnswers = latestAnswersResult.getOrElse(() => state.answers);

    // If BMI was shown before earlier questions were accepted, return to
    // the first unanswered question. The answers API enforces index order.
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

    // Store the classified BMI as the ordered assessment answer. The
    // server response supplies the authoritative next question index.
    final answer = bmiPreview.bmi.toStringAsFixed(1);
    final answerResult = await _submitAnswer((
      slug: slug,
      sessionId: sessionId,
      questionKey: currentBmiQuestion.key,
      questionIndex: currentBmiQuestion.index,
      answer: answer,
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
          answer: answer,
        );

        if (result.terminate) {
          emit(
            state.copyWith(
              status: AssessmentStatus.ready,
              terminated: true,
              terminationReference: result.reference,
              session: updatedSession,
              answers: recordedAnswers,
              clearBmiPreview: true,
              clearBmiPreviewInputKey: true,
            ),
          );
          return;
        }

        if (result.completed) {
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
    required String answer,
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
    final answeredIndices = answers
        .map((answer) => answer.questionIndex)
        .toSet();
    final questions = [...definition.questions]
      ..sort((a, b) => a.index.compareTo(b.index));
    for (final question in questions) {
      if (beforeIndex != null && question.index >= beforeIndex) continue;
      if (question.type == AssessmentQuestionType.unknown) continue;
      if (skipBmi && question.type == AssessmentQuestionType.bmi) continue;
      if (!answeredIndices.contains(question.index)) return question;
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

  String _bmiPreviewInputKey(double weightKg, double heightCm) =>
      '${weightKg.toString()}|${heightCm.toString()}';

  // ─────────────────────────────────────────────────────────────────────────
  // Score + referral
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onFetchScore(
    FetchScoreEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    if (state.completionHandled && state.score != null) return;

    emit(state.copyWith(status: AssessmentStatus.loading));
    await _loadScoreAndReferral(emit);
  }

  /// Fetches score (required) and referral (optional) in parallel, then
  /// emits `completed` with both in state. Sets [completionHandled] so
  /// downstream screens know not to refetch.
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
