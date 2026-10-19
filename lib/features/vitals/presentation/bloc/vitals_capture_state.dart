part of 'vitals_capture_bloc.dart';

enum VitalsCaptureStep {
  idle,
  loadingContent,
  intro,
  pathway,
  bmi,
  reading,
  submitting,
  done,
  error,
}

class VitalsCaptureState extends Equatable {
  final VitalsCaptureKind? kind;
  final VitalsCaptureStep step;
  final VitalsCaptureContent? content;

  final String? pathwayValue;
  final String? providerPlanValue;
  final List<String> treatmentGapValues;
  final String? treatmentGapOther;
  final List<int> dialysisDays;

  final double? weightKg;
  final double? heightCm;
  final double? bmi;

  final VitalsCaptureResult? result;
  final Referral? referral;

  final String? errorMessage;

  const VitalsCaptureState({
    this.kind,
    this.step = VitalsCaptureStep.idle,
    this.content,
    this.pathwayValue,
    this.providerPlanValue,
    this.treatmentGapValues = const [],
    this.treatmentGapOther,
    this.dialysisDays = const [],
    this.weightKg,
    this.heightCm,
    this.bmi,
    this.result,
    this.referral,
    this.errorMessage,
  });

  VitalsCaptureState copyWith({
    VitalsCaptureKind? kind,
    VitalsCaptureStep? step,
    VitalsCaptureContent? content,
    String? pathwayValue,
    String? providerPlanValue,
    List<String>? treatmentGapValues,
    String? treatmentGapOther,
    List<int>? dialysisDays,
    double? weightKg,
    double? heightCm,
    double? bmi,
    VitalsCaptureResult? result,
    Referral? referral,
    String? errorMessage,
    bool clearProviderPlan = false,
    bool clearError = false,
  }) => VitalsCaptureState(
    kind: kind ?? this.kind,
    step: step ?? this.step,
    content: content ?? this.content,
    pathwayValue: pathwayValue ?? this.pathwayValue,
    providerPlanValue: clearProviderPlan
        ? null
        : (providerPlanValue ?? this.providerPlanValue),
    treatmentGapValues: treatmentGapValues ?? this.treatmentGapValues,
    treatmentGapOther: treatmentGapOther ?? this.treatmentGapOther,
    dialysisDays: dialysisDays ?? this.dialysisDays,
    weightKg: weightKg ?? this.weightKg,
    heightCm: heightCm ?? this.heightCm,
    bmi: bmi ?? this.bmi,
    result: result ?? this.result,
    referral: referral ?? this.referral,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  /// True when the currently selected pathway needs a provider-plan
  /// follow-up question.
  bool get needsProviderPlan {
    final v = pathwayValue;
    return v == 'provider_directed';
  }

  bool get needsTreatmentGap {
    final v = pathwayValue;
    return v == 'diagnosed_not_on_medication';
  }

  bool get needsDialysisDays => pathwayValue == 'kidney_dialysis';

  bool get pathwayCanContinue {
    if (pathwayValue == null) return false;
    if (needsProviderPlan && providerPlanValue == null) return false;
    if (needsTreatmentGap && treatmentGapValues.isEmpty) return false;
    if (needsDialysisDays && dialysisDays.isEmpty) return false;
    return true;
  }

  @override
  List<Object?> get props => [
    kind,
    step,
    content,
    pathwayValue,
    providerPlanValue,
    treatmentGapValues,
    treatmentGapOther,
    dialysisDays,
    weightKg,
    heightCm,
    bmi,
    result,
    referral,
    errorMessage,
  ];
}
