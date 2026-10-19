import 'package:equatable/equatable.dart';

class VitalsCaptureResult extends Equatable {
  final String id;
  final String pathway;
  final String context;

  final VitalsSessionReading? firstReading;
  final VitalsSessionReading? secondReading;
  final VitalsSessionReading? thirdReading;

  final String secondReadingRole;
  final bool repeatRequired;

  final String bpCategory;
  final String bpCategoryLabel;
  final String pulseCategory;
  final String? averageSystolic;
  final String? averageDiastolic;
  final String? averagePulse;
  final bool pulseIsResting;

  final String wellbeingQuestionCode;
  final String wellbeingQuestionText;
  final String? wellbeingAnswer;
  final List<String> emergencySymptoms;

  final String finalCta;
  final String finalCtaLabel;
  final String finalRecommendation;
  final String pulseNote;

  final int? age;
  final String? gender;
  final String? weightKg;
  final String? heightCm;
  final double? bmi;
  final String? bmiClassification;
  final double? bmiDeficitKg;

  final String status;

  const VitalsCaptureResult({
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

  @override
  List<Object?> get props => [
    id,
    pathway,
    context,
    firstReading,
    secondReading,
    thirdReading,
    secondReadingRole,
    repeatRequired,
    bpCategory,
    bpCategoryLabel,
    pulseCategory,
    averageSystolic,
    averageDiastolic,
    averagePulse,
    pulseIsResting,
    wellbeingQuestionCode,
    wellbeingQuestionText,
    wellbeingAnswer,
    emergencySymptoms,
    finalCta,
    finalCtaLabel,
    finalRecommendation,
    pulseNote,
    age,
    gender,
    weightKg,
    heightCm,
    bmi,
    bmiClassification,
    bmiDeficitKg,
    status,
  ];
}

class VitalsSessionReading extends Equatable {
  final String id;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? pulseClassification;
  final String? pulseClassificationLabel;
  final String? weightKg;
  final String classification;
  final String? classificationLabel;
  final String? dialysisPhase;
  final String takenAt;
  final String? notes;
  final String? createdAt;

  const VitalsSessionReading({
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

  @override
  List<Object?> get props => [
    id,
    systolic,
    diastolic,
    pulse,
    pulseClassification,
    pulseClassificationLabel,
    weightKg,
    classification,
    classificationLabel,
    dialysisPhase,
    takenAt,
    notes,
    createdAt,
  ];
}
