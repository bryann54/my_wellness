import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_answer.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_definition.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_question.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/domain/entities/bmi_preview.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/assessments/domain/entities/vitals_access.dart';
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
  final DownloadAssessmentReportUseCase _downloadReport;
  final EmailAssessmentReportUseCase _emailReport;

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
    this._downloadReport,
    this._emailReport,
  ) : super(const AssessmentsState()) {
    on<LoadAssessmentsEvent>(_onLoad, transformer: restartable());
    on<SearchAssessmentsEvent>(_onSearch);
    on<StartAssessmentsEvent>(_onStart, transformer: restartable());
    on<ResumeAssessmentsEvent>(_onResume, transformer: restartable());
    on<SubmitCancerPreScreeningEvent>(_onSubmitPreScreening);
    on<SubmitAnswerEvent>(_onSubmitAnswer, transformer: droppable());
    on<SubmitBmiEvent>(_onSubmitBmi, transformer: droppable());
    on<PreviewBmiEvent>(_onPreviewBmi);
    on<ClearBmiPreviewEvent>(_onClearBmiPreview);
    on<FetchScoreEvent>(_onFetchScore);
    on<AlertNavigatorEvent>(_onAlertNavigator);
    on<DownloadReportEvent>(_onDownloadReport, transformer: droppable());
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
    if (!event.silent || state.assessments.isEmpty) {
      emit(state.copyWith(status: AssessmentStatus.loading, clearError: true));
    }

    final accessRes = await _getAccess(NoParams());
    final listRes = await _listAssessments(NoParams());

    final failure =
        accessRes.fold<Failure?>((f) => f, (_) => null) ??
        listRes.fold<Failure?>((f) => f, (_) => null);

    if (failure != null) {
      if (!event.silent || state.assessments.isEmpty) {
        emit(
          state.copyWith(
            status: AssessmentStatus.error,
            errorMessage: mapFailure(failure),
          ),
        );
      }
      return;
    }

    final access = accessRes.getOrElse(
      () => const VitalsAccess(hasAccess: false),
    );
    final all = listRes.getOrElse(() => const <AssessmentSummary>[]);

    final visible = all
        .where(
          (a) =>
              !a.slug.endsWith('-followup') && a.isVisibleFor(event.userGender),
        )
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

  /// If the bloc already holds a live session for this slug, no need to hit
  /// the network again.
  bool _isWarmForSlug(String slug) {
    return state.definition?.slug == slug &&
        state.session?.assessmentSlug == slug &&
        state.status == AssessmentStatus.ready;
  }

  Future<void> _onStart(
    StartAssessmentsEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    if (_isWarmForSlug(event.slug) && !state.alreadyCompleted) return;

    _bmiPreviewRequestId++;
    emit(
      state.copyWith(
        status: AssessmentStatus.loading,
        clearError: true,
        terminated: false,
        clearBmiPreview: true,
        clearBmiPreviewInputKey: true,
        completionHandled: false,
        alreadyCompleted: false,
      ),
    );
    _activeSlug = event.slug;

    final canStartRes = await _canStart(event.slug);
    final canStart = canStartRes.fold(
      (_) => const CanStartResult(allowed: false),
      (r) => r,
    );

    final defRes = await _getDefinition(event.slug);
    final defFailure = defRes.fold<Failure?>((f) => f, (_) => null);
    if (defFailure != null) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(defFailure),
        ),
      );
      return;
    }
    final def = defRes.getOrElse(() => throw StateError('definition missing'));

    // Blocked reasons that live only on can-start: don't create a session.
    if (!canStart.allowed &&
        canStart.blockedReason != null &&
        canStart.blockedReason != 'gender_ineligible' &&
        canStart.blockedReason != 'age_ineligible' &&
        canStart.blockedReason != 'cancer_diagnosed_blocked' &&
        canStart.blockedReason != 'assessment_paused' &&
        canStart.blockedReason != 'ebola_access_required') {
      // chapter_not_unlocked or ordinary cooldown: show intro without a session.
      emit(
        state.copyWith(
          status: AssessmentStatus.ready,
          definition: def,
          canStart: canStart,
        ),
      );
      return;
    }

    final sessionRes = await _startSession(event.slug);
    final sessionFailure = sessionRes.fold<Failure?>((f) => f, (_) => null);
    if (sessionFailure != null) {
      // Any hard gate (age/gender/cancer/in-progress) surfaces here.
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

    if (session.status == AssessmentSessionStatus.completed) {
      // Skip straight to the thank-you/result screen.
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

    if (session.status == AssessmentSessionStatus.inProgress) {
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
      return;
    }

    // awaiting_payment / awaiting_call / needs_pre_screening: show the intro.
    emit(
      state.copyWith(
        status: AssessmentStatus.ready,
        definition: def,
        session: session,
        canStart: canStart,
        answers: const <AssessmentAnswer>[],
      ),
    );
  }

  Future<void> _onResume(
    ResumeAssessmentsEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    if (state.session?.id == event.sessionId &&
        state.definition?.slug == event.slug &&
        state.status == AssessmentStatus.ready) {
      return;
    }

    _bmiPreviewRequestId++;
    emit(
      state.copyWith(
        status: AssessmentStatus.loading,
        clearError: true,
        clearBmiPreview: true,
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
    final defFailure = defRes.fold<Failure?>((f) => f, (_) => null);
    if (defFailure != null) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(defFailure),
        ),
      );
      return;
    }
    final def = defRes.getOrElse(() => throw StateError('definition missing'));

    final sessionRes = await _startSession(event.slug);
    final sessionFailure = sessionRes.fold<Failure?>((f) => f, (_) => null);
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

    if (session.status == AssessmentSessionStatus.completed) {
      emit(
        state.copyWith(
          status: AssessmentStatus.completed,
          session: session,
          definition: def,
        ),
      );
      await _loadScoreAndReferral(emit);
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
        session: session,
        definition: def,
        answers: answers,
      ),
    );
  }

  Future<void> _onSubmitPreScreening(
    SubmitCancerPreScreeningEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    final session = state.session;
    final slug = _activeSlug;
    if (session == null || slug == null) return;
    if (session.status != AssessmentSessionStatus.needsPreScreening) return;

    emit(state.copyWith(status: AssessmentStatus.submitting, clearError: true));
    final result = await _submitPreScreening(
      slug: slug,
      sessionId: session.id,
      priorCancerHistory: event.priorCancerHistory,
      priorCancerType: event.priorCancerType,
      priorCancerYear: event.priorCancerYear,
    );

    await result.fold<Future<void>>(
      (failure) async => emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(failure),
        ),
      ),
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
        final recorded = _recordAnswer(
          state.answers,
          questionKey: event.questionKey,
          questionIndex: event.questionIndex,
          answer: event.answer,
        );
        final updatedSession = state.session?.applyResult(result);

        if (result.completed) {
          emit(
            state.copyWith(
              status: AssessmentStatus.completed,
              session: updatedSession,
              answers: recorded,
            ),
          );
          await _loadScoreAndReferral(emit);
          return;
        }
        if (result.terminate) {
          emit(
            state.copyWith(
              status: AssessmentStatus.ready,
              terminated: true,
              terminationReference: result.reference,
              session: updatedSession,
              answers: recorded,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            status: AssessmentStatus.ready,
            session: updatedSession,
            answers: recorded,
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

    final weightKg = double.tryParse(event.weightKg);
    final heightCm = double.tryParse(event.heightCm);
    if (weightKg == null ||
        heightCm == null ||
        weightKg < 20 ||
        weightKg > 400 ||
        heightCm < 80 ||
        heightCm > 250) {
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

    final preview = state.bmiPreview;
    final inputKey = _inputKey(weightKg, heightCm);
    if (preview == null || state.bmiPreviewInputKey != inputKey) {
      emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: 'BMI result is not ready. Re-enter your measurements.',
          toastType: ToastType.error,
          toastMessage: 'BMI result is not ready.',
          toastNonce: state.toastNonce + 1,
        ),
      );
      return;
    }

    final session = state.session;
    final definition = state.definition;
    if (session == null || definition == null) return;
    final bmiQuestion = definition.questionByIndex(session.currentIndex);
    if (bmiQuestion == null || bmiQuestion.type != AssessmentQuestionType.bmi) {
      return;
    }

    emit(state.copyWith(status: AssessmentStatus.submitting));

    final metrics = await _submitBmiMetrics(
      slug: slug,
      sessionId: sessionId,
      weightKg: weightKg,
      heightCm: heightCm,
    );
    final metricsFailure = metrics.fold<Failure?>((f) => f, (_) => null);
    if (metricsFailure != null) {
      final message = mapFailure(metricsFailure);
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

    // The preview endpoint is the authoritative source for the bucket sent
    // back to the assessment engine. Do not duplicate clinical thresholds.
    final bucket = preview.classification;
    final answerRes = await _submitAnswer((
      slug: slug,
      sessionId: sessionId,
      questionKey: bmiQuestion.key,
      questionIndex: bmiQuestion.index,
      answer: bucket,
    ));

    await answerRes.fold(
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
        final recorded = _recordAnswer(
          state.answers,
          questionKey: bmiQuestion.key,
          questionIndex: bmiQuestion.index,
          answer: bucket,
        );

        if (result.completed) {
          emit(
            state.copyWith(
              status: AssessmentStatus.completed,
              session: updatedSession,
              answers: recorded,
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
            answers: recorded,
            clearBmiPreview: true,
            clearBmiPreviewInputKey: true,
          ),
        );
      },
    );
  }

  Future<void> _onPreviewBmi(
    PreviewBmiEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    final weightKg = double.tryParse(event.weightKg);
    final heightCm = double.tryParse(event.heightCm);
    if (weightKg == null ||
        heightCm == null ||
        weightKg <= 0 ||
        heightCm <= 0) {
      _onClearBmiPreview(const ClearBmiPreviewEvent(), emit);
      return;
    }
    final requestId = ++_bmiPreviewRequestId;
    final inputKey = _inputKey(weightKg, heightCm);
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
    if (state.status != AssessmentStatus.completed) {
      emit(state.copyWith(status: AssessmentStatus.loading));
    }
    await _loadScoreAndReferral(emit);
  }

  Future<void> _onAlertNavigator(
    AlertNavigatorEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    // Stub: the backend endpoint exists but isn't ported here; the navigator
    // block will surface via the awaiting_call UI once a call is queued.
    // Keeping a placeholder so the button's disabled state can be driven.
  }

  Future<void> _onDownloadReport(
    DownloadReportEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    final slug = _activeSlug;
    final sessionId = _activeSessionId;
    if (slug == null || sessionId == null) return;

    if (event.emailOnly) {
      emit(state.copyWith(reportEmailing: true, clearError: true));
      final res = await _emailReport(
        slug: slug,
        sessionId: sessionId,
        email: event.email.trim(),
      );
      res.fold(
        (f) => emit(
          state.copyWith(
            reportEmailing: false,
            toastType: ToastType.error,
            toastMessage: mapFailure(f),
            toastNonce: state.toastNonce + 1,
          ),
        ),
        (_) => emit(
          state.copyWith(
            reportEmailing: false,
            toastType: ToastType.success,
            toastMessage: 'Report queued for ${event.email}',
            toastNonce: state.toastNonce + 1,
          ),
        ),
      );
      return;
    }

    emit(state.copyWith(reportDownloading: true, clearError: true));
    final res = await _downloadReport(slug: slug, sessionId: sessionId);

    await res.fold<Future<void>>(
      (f) async => emit(
        state.copyWith(
          reportDownloading: false,
          toastType: ToastType.error,
          toastMessage: mapFailure(f),
          toastNonce: state.toastNonce + 1,
        ),
      ),
      (report) async {
        try {
          final dir = await getTemporaryDirectory();
          final filename =
              report.filename ??
              'assessment-report-${DateTime.now().millisecondsSinceEpoch}.pdf';
          final file = File('${dir.path}/$filename');
          await file.writeAsBytes(report.bytes, flush: true);

          final hint = report.passwordHint;
          emit(
            state.copyWith(
              reportDownloading: false,
              toastType: ToastType.success,
              toastMessage: hint != null
                  ? 'Report saved. Password hint: $hint.'
                  : 'Report saved to ${file.path}',
              toastNonce: state.toastNonce + 1,
            ),
          );
        } catch (_) {
          emit(
            state.copyWith(
              reportDownloading: false,
              toastType: ToastType.error,
              toastMessage: 'Could not save the report.',
              toastNonce: state.toastNonce + 1,
            ),
          );
        }
      },
    );
  }

  Future<void> _loadScoreAndReferral(Emitter<AssessmentsState> emit) async {
    final slug = _activeSlug;
    final sessionId = _activeSessionId;
    if (slug == null || sessionId == null) return;

    final scoreRes = await _getScore((slug: slug, sessionId: sessionId));
    final referralRes = await _getReferral(sessionId);
    final canStartRes = await _canStart(slug);

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
            canStart: canStartRes.getOrElse(
              () => const CanStartResult(allowed: false),
            ),
            completionHandled: true,
          ),
        );
      },
    );
  }

  List<AssessmentAnswer> _recordAnswer(
    List<AssessmentAnswer> answers, {
    required String questionKey,
    required int questionIndex,
    required String answer,
  }) {
    final updated =
        answers
            .where((a) => a.questionKey != questionKey)
            .toList(growable: true)
          ..add(
            AssessmentAnswer(
              questionKey: questionKey,
              questionIndex: questionIndex,
              answer: answer,
            ),
          );
    return updated;
  }

  String _inputKey(double weightKg, double heightCm) =>
      '${weightKg.toString()}|${heightCm.toString()}';
}
