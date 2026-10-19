// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vitals_capture_content_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VitalsCaptureContentModel _$VitalsCaptureContentModelFromJson(
  Map<String, dynamic> json,
) => VitalsCaptureContentModel(
  onboarding: VitalsOnboardingModel.fromJson(
    json['onboarding'] as Map<String, dynamic>,
  ),
  pathway: VitalsPathwayModel.fromJson(json['pathway'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VitalsCaptureContentModelToJson(
  VitalsCaptureContentModel instance,
) => <String, dynamic>{
  'onboarding': instance.onboarding.toJson(),
  'pathway': instance.pathway.toJson(),
};

VitalsOnboardingModel _$VitalsOnboardingModelFromJson(
  Map<String, dynamic> json,
) => VitalsOnboardingModel(
  intro: VitalsOnboardingIntroModel.fromJson(
    json['intro'] as Map<String, dynamic>,
  ),
  tips: VitalsOnboardingTipsModel.fromJson(
    json['tips'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$VitalsOnboardingModelToJson(
  VitalsOnboardingModel instance,
) => <String, dynamic>{
  'intro': instance.intro.toJson(),
  'tips': instance.tips.toJson(),
};

VitalsOnboardingIntroModel _$VitalsOnboardingIntroModelFromJson(
  Map<String, dynamic> json,
) => VitalsOnboardingIntroModel(
  title: json['title'] as String,
  heading: json['heading'] as String,
  paragraphs: (json['paragraphs'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$VitalsOnboardingIntroModelToJson(
  VitalsOnboardingIntroModel instance,
) => <String, dynamic>{
  'title': instance.title,
  'heading': instance.heading,
  'paragraphs': instance.paragraphs,
};

VitalsOnboardingTipsModel _$VitalsOnboardingTipsModelFromJson(
  Map<String, dynamic> json,
) => VitalsOnboardingTipsModel(
  title: json['title'] as String,
  intro: json['intro'] as String,
  items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$VitalsOnboardingTipsModelToJson(
  VitalsOnboardingTipsModel instance,
) => <String, dynamic>{
  'title': instance.title,
  'intro': instance.intro,
  'items': instance.items,
};

VitalsPathwayModel _$VitalsPathwayModelFromJson(
  Map<String, dynamic> json,
) => VitalsPathwayModel(
  pathwayQuestion: json['pathway_question'] as String,
  pathwayOptions: (json['pathway_options'] as List<dynamic>)
      .map((e) => VitalsPathwayOptionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  providerPlanQuestion: json['provider_plan_question'] as String?,
  providerPlanOptions:
      (json['provider_plan_options'] as List<dynamic>?)
          ?.map(
            (e) => VitalsPathwayOptionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  treatmentGapQuestion: json['treatment_gap_question'] as String?,
  treatmentGapHint: json['treatment_gap_hint'] as String?,
  treatmentGapOptions:
      (json['treatment_gap_options'] as List<dynamic>?)
          ?.map(
            (e) => VitalsPathwayOptionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  treatmentGapOtherHint: json['treatment_gap_other_hint'] as String?,
  medicationStep: json['medication_step'] == null
      ? null
      : VitalsMedicationStepModel.fromJson(
          json['medication_step'] as Map<String, dynamic>,
        ),
  dialysisDaysQuestion: json['dialysis_days_question'] as String?,
  dialysisDaysHint: json['dialysis_days_hint'] as String?,
  dayOptions:
      (json['day_options'] as List<dynamic>?)
          ?.map(
            (e) => VitalsPathwayOptionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$VitalsPathwayModelToJson(
  VitalsPathwayModel instance,
) => <String, dynamic>{
  'pathway_question': instance.pathwayQuestion,
  'pathway_options': instance.pathwayOptions.map((e) => e.toJson()).toList(),
  'provider_plan_question': instance.providerPlanQuestion,
  'provider_plan_options': instance.providerPlanOptions
      .map((e) => e.toJson())
      .toList(),
  'treatment_gap_question': instance.treatmentGapQuestion,
  'treatment_gap_hint': instance.treatmentGapHint,
  'treatment_gap_options': instance.treatmentGapOptions
      .map((e) => e.toJson())
      .toList(),
  'treatment_gap_other_hint': instance.treatmentGapOtherHint,
  'medication_step': instance.medicationStep?.toJson(),
  'dialysis_days_question': instance.dialysisDaysQuestion,
  'dialysis_days_hint': instance.dialysisDaysHint,
  'day_options': instance.dayOptions.map((e) => e.toJson()).toList(),
};

VitalsPathwayOptionModel _$VitalsPathwayOptionModelFromJson(
  Map<String, dynamic> json,
) => VitalsPathwayOptionModel(
  value: json['value'] as String,
  label: json['label'] as String,
  advice: json['advice'] as String?,
);

Map<String, dynamic> _$VitalsPathwayOptionModelToJson(
  VitalsPathwayOptionModel instance,
) => <String, dynamic>{
  'value': instance.value,
  'label': instance.label,
  'advice': instance.advice,
};

VitalsMedicationStepModel _$VitalsMedicationStepModelFromJson(
  Map<String, dynamic> json,
) => VitalsMedicationStepModel(
  label: json['label'] as String,
  helper: json['helper'] as String,
);

Map<String, dynamic> _$VitalsMedicationStepModelToJson(
  VitalsMedicationStepModel instance,
) => <String, dynamic>{'label': instance.label, 'helper': instance.helper};
