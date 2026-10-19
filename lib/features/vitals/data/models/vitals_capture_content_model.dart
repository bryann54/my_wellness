import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_capture_content.dart';

part 'vitals_capture_content_model.g.dart';

@JsonSerializable(explicitToJson: true)
class VitalsCaptureContentModel {
  final VitalsOnboardingModel onboarding;
  final VitalsPathwayModel pathway;

  const VitalsCaptureContentModel({
    required this.onboarding,
    required this.pathway,
  });

  factory VitalsCaptureContentModel.fromJson(Map<String, dynamic> json) =>
      _$VitalsCaptureContentModelFromJson(json);

  Map<String, dynamic> toJson() => _$VitalsCaptureContentModelToJson(this);

  VitalsCaptureContent toEntity() => VitalsCaptureContent(
    onboarding: onboarding.toEntity(),
    pathway: pathway.toEntity(),
  );
}

@JsonSerializable(explicitToJson: true)
class VitalsOnboardingModel {
  final VitalsOnboardingIntroModel intro;
  final VitalsOnboardingTipsModel tips;

  const VitalsOnboardingModel({required this.intro, required this.tips});

  factory VitalsOnboardingModel.fromJson(Map<String, dynamic> json) =>
      _$VitalsOnboardingModelFromJson(json);

  Map<String, dynamic> toJson() => _$VitalsOnboardingModelToJson(this);

  VitalsOnboarding toEntity() =>
      VitalsOnboarding(intro: intro.toEntity(), tips: tips.toEntity());
}

@JsonSerializable()
class VitalsOnboardingIntroModel {
  final String title;
  final String heading;
  final List<String> paragraphs;

  const VitalsOnboardingIntroModel({
    required this.title,
    required this.heading,
    required this.paragraphs,
  });

  factory VitalsOnboardingIntroModel.fromJson(Map<String, dynamic> json) =>
      _$VitalsOnboardingIntroModelFromJson(json);

  Map<String, dynamic> toJson() => _$VitalsOnboardingIntroModelToJson(this);

  VitalsOnboardingIntro toEntity() => VitalsOnboardingIntro(
    title: title,
    heading: heading,
    paragraphs: paragraphs,
  );
}

@JsonSerializable()
class VitalsOnboardingTipsModel {
  final String title;
  final String intro;
  final List<String> items;

  const VitalsOnboardingTipsModel({
    required this.title,
    required this.intro,
    required this.items,
  });

  factory VitalsOnboardingTipsModel.fromJson(Map<String, dynamic> json) =>
      _$VitalsOnboardingTipsModelFromJson(json);

  Map<String, dynamic> toJson() => _$VitalsOnboardingTipsModelToJson(this);

  VitalsOnboardingTips toEntity() =>
      VitalsOnboardingTips(title: title, intro: intro, items: items);
}

@JsonSerializable(explicitToJson: true)
class VitalsPathwayModel {
  @JsonKey(name: 'pathway_question')
  final String pathwayQuestion;

  @JsonKey(name: 'pathway_options')
  final List<VitalsPathwayOptionModel> pathwayOptions;

  @JsonKey(name: 'provider_plan_question')
  final String? providerPlanQuestion;

  @JsonKey(name: 'provider_plan_options')
  final List<VitalsPathwayOptionModel> providerPlanOptions;

  @JsonKey(name: 'treatment_gap_question')
  final String? treatmentGapQuestion;

  @JsonKey(name: 'treatment_gap_hint')
  final String? treatmentGapHint;

  @JsonKey(name: 'treatment_gap_options')
  final List<VitalsPathwayOptionModel> treatmentGapOptions;

  @JsonKey(name: 'treatment_gap_other_hint')
  final String? treatmentGapOtherHint;

  @JsonKey(name: 'medication_step')
  final VitalsMedicationStepModel? medicationStep;

  @JsonKey(name: 'dialysis_days_question')
  final String? dialysisDaysQuestion;

  @JsonKey(name: 'dialysis_days_hint')
  final String? dialysisDaysHint;

  @JsonKey(name: 'day_options')
  final List<VitalsPathwayOptionModel> dayOptions;

  const VitalsPathwayModel({
    required this.pathwayQuestion,
    required this.pathwayOptions,
    this.providerPlanQuestion,
    this.providerPlanOptions = const [],
    this.treatmentGapQuestion,
    this.treatmentGapHint,
    this.treatmentGapOptions = const [],
    this.treatmentGapOtherHint,
    this.medicationStep,
    this.dialysisDaysQuestion,
    this.dialysisDaysHint,
    this.dayOptions = const [],
  });

  factory VitalsPathwayModel.fromJson(Map<String, dynamic> json) =>
      _$VitalsPathwayModelFromJson(json);

  Map<String, dynamic> toJson() => _$VitalsPathwayModelToJson(this);

  VitalsPathway toEntity() => VitalsPathway(
    pathwayQuestion: pathwayQuestion,
    pathwayOptions: pathwayOptions.map((o) => o.toEntity()).toList(),
    providerPlanQuestion: providerPlanQuestion,
    providerPlanOptions: providerPlanOptions.map((o) => o.toEntity()).toList(),
    treatmentGapQuestion: treatmentGapQuestion,
    treatmentGapHint: treatmentGapHint,
    treatmentGapOptions: treatmentGapOptions.map((o) => o.toEntity()).toList(),
    treatmentGapOtherHint: treatmentGapOtherHint,
    medicationStep: medicationStep?.toEntity(),
    dialysisDaysQuestion: dialysisDaysQuestion,
    dialysisDaysHint: dialysisDaysHint,
    dayOptions: dayOptions.map((o) => o.toEntity()).toList(),
  );
}

@JsonSerializable()
class VitalsPathwayOptionModel {
  final String value;
  final String label;
  final String? advice;

  const VitalsPathwayOptionModel({
    required this.value,
    required this.label,
    this.advice,
  });

  factory VitalsPathwayOptionModel.fromJson(Map<String, dynamic> json) =>
      VitalsPathwayOptionModel(
        value: _coerceString(json['value']),
        label: json['label'] as String? ?? '',
        advice: json['advice'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'value': value,
    'label': label,
    'advice': advice,
  };

  VitalsPathwayOption toEntity() =>
      VitalsPathwayOption(value: value, label: label, advice: advice);
  static String _coerceString(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw;
    return raw.toString();
  }
}

@JsonSerializable()
class VitalsMedicationStepModel {
  final String label;
  final String helper;

  const VitalsMedicationStepModel({required this.label, required this.helper});

  factory VitalsMedicationStepModel.fromJson(Map<String, dynamic> json) =>
      _$VitalsMedicationStepModelFromJson(json);

  Map<String, dynamic> toJson() => _$VitalsMedicationStepModelToJson(this);

  VitalsMedicationStep toEntity() =>
      VitalsMedicationStep(label: label, helper: helper);
}
