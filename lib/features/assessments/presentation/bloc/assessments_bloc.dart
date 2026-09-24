import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_answer.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_definition.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/domain/entities/bmi_preview.dart';
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
  final GetAssessmentAnswersUseCase _getAnswers;
  final SubmitAssessmentAnswerUseCase _submitAnswer;
  final SubmitAssessmentBmiUseCase _submitBmi;
  final GetAssessmentScoreUseCase _getScore;
  final PreviewBmiUseCase _previewBmi;
  final AccountBloc _accountBloc;

  String? _activeSlug;
  String? _activeSessionId;

  AssessmentsBloc(
    this._getAccess,
    this._listAssessments,
    this._canStart,
    this._getDefinition,
    this._startSession,
    this._getAnswers,
    this._submitAnswer,
    this._submitBmi,
    this._getScore,
    this._previewBmi,
     this._accountBloc,
  ) : super(const AssessmentsState()) {
    on<LoadAssessmentsEvent>(_onLoad);
    on<StartAssessmentsEvent>(_onStart);
    on<ResumeAssessmentsEvent>(_onResume);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<SubmitBmiEvent>(_onSubmitBmi);
    on<PreviewBmiEvent>(_onPreviewBmi);
    on<ClearBmiPreviewEvent>(
      (_, emit) => emit(state.copyWith(clearBmiPreview: true)),
    );
    on<FetchScoreEvent>(_onFetchScore);
    on<ResetAssessmentsEvent>((_, emit) {
      _activeSlug = null;
      _activeSessionId = null;
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

    // Read gender from the health profile (falls back to null → show all).
    final userGender = _accountBloc.state.profile?.gender;

    final visible = all
        .where((a) => a.isVisibleFor(userGender))
        .toList(growable: false);

    emit(
      state.copyWith(
        status: AssessmentStatus.ready,
        access: access,
        assessments: visible,
      ),
    );
  }

Future<void> _onStart(
    StartAssessmentsEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AssessmentStatus.loading,
        clearError: true,
        terminated: false,
        terminationReference: null,
        clearBmiPreview: true,
      ),
    );

    _activeSlug = event.slug;

    // 1. Can-start gate
    final canStartRes = await _canStart(event.slug);
    final canStart = canStartRes.fold(
      (_) => const CanStartResult(allowed: false),
      (r) => r,
    );
    if (!canStart.allowed) {
      emit(
        state.copyWith(status: AssessmentStatus.ready, alreadyCompleted: true),
      );
      return;
    }
    final defRes = await _getDefinition(event.slug);
    final sessionRes = await _startSession(event.slug);

    // 3. Surface the first failure
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

    // 4. Unwrap
    final def = defRes.getOrElse(() => throw StateError('definition missing'));
    final session = sessionRes.getOrElse(
      () => throw StateError('session missing'),
    );
    _activeSessionId = session.id;

    // 5. Load any existing answers (for resume)
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
    emit(state.copyWith(status: AssessmentStatus.loading, clearError: true));
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
        definition: defRes.getOrElse(
          () => throw StateError('definition missing'),
        ),
        answers: answersRes.getOrElse(() => const <AssessmentAnswer>[]),
      ),
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
      (f) async => emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (result) async {
        if (result.terminate) {
          emit(
            state.copyWith(
              status: AssessmentStatus.ready,
              terminated: true,
              terminationReference: result.reference,
              session: state.session?.applyResult(result),
            ),
          );
          return;
        }
        if (result.completed) {
          emit(
            state.copyWith(
              status: AssessmentStatus.completed,
              session: state.session?.applyResult(result),
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            status: AssessmentStatus.ready,
            session: state.session?.applyResult(result),
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

    final res = await _submitBmi((
      slug: slug,
      sessionId: sessionId,
      weightKg: event.weightKg,
      heightCm: event.heightCm,
    ));

    await res.fold(
      (f) async => emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (ok) async {
        if (!ok) {
          emit(
            state.copyWith(
              status: AssessmentStatus.error,
              errorMessage: 'BMI could not be saved.',
            ),
          );
          return;
        }
        emit(
          state.copyWith(status: AssessmentStatus.ready, clearBmiPreview: true),
        );
      },
    );
  }

  Future<void> _onPreviewBmi(
    PreviewBmiEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    final res = await _previewBmi((
      weightKg: event.weightKg,
      heightCm: event.heightCm,
    ));
    res.fold((_) {}, (preview) => emit(state.copyWith(bmiPreview: preview)));
  }

  Future<void> _onFetchScore(
    FetchScoreEvent event,
    Emitter<AssessmentsState> emit,
  ) async {
    final slug = _activeSlug;
    final sessionId = _activeSessionId;
    if (slug == null || sessionId == null) return;

    emit(state.copyWith(status: AssessmentStatus.loading));

    final res = await _getScore((slug: slug, sessionId: sessionId));
    res.fold(
      (f) => emit(
        state.copyWith(
          status: AssessmentStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (score) => emit(
        state.copyWith(status: AssessmentStatus.completed, score: score),
      ),
    );
  }
}
