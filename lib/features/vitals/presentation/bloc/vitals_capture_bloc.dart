import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_access.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_capture_content.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_capture_result.dart';
import 'package:my_wellness/features/vitals/domain/usecases/vitals_capture_usecases.dart';

part 'vitals_capture_event.dart';
part 'vitals_capture_state.dart';

@injectable
class VitalsCaptureBloc extends Bloc<VitalsCaptureEvent, VitalsCaptureState> {
  final GetVitalsCaptureContentUseCase _getContent;
  final CreateVitalsSessionUseCase _createSession;
  final GetVitalsReferralUseCase _getReferral;
  final GetVitalsAccessUseCase _getAccess;
  final AlertVitalsNavigatorUseCase _alertNavigator;
  final ClassifyVitalsPreviewUseCase _classifyPreview;
  final GetMonitoringProfileUseCase _getMonitoringProfile;
  final SetMonitoringProfileUseCase _setMonitoringProfile;
  final AddVitalsSecondReadingUseCase _addSecondReading;
  final AddVitalsWellbeingUseCase _addWellbeing;
  final GetReferralFacilityCandidatesUseCase _getFacilityCandidates;
  final CreateReferralFromReadingUseCase _createReferral;

  final Map<VitalsCaptureKind, VitalsCaptureContent> _contentCache = {};
  final Set<VitalsCaptureKind> _loadingKinds = {};

  VitalsCaptureBloc(
    this._getContent,
    this._createSession,
    this._getReferral,
    this._getAccess,
    this._alertNavigator,
    this._classifyPreview,
    this._getMonitoringProfile,
    this._setMonitoringProfile,
    this._addSecondReading,
    this._addWellbeing,
    this._getFacilityCandidates,
    this._createReferral,
  ) : super(const VitalsCaptureState()) {
    on<StartVitalsCaptureEvent>(_onStart);
    on<CaptureContinueFromIntroEvent>(_onContinueIntro);
    on<SelectPathwayEvent>(_onSelectPathway);
    on<SelectProviderPlanEvent>(_onSelectProviderPlan);
    on<ToggleTreatmentGapEvent>(_onToggleTreatmentGap);
    on<SetTreatmentGapOtherEvent>(_onSetTreatmentGapOther);
    on<ToggleDialysisDayEvent>(_onToggleDialysisDay);
    on<CaptureContinueFromPathwayEvent>(_onContinuePathway);
    on<ConfirmBmiEvent>(_onConfirmBmi);
    on<SkipBmiEvent>(
      (_, emit) => emit(state.copyWith(step: VitalsCaptureStep.reading)),
    );
    on<SubmitVitalsReadingEvent>(_onSubmitReading);
    on<SubmitVitalsSecondReadingEvent>(_onSubmitSecondReading);
    on<AnswerWellbeingEvent>(_onAnswerWellbeing);
    on<CancelVitalsCaptureEvent>((_, emit) => emit(const VitalsCaptureState()));
    on<PreviewBpEvent>(_onPreviewBp);
    on<PreviewBsEvent>(_onPreviewBs);
    on<ClearPreviewEvent>(
      (_, emit) => emit(state.copyWith(clearPreview: true)),
    );
    on<LoadVitalsAccessEvent>(_onLoadAccess);
    on<AlertNavigatorEvent>(_onAlertNavigator);
    on<LoadFacilityCandidatesEvent>(_onLoadFacilityCandidates);
    on<BookReferralEvent>(_onBookReferral);
  }

