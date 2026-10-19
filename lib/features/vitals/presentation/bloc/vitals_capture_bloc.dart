import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
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

  VitalsCaptureBloc(this._getContent, this._createSession, this._getReferral)
    : super(const VitalsCaptureState()) {
    on<StartVitalsCaptureEvent>(_onStart);
    on<CaptureContinueFromIntroEvent>(_onContinueIntro);
    on<SelectPathwayEvent>(_onSelectPathway);
    on<SelectProviderPlanEvent>(_onSelectProviderPlan);
    on<ToggleTreatmentGapEvent>(_onToggleTreatmentGap);
    on<SetTreatmentGapOtherEvent>(_onSetTreatmentGapOther);
    on<ToggleDialysisDayEvent>(_onToggleDialysisDay);
    on<CaptureContinueFromPathwayEvent>(_onContinuePathway);
    on<ConfirmBmiEvent>(_onConfirmBmi);
    on<SubmitVitalsReadingEvent>(_onSubmitReading);
    on<CancelVitalsCaptureEvent>((_, emit) => emit(const VitalsCaptureState()));
  }

  Future<void> _onStart(
    StartVitalsCaptureEvent event,
    Emitter<VitalsCaptureState> emit,
  ) async {
    emit(
      VitalsCaptureState(
        kind: event.kind,
        step: VitalsCaptureStep.loadingContent,
      ),
    );

    final res = await _getContent(event.kind);
    res.fold(
      (f) => emit(
        state.copyWith(
          step: VitalsCaptureStep.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (content) =>
          emit(state.copyWith(step: VitalsCaptureStep.intro, content: content)),
    );
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

  Future<void> _onSubmitReading(
    SubmitVitalsReadingEvent event,
    Emitter<VitalsCaptureState> emit,
  ) async {
    emit(state.copyWith(step: VitalsCaptureStep.submitting));

    final payload = <String, dynamic>{...event.readingPayload};

    final res = await _createSession((kind: state.kind!, payload: payload));

    await res.fold(
      (f) async => emit(
        state.copyWith(
          step: VitalsCaptureStep.reading,
          errorMessage: mapFailure(f),
        ),
      ),
      (result) async {
        emit(state.copyWith(step: VitalsCaptureStep.done, result: result));

        // Kick the referral fetch off the critical path. We capture the
        // current kind locally so a cancel/reset can't leak into this
        // closure's reference to `state`.
        final readingId = result.firstReading?.id;
        if (readingId != null) {
          _fetchReferralInBackground(
            kind: state.kind!,
            readingId: readingId,
            emit: emit,
          );
        }
      },
    );
  }

  Future<void> _fetchReferralInBackground({
    required VitalsCaptureKind kind,
    required String readingId,
    required Emitter<VitalsCaptureState> emit,
  }) async {
    final res = await _getReferral((kind: kind, readingId: readingId));
    if (emit.isDone) return;
    res.fold(
      (_) => null,
      (referral) => emit(state.copyWith(referral: referral)),
    );
  }
}
