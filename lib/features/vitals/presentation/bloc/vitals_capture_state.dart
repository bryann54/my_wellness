part of 'vitals_capture_bloc.dart';

enum VitalsCaptureStep {
  idle,
  loadingContent,
  intro,
  pathway,
  bmi,
  reading,
  submitting,
  awaitingSecondReading,
  awaitingWellbeing,
  completed,
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
  final VitalsAccess? access;
  final bool accessLoading;

  final String? previewClassification;
  final bool previewLoading;

  final List<Map<String, dynamic>> facilityCandidates;
  final List<String> requiredServices;
  final String? facilityReason;
  final bool candidatesLoading;
  final bool bookingReferral;

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
    this.access,
    this.accessLoading = false,
    this.previewClassification,
    this.previewLoading = false,
    this.facilityCandidates = const [],
    this.requiredServices = const [],
    this.facilityReason,
    this.candidatesLoading = false,
    this.bookingReferral = false,
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
    VitalsAccess? access,
    bool? accessLoading,
    String? previewClassification,
    bool? previewLoading,
    List<Map<String, dynamic>>? facilityCandidates,
    List<String>? requiredServices,
    String? facilityReason,
    bool? candidatesLoading,
    bool? bookingReferral,
    String? errorMessage,
    bool clearProviderPlan = false,
    bool clearError = false,
    bool clearPreview = false,
    bool clearCandidates = false,
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
    access: access ?? this.access,
    accessLoading: accessLoading ?? this.accessLoading,
    previewClassification: clearPreview
        ? null
        : (previewClassification ?? this.previewClassification),
    previewLoading: previewLoading ?? this.previewLoading,
    facilityCandidates: clearCandidates
        ? const []
        : (facilityCandidates ?? this.facilityCandidates),
    requiredServices: clearCandidates
        ? const []
        : (requiredServices ?? this.requiredServices),
    facilityReason: clearCandidates
        ? null
        : (facilityReason ?? this.facilityReason),
    candidatesLoading: candidatesLoading ?? this.candidatesLoading,
    bookingReferral: bookingReferral ?? this.bookingReferral,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
  bool get needsProviderPlan {
    final v = pathwayValue;
    return v == 'provider_directed';
  }

  bool get needsTreatmentGap {
    final v = pathwayValue;
    return v == 'diagnosed_not_on_medication';
  }

  bool get needsDialysisDays => pathwayValue == 'kidney_dialysis';

  bool get isDialysisDayToday =>
      (content?.pathway.dialysisDaysQuestion != null) &&
      dialysisDays.isNotEmpty;

  bool get pathwayCanContinue {
    return pathwayValue != null;
  }

  bool get followupCanContinue =>
      (!needsProviderPlan || providerPlanValue != null) &&
      (!needsTreatmentGap || treatmentGapValues.isNotEmpty) &&
      (!needsDialysisDays || dialysisDays.isNotEmpty);

  String? get effectiveReadingId =>
      result?.thirdReading?.id ??
      result?.secondReading?.id ??
      result?.firstReading?.id;
  bool get needsManualFacilityBooking =>
      pathwayValue == 'routine' &&
      (result?.finalCta == 'visit_health_facility' ||
          result?.finalCta == 'visit_health_facility_now' ||
          result?.finalCta == 'go_to_hospital_immediately');

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
    access,
    accessLoading,
    previewClassification,
    previewLoading,
    facilityCandidates,
    requiredServices,
    facilityReason,
    candidatesLoading,
    bookingReferral,
    errorMessage,
  ];
}