  Future<void> _onStart(
    StartVitalsCaptureEvent event,
    Emitter<VitalsCaptureState> emit,
  ) async {
    // Refresh access first — cheap and authoritative.
    final accessRes = await _getAccess(NoParams());
    accessRes.fold((_) {}, (a) => emit(state.copyWith(access: a)));

    final profileRes = await _getMonitoringProfile(event.kind);
    final profile = profileRes.getOrElse(() => const <String, dynamic>{});
    final existingPathway = (profile['pathway'] as String?)?.trim();

    final cached = _contentCache[event.kind];
    if (cached != null) {
      emit(
        VitalsCaptureState(
          kind: event.kind,
          step: VitalsCaptureStep.pathway,
          content: cached,
          access: state.access,
          pathwayValue: existingPathway?.isEmpty == false
              ? existingPathway
              : null,
        ),
      );
      return;
    }
    if (!_loadingKinds.add(event.kind)) return;

    emit(
      VitalsCaptureState(
        kind: event.kind,
        step: VitalsCaptureStep.loadingContent,
        access: state.access,
        pathwayValue: existingPathway?.isEmpty == false
            ? existingPathway
            : null,
      ),
    );

    try {
      final res = await _getContent(event.kind);
      res.fold(
        (f) {
          if (state.kind == event.kind) {
            emit(
              state.copyWith(
                step: VitalsCaptureStep.error,
                errorMessage: mapFailure(f),
              ),
            );
          }
        },
        (content) {
          _contentCache[event.kind] = content;
          if (state.kind == event.kind) {
            emit(
              state.copyWith(step: VitalsCaptureStep.pathway, content: content),
            );
          }
        },
      );
    } finally {
      _loadingKinds.remove(event.kind);
    }
  }

  void _onContinueIntro(_, Emitter<VitalsCaptureState> emit) {
    emit(state.copyWith(step: VitalsCaptureStep.pathway));
  }

  void _onSelectPathway(
    SelectPathwayEvent event,
    Emitter<VitalsCaptureState> emit,
  ) {
    emit(
      state.copyWith(
        pathwayValue: event.value,
        clearProviderPlan: true,
        treatmentGapValues: const [],
        treatmentGapOther: null,
        dialysisDays: const [],
      ),
    );
  }

  void _onSelectProviderPlan(
    SelectProviderPlanEvent event,
    Emitter<VitalsCaptureState> emit,
  ) {
    emit(state.copyWith(providerPlanValue: event.value));
  }

  void _onToggleTreatmentGap(
    ToggleTreatmentGapEvent event,
    Emitter<VitalsCaptureState> emit,
  ) {
    final next = [...state.treatmentGapValues];
    if (next.contains(event.value)) {
      next.remove(event.value);
    } else {
      next.add(event.value);
    }
    emit(state.copyWith(treatmentGapValues: next));
  }

  void _onSetTreatmentGapOther(
    SetTreatmentGapOtherEvent event,
    Emitter<VitalsCaptureState> emit,
  ) {
    emit(state.copyWith(treatmentGapOther: event.text));
  }

  void _onToggleDialysisDay(
    ToggleDialysisDayEvent event,
    Emitter<VitalsCaptureState> emit,
  ) {
    final next = [...state.dialysisDays];
    if (next.contains(event.day)) {
      next.remove(event.day);
    } else if (next.length < 3) {
      next.add(event.day);
    }
    emit(state.copyWith(dialysisDays: next));
  }

  void _onContinuePathway(_, Emitter<VitalsCaptureState> emit) {
    emit(state.copyWith(step: VitalsCaptureStep.bmi));
  }

  void _onConfirmBmi(ConfirmBmiEvent event, Emitter<VitalsCaptureState> emit) {
    emit(
      state.copyWith(
        weightKg: event.weightKg,
        heightCm: event.heightCm,
        bmi: event.bmi,
        step: VitalsCaptureStep.reading,
      ),
    );
  }

  Future<void> _persistPathway(VitalsCaptureKind kind) async {
    final pathway = state.pathwayValue;
    if (pathway == null) return;
    final payload = <String, dynamic>{'pathway': pathway};
    if (state.providerPlanValue != null) {
      payload['provider_plan'] = state.providerPlanValue;
    }
    if (state.treatmentGapValues.isNotEmpty) {
      payload['treatment_gap_reasons'] = state.treatmentGapValues;
    }
    if (state.treatmentGapOther != null &&
        state.treatmentGapOther!.trim().isNotEmpty) {
      payload['treatment_gap_other_text'] = state.treatmentGapOther!.trim();
    }
    if (state.dialysisDays.isNotEmpty) {
      payload['dialysis_days'] = state.dialysisDays;
    }
    await _setMonitoringProfile((kind: kind, payload: payload));
  }

