part of 'vitals_capture_bloc.dart';

abstract class VitalsCaptureEvent extends Equatable {
  const VitalsCaptureEvent();
  @override
  List<Object?> get props => [];
}

class StartVitalsCaptureEvent extends VitalsCaptureEvent {
  final VitalsCaptureKind kind;
  const StartVitalsCaptureEvent(this.kind);
  @override
  List<Object?> get props => [kind];
}

class CaptureContinueFromIntroEvent extends VitalsCaptureEvent {
  const CaptureContinueFromIntroEvent();
}

class SelectPathwayEvent extends VitalsCaptureEvent {
  final String value;
  const SelectPathwayEvent(this.value);
  @override
  List<Object?> get props => [value];
}

class SelectProviderPlanEvent extends VitalsCaptureEvent {
  final String value;
  const SelectProviderPlanEvent(this.value);
  @override
  List<Object?> get props => [value];
}

class ToggleTreatmentGapEvent extends VitalsCaptureEvent {
  final String value;
  const ToggleTreatmentGapEvent(this.value);
  @override
  List<Object?> get props => [value];
}

class SetTreatmentGapOtherEvent extends VitalsCaptureEvent {
  final String text;
  const SetTreatmentGapOtherEvent(this.text);
  @override
  List<Object?> get props => [text];
}

class ToggleDialysisDayEvent extends VitalsCaptureEvent {
  final int day;
  const ToggleDialysisDayEvent(this.day);
  @override
  List<Object?> get props => [day];
}

class CaptureContinueFromPathwayEvent extends VitalsCaptureEvent {
  const CaptureContinueFromPathwayEvent();
}

class ConfirmBmiEvent extends VitalsCaptureEvent {
  final double weightKg;
  final double heightCm;
  final double bmi;
  const ConfirmBmiEvent({
    required this.weightKg,
    required this.heightCm,
    required this.bmi,
  });
  @override
  List<Object?> get props => [weightKg, heightCm, bmi];
}

class SubmitVitalsReadingEvent extends VitalsCaptureEvent {
  final Map<String, dynamic> readingPayload;
  const SubmitVitalsReadingEvent(this.readingPayload);
  @override
  List<Object?> get props => [readingPayload];
}

class CancelVitalsCaptureEvent extends VitalsCaptureEvent {
  const CancelVitalsCaptureEvent();
}
