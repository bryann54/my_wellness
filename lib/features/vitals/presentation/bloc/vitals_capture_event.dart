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

class SubmitVitalsSecondReadingEvent extends VitalsCaptureEvent {
  final Map<String, dynamic> readingPayload;
  const SubmitVitalsSecondReadingEvent(this.readingPayload);
  @override
  List<Object?> get props => [readingPayload];
}

class AnswerWellbeingEvent extends VitalsCaptureEvent {
  final bool answer;
  const AnswerWellbeingEvent(this.answer);
  @override
  List<Object?> get props => [answer];
}

class CancelVitalsCaptureEvent extends VitalsCaptureEvent {
  const CancelVitalsCaptureEvent();
}

// Preview
class PreviewBpEvent extends VitalsCaptureEvent {
  final int systolic;
  final int diastolic;
  const PreviewBpEvent({required this.systolic, required this.diastolic});
  @override
  List<Object?> get props => [systolic, diastolic];
}

class PreviewBsEvent extends VitalsCaptureEvent {
  final String value;
  final String unit;
  final String readingType;
  final String? mealTiming;
  const PreviewBsEvent({
    required this.value,
    required this.unit,
    required this.readingType,
    this.mealTiming,
  });
  @override
  List<Object?> get props => [value, unit, readingType, mealTiming];
}

class ClearPreviewEvent extends VitalsCaptureEvent {
  const ClearPreviewEvent();
}

// Access gate
class LoadVitalsAccessEvent extends VitalsCaptureEvent {
  const LoadVitalsAccessEvent();
}

class AlertNavigatorEvent extends VitalsCaptureEvent {
  const AlertNavigatorEvent();
}

// Facility candidates / referral booking
class LoadFacilityCandidatesEvent extends VitalsCaptureEvent {
  final double? userLat;
  final double? userLng;
  const LoadFacilityCandidatesEvent({this.userLat, this.userLng});
  @override
  List<Object?> get props => [userLat, userLng];
}

class BookReferralEvent extends VitalsCaptureEvent {
  final String? facilityId;
  final double? userLat;
  final double? userLng;
  const BookReferralEvent({this.facilityId, this.userLat, this.userLng});
  @override
  List<Object?> get props => [facilityId, userLat, userLng];
}
