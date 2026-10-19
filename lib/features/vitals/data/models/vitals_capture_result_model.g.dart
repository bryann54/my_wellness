// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vitals_capture_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VitalsCaptureResultModel _$VitalsCaptureResultModelFromJson(
  Map<String, dynamic> json,
) => VitalsCaptureResultModel(
  id: json['id'] as String,
  pathway: json['pathway'] as String,
  context: json['context'] as String,
  bpCategory: json['bp_category'] as String,
  bpCategoryLabel: json['bp_category_label'] as String,
  pulseCategory: json['pulse_category'] as String,
  secondReadingRole: json['second_reading_role'] as String,
  repeatRequired: json['repeat_required'] as bool,
  pulseIsResting: json['pulse_is_resting'] as bool,
  wellbeingQuestionCode: json['wellbeing_question_code'] as String,
  wellbeingQuestionText: json['wellbeing_question_text'] as String,
  finalCta: json['final_cta'] as String,
  finalCtaLabel: json['final_cta_label'] as String,
  finalRecommendation: json['final_recommendation'] as String,
  pulseNote: json['pulse_note'] as String,
  status: json['status'] as String,
  firstReading: json['first_reading'] == null
      ? null
      : VitalsSessionReadingModel.fromJson(
          json['first_reading'] as Map<String, dynamic>,
        ),
  secondReading: json['second_reading'] == null
      ? null
      : VitalsSessionReadingModel.fromJson(
          json['second_reading'] as Map<String, dynamic>,
        ),
  thirdReading: json['third_reading'] == null
      ? null
      : VitalsSessionReadingModel.fromJson(
          json['third_reading'] as Map<String, dynamic>,
        ),
  averageSystolic: json['average_systolic'] as String?,
  averageDiastolic: json['average_diastolic'] as String?,
  averagePulse: json['average_pulse'] as String?,
  wellbeingAnswer: json['wellbeing_answer'] as String?,
  emergencySymptoms:
      (json['emergency_symptoms'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  age: (json['age'] as num?)?.toInt(),
  gender: json['gender'] as String?,
  weightKg: json['weight_kg'] as String?,
  heightCm: json['height_cm'] as String?,
  bmi: json['bmi'] as String?,
  bmiClassification: json['bmi_classification'] as String?,
  bmiDeficitKg: (json['bmi_deficit_kg'] as num?)?.toDouble(),
);

Map<String, dynamic> _$VitalsCaptureResultModelToJson(
  VitalsCaptureResultModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'pathway': instance.pathway,
  'context': instance.context,
  'first_reading': instance.firstReading?.toJson(),
  'second_reading': instance.secondReading?.toJson(),
  'third_reading': instance.thirdReading?.toJson(),
  'second_reading_role': instance.secondReadingRole,
  'repeat_required': instance.repeatRequired,
  'bp_category': instance.bpCategory,
  'bp_category_label': instance.bpCategoryLabel,
  'pulse_category': instance.pulseCategory,
  'average_systolic': instance.averageSystolic,
  'average_diastolic': instance.averageDiastolic,
  'average_pulse': instance.averagePulse,
  'pulse_is_resting': instance.pulseIsResting,
  'wellbeing_question_code': instance.wellbeingQuestionCode,
  'wellbeing_question_text': instance.wellbeingQuestionText,
  'wellbeing_answer': instance.wellbeingAnswer,
  'emergency_symptoms': instance.emergencySymptoms,
  'final_cta': instance.finalCta,
  'final_cta_label': instance.finalCtaLabel,
  'final_recommendation': instance.finalRecommendation,
  'pulse_note': instance.pulseNote,
  'age': instance.age,
  'gender': instance.gender,
  'weight_kg': instance.weightKg,
  'height_cm': instance.heightCm,
  'bmi': instance.bmi,
  'bmi_classification': instance.bmiClassification,
  'bmi_deficit_kg': instance.bmiDeficitKg,
  'status': instance.status,
};

VitalsSessionReadingModel _$VitalsSessionReadingModelFromJson(
  Map<String, dynamic> json,
) => VitalsSessionReadingModel(
  id: json['id'] as String,
  systolic: (json['systolic'] as num).toInt(),
  diastolic: (json['diastolic'] as num).toInt(),
  classification: json['classification'] as String,
  takenAt: json['taken_at'] as String,
  pulse: (json['pulse'] as num?)?.toInt(),
  pulseClassification: json['pulse_classification'] as String?,
  pulseClassificationLabel: json['pulse_classification_label'] as String?,
  weightKg: json['weight_kg'] as String?,
  classificationLabel: json['classification_label'] as String?,
  dialysisPhase: json['dialysis_phase'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$VitalsSessionReadingModelToJson(
  VitalsSessionReadingModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'systolic': instance.systolic,
  'diastolic': instance.diastolic,
  'pulse': instance.pulse,
  'pulse_classification': instance.pulseClassification,
  'pulse_classification_label': instance.pulseClassificationLabel,
  'weight_kg': instance.weightKg,
  'classification': instance.classification,
  'classification_label': instance.classificationLabel,
  'dialysis_phase': instance.dialysisPhase,
  'taken_at': instance.takenAt,
  'notes': instance.notes,
  'created_at': instance.createdAt,
};