  Future<void> _onSubmitReading(
    SubmitVitalsReadingEvent event,
    Emitter<VitalsCaptureState> emit,
  ) async {
    emit(state.copyWith(step: VitalsCaptureStep.submitting, clearError: true));

    final kind = state.kind!;
    final payload = <String, dynamic>{
      ...event.readingPayload,
      if (state.weightKg != null) 'weight_kg': state.weightKg,
      if (state.heightCm != null) 'height_cm': state.heightCm,
    };

    // Persist pathway before creating the session so the server knows
    // the pathway when validating dialysis-day rules.
    await _persistPathway(kind);

    final res = await _createSession((kind: kind, payload: payload));

    await res.fold(
      (f) async => emit(
        state.copyWith(
          step: VitalsCaptureStep.reading,
          errorMessage: mapFailure(f),
        ),
      ),
      (result) async {
        _routeFromServerStatus(result, emit);

        // Only auto-fetch referral for non-Pathway-A pathways. Pathway A
        // uses the manual facility picker instead.
        if (kind == VitalsCaptureKind.bp &&
            state.pathwayValue != null &&
            state.pathwayValue != 'routine') {
          _fetchReferralInBackground(
            kind: kind,
            readingId: result.firstReading?.id,
            emit: emit,
          );
        }
      },
    );
  }

  void _routeFromServerStatus(
    VitalsCaptureResult result,
    Emitter<VitalsCaptureState> emit,
  ) {
    switch (result.status) {
      case 'awaiting_second_reading':
        emit(
          state.copyWith(
            step: VitalsCaptureStep.awaitingSecondReading,
            result: result,
          ),
        );
        return;
      case 'awaiting_wellbeing':
        emit(
          state.copyWith(
            step: VitalsCaptureStep.awaitingWellbeing,
            result: result,
          ),
        );
        return;
      case 'completed':
      default:
        emit(state.copyWith(step: VitalsCaptureStep.done, result: result));
        return;
    }
  }

  Future<void> _onSubmitSecondReading(
    SubmitVitalsSecondReadingEvent event,
    Emitter<VitalsCaptureState> emit,
  ) async {
    final sessionId = state.result?.id;
    if (sessionId == null) return;

    emit(state.copyWith(step: VitalsCaptureStep.submitting, clearError: true));

    final res = await _addSecondReading((
      sessionId: sessionId,
      payload: event.readingPayload,
    ));

    res.fold(
      (f) => emit(
        state.copyWith(
          step: VitalsCaptureStep.awaitingSecondReading,
          errorMessage: mapFailure(f),
        ),
      ),
      (result) => _routeFromServerStatus(result, emit),
    );
  }

  Future<void> _onAnswerWellbeing(
    AnswerWellbeingEvent event,
    Emitter<VitalsCaptureState> emit,
  ) async {
    final sessionId = state.result?.id;
    if (sessionId == null) return;

    emit(state.copyWith(step: VitalsCaptureStep.submitting, clearError: true));

    final res = await _addWellbeing((
      sessionId: sessionId,
      answer: event.answer,
    ));

    res.fold(
      (f) => emit(
        state.copyWith(
          step: VitalsCaptureStep.awaitingWellbeing,
          errorMessage: mapFailure(f),
        ),
      ),
      (result) => _routeFromServerStatus(result, emit),
    );
  }

  Future<void> _fetchReferralInBackground({
    required VitalsCaptureKind kind,
    required String? readingId,
    required Emitter<VitalsCaptureState> emit,
  }) async {
    if (readingId == null) return;
    final res = await _getReferral((kind: kind, readingId: readingId));
    if (emit.isDone) return;
    res.fold((_) => null, (referral) {
      if (referral != null) emit(state.copyWith(referral: referral));
    });
  }

