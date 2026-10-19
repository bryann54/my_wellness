import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_capture_result.dart';

part 'vitals_capture_result_model.g.dart';

@JsonSerializable(explicitToJson: true)
class VitalsCaptureResultModel {
  final String id;
  final String pathway;
  final String context;

  @JsonKey(name: 'first_reading')
  final VitalsSessionReadingModel? firstReading;

  @JsonKey(name: 'second_reading')
  final VitalsSessionReadingModel? secondReading;

  @JsonKey(name: 'third_reading')
  final VitalsSessionReadingModel? thirdReading;

  @JsonKey(name: 'second_reading_role')
  final String secondReadingRole;

  @JsonKey(name: 'repeat_required')
  final bool repeatRequired;

  @JsonKey(name: 'bp_category')
  final String bpCategory;

  @JsonKey(name: 'bp_category_label')
  final String bpCategoryLabel;

  @JsonKey(name: 'pulse_category')
  final String pulseCategory;

  @JsonKey(name: 'average_systolic')
  final String? averageSystolic;

  @JsonKey(name: 'average_diastolic')
  final String? averageDiastolic;

  @JsonKey(name: 'average_pulse')
  final String? averagePulse;

  @JsonKey(name: 'pulse_is_resting')
  final bool pulseIsResting;

  @JsonKey(name: 'wellbeing_question_code')
  final String wellbeingQuestionCode;

  @JsonKey(name: 'wellbeing_question_text')
  final String wellbeingQuestionText;

  @JsonKey(name: 'wellbeing_answer')
  final String? wellbeingAnswer;

  @JsonKey(name: 'emergency_symptoms')
  final List<String> emergencySymptoms;

  @JsonKey(name: 'final_cta')
  final String finalCta;

  @JsonKey(name: 'final_cta_label')
  final String finalCtaLabel;

  @JsonKey(name: 'final_recommendation')
  final String finalRecommendation;

  @JsonKey(name: 'pulse_note')
  final String pulseNote;

  final int? age;
  final String? gender;

  @JsonKey(name: 'weight_kg')
  final String? weightKg;

  @JsonKey(name: 'height_cm')
  final String? heightCm;

  final String? bmi;

  @JsonKey(name: 'bmi_classification')
  final String? bmiClassification;

  @JsonKey(name: 'bmi_deficit_kg')
  final double? bmiDeficitKg;

  final String status;

  const VitalsCaptureResultModel({
    required this.id,
    required this.pathway,
    required this.context,
    required this.bpCategory,
    required this.bpCategoryLabel,
    required this.pulseCategory,
    required this.secondReadingRole,
    required this.repeatRequired,
    required this.pulseIsResting,
    required this.wellbeingQuestionCode,
    required this.wellbeingQuestionText,
    required this.finalCta,
    required this.finalCtaLabel,
    required this.finalRecommendation,
    required this.pulseNote,
    required this.status,
    this.firstReading,
    this.secondReading,
    this.thirdReading,
    this.averageSystolic,
    this.averageDiastolic,
    this.averagePulse,
    this.wellbeingAnswer,
    this.emergencySymptoms = const [],
    this.age,
    this.gender,
    this.weightKg,
    this.heightCm,
    this.bmi,
    this.bmiClassification,
    this.bmiDeficitKg,
  });

  factory VitalsCaptureResultModel.fromJson(Map<String, dynamic> json) =>
      _$VitalsCaptureResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$VitalsCaptureResultModelToJson(this);

  VitalsCaptureResult toEntity() => VitalsCaptureResult(
    id: id,
    pathway: pathway,
    context: context,
    firstReading: firstReading?.toEntity(),
    secondReading: secondReading?.toEntity(),
    thirdReading: thirdReading?.toEntity(),
    secondReadingRole: secondReadingRole,
    repeatRequired: repeatRequired,
    bpCategory: bpCategory,
    bpCategoryLabel: bpCategoryLabel,
    pulseCategory: pulseCategory,
    averageSystolic: averageSystolic,
    averageDiastolic: averageDiastolic,
    averagePulse: averagePulse,
    pulseIsResting: pulseIsResting,
    wellbeingQuestionCode: wellbeingQuestionCode,
    wellbeingQuestionText: wellbeingQuestionText,
    wellbeingAnswer: wellbeingAnswer,
    emergencySymptoms: emergencySymptoms,
    finalCta: finalCta,
    finalCtaLabel: finalCtaLabel,
    finalRecommendation: finalRecommendation,
    pulseNote: pulseNote,
    age: age,
    gender: gender,
    weightKg: weightKg,
    heightCm: heightCm,
    bmi: bmi == null ? null : double.tryParse(bmi!),
    bmiClassification: bmiClassification,
    bmiDeficitKg: bmiDeficitKg,
    status: status,
  );
}

@JsonSerializable()
class VitalsSessionReadingModel {
  final String id;
  final int systolic;
  final int diastolic;
  final int? pulse;

  @JsonKey(name: 'pulse_classification')
  final String? pulseClassification;

  @JsonKey(name: 'pulse_classification_label')
  final String? pulseClassificationLabel;

  @JsonKey(name: 'weight_kg')
  final String? weightKg;

  final String classification;

  @JsonKey(name: 'classification_label')
  final String? classificationLabel;

  @JsonKey(name: 'dialysis_phase')
  final String? dialysisPhase;

  @JsonKey(name: 'taken_at')
  final String takenAt;

  final String? notes;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  const VitalsSessionReadingModel({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.classification,
    required this.takenAt,
    this.pulse,
    this.pulseClassification,
    this.pulseClassificationLabel,
    this.weightKg,
    this.classificationLabel,
    this.dialysisPhase,
    this.notes,
    this.createdAt,
  });

  factory VitalsSessionReadingModel.fromJson(Map<String, dynamic> json) =>
      _$VitalsSessionReadingModelFromJson(json);

  Map<String, dynamic> toJson() => _$VitalsSessionReadingModelToJson(this);

  VitalsSessionReading toEntity() => VitalsSessionReading(
    id: id,
    systolic: systolic,
    diastolic: diastolic,
    pulse: pulse,
    pulseClassification: pulseClassification,
    pulseClassificationLabel: pulseClassificationLabel,
    weightKg: weightKg,
    classification: classification,
    classificationLabel: classificationLabel,
    dialysisPhase: dialysisPhase,
    takenAt: takenAt,
    notes: notes,
    createdAt: createdAt,
  );
}