  Future<void> _onPreviewBp(
    PreviewBpEvent event,
    Emitter<VitalsCaptureState> emit,
  ) async {
    emit(state.copyWith(previewLoading: true));
    final res = await _classifyPreview({
      'systolic': event.systolic,
      'diastolic': event.diastolic,
    });
    if (emit.isDone) return;
    res.fold(
      (_) => emit(state.copyWith(previewLoading: false)),
      (classification) => emit(
        state.copyWith(
          previewLoading: false,
          previewClassification: classification,
        ),
      ),
    );
  }

  Future<void> _onPreviewBs(
    PreviewBsEvent event,
    Emitter<VitalsCaptureState> emit,
  ) async {
    emit(state.copyWith(previewLoading: true));
    final payload = <String, dynamic>{
      'value': double.tryParse(event.value) ?? 0,
      if (event.readingType != 'hba1c') 'unit': event.unit,
      'reading_type': event.readingType,
      if (event.mealTiming != null) 'meal_timing': event.mealTiming,
    };
    final res = await _classifyPreview(payload);
    if (emit.isDone) return;
    res.fold(
      (_) => emit(state.copyWith(previewLoading: false)),
      (classification) => emit(
        state.copyWith(
          previewLoading: false,
          previewClassification: classification,
        ),
      ),
    );
  }

  Future<void> _onLoadAccess(
    LoadVitalsAccessEvent event,
    Emitter<VitalsCaptureState> emit,
  ) async {
    emit(state.copyWith(accessLoading: true));
    final res = await _getAccess(NoParams());
    if (emit.isDone) return;
    res.fold(
      (_) => emit(state.copyWith(accessLoading: false)),
      (access) => emit(state.copyWith(accessLoading: false, access: access)),
    );
  }

  Future<void> _onAlertNavigator(
    AlertNavigatorEvent event,
    Emitter<VitalsCaptureState> emit,
  ) async {
    final res = await _alertNavigator(NoParams());
    if (emit.isDone) return;
    res.fold(
      (f) => emit(state.copyWith(errorMessage: mapFailure(f))),
      (access) => emit(state.copyWith(access: access)),
    );
  }

  Future<void> _onLoadFacilityCandidates(
    LoadFacilityCandidatesEvent event,
    Emitter<VitalsCaptureState> emit,
  ) async {
    final kind = state.kind;
    final readingId = state.effectiveReadingId;
    if (kind == null || readingId == null) return;

    emit(state.copyWith(candidatesLoading: true, clearCandidates: true));
    final res = await _getFacilityCandidates((
      kind: kind,
      readingId: readingId,
      userLat: event.userLat,
      userLng: event.userLng,
    ));
    if (emit.isDone) return;
    res.fold(
      (f) => emit(
        state.copyWith(candidatesLoading: false, errorMessage: mapFailure(f)),
      ),
      (data) => emit(
        state.copyWith(
          candidatesLoading: false,
          facilityCandidates: data.candidates,
          requiredServices: data.requiredServices,
          facilityReason: data.reason,
        ),
      ),
    );
  }

  Future<void> _onBookReferral(
    BookReferralEvent event,
    Emitter<VitalsCaptureState> emit,
  ) async {
    final kind = state.kind;
    final readingId = state.effectiveReadingId;
    if (kind == null || readingId == null) return;

    emit(state.copyWith(bookingReferral: true, clearError: true));
    final res = await _createReferral((
      kind: kind,
      readingId: readingId,
      userLat: event.userLat,
      userLng: event.userLng,
      facilityId: event.facilityId,
    ));
    if (emit.isDone) return;
    res.fold(
      (f) => emit(
        state.copyWith(bookingReferral: false, errorMessage: mapFailure(f)),
      ),
      (referral) =>
          emit(state.copyWith(bookingReferral: false, referral: referral)),
    );
  }
}
