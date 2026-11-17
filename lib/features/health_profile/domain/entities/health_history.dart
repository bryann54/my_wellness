import 'package:equatable/equatable.dart';

class HealthHistory extends Equatable {
  const HealthHistory({
    this.bpAttentionNotice,
    this.bloodPressureReadings = const [],
    this.bloodSugarReadings = const [],
    this.vitalSigns = const [],
    this.diagnoses = const [],
    this.allergies = const [],
    this.labResults = const [],
    this.procedures = const [],
    this.prescriptions = const [],
    this.immunizations = const [],
  });

  final String? bpAttentionNotice;
  final List<BloodPressureRecord> bloodPressureReadings;
  final List<BloodSugarRecord> bloodSugarReadings;
  final List<VitalSignRecord> vitalSigns;
  final List<DiagnosisRecord> diagnoses;
  final List<AllergyRecord> allergies;
  final List<LabResultRecord> labResults;
  final List<ProcedureRecord> procedures;
  final List<PrescriptionRecord> prescriptions;
  final List<ImmunizationRecord> immunizations;

  BloodPressureRecord? get latestBloodPressure =>
      bloodPressureReadings.isEmpty ? null : bloodPressureReadings.first;
  BloodSugarRecord? get latestBloodSugar =>
      bloodSugarReadings.isEmpty ? null : bloodSugarReadings.first;

  bool get isEmpty =>
      bloodPressureReadings.isEmpty &&
      bloodSugarReadings.isEmpty &&
      vitalSigns.isEmpty &&
      diagnoses.isEmpty &&
      allergies.isEmpty &&
      labResults.isEmpty &&
      procedures.isEmpty &&
      prescriptions.isEmpty &&
      immunizations.isEmpty;

  @override
  List<Object?> get props => [
    bpAttentionNotice,
    bloodPressureReadings,
    bloodSugarReadings,
    vitalSigns,
    diagnoses,
    allergies,
    labResults,
    procedures,
    prescriptions,
    immunizations,
  ];
}

class BloodPressureRecord extends Equatable {
  const BloodPressureRecord({
    required this.id,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.monitorBand,
    this.monitorBandLabel,
    this.dialysisPhase,
    this.notes,
    this.takenAt,
    this.needsAttention = false,
  });

  final String id;
  final int? systolic;
  final int? diastolic;
  final int? pulse;
  final String? monitorBand;
  final String? monitorBandLabel;
  final String? dialysisPhase;
  final String? notes;
  final DateTime? takenAt;
  final bool needsAttention;

  @override
  List<Object?> get props => [
    id,
    systolic,
    diastolic,
    pulse,
    monitorBand,
    monitorBandLabel,
    dialysisPhase,
    notes,
    takenAt,
    needsAttention,
  ];
}

class BloodSugarRecord extends Equatable {
  const BloodSugarRecord({
    required this.id,
    required this.value,
    this.unit,
    this.readingTypeLabel,
    this.classification,
    this.classificationLabel,
    this.displayColour,
    this.notes,
    this.takenAt,
  });

  final String id;
  final String value;
  final String? unit;
  final String? readingTypeLabel;
  final String? classification;
  final String? classificationLabel;
  final String? displayColour;
  final String? notes;
  final DateTime? takenAt;

  @override
  List<Object?> get props => [
    id,
    value,
    unit,
    readingTypeLabel,
    classification,
    classificationLabel,
    displayColour,
    notes,
    takenAt,
  ];
}

class VitalSignRecord extends Equatable {
  const VitalSignRecord({
    required this.id,
    required this.typeLabel,
    required this.value,
    this.unit,
    this.notes,
    this.takenAt,
  });

  final String id;
  final String typeLabel;
  final String value;
  final String? unit;
  final String? notes;
  final DateTime? takenAt;

  @override
  List<Object?> get props => [id, typeLabel, value, unit, notes, takenAt];
}

class DiagnosisRecord extends Equatable {
  const DiagnosisRecord({
    required this.id,
    required this.condition,
    this.severity,
    this.details,
    this.recordedAt,
  });

  final String id;
  final String condition;
  final String? severity;
  final String? details;
  final DateTime? recordedAt;

  @override
  List<Object?> get props => [id, condition, severity, details, recordedAt];
}

class AllergyRecord extends Equatable {
  const AllergyRecord({
    required this.id,
    required this.allergen,
    this.severity,
    this.reaction,
    this.notes,
    this.recordedAt,
  });

  final String id;
  final String allergen;
  final String? severity;
  final String? reaction;
  final String? notes;
  final DateTime? recordedAt;

  @override
  List<Object?> get props => [
    id,
    allergen,
    severity,
    reaction,
    notes,
    recordedAt,
  ];
}

class LabResultRecord extends Equatable {
  const LabResultRecord({
    required this.id,
    required this.testName,
    required this.value,
    this.unit,
    this.referenceRange,
    this.interpretation,
    this.interpretationLabel,
    this.specimenTypeLabel,
    this.specimenCollectedAt,
    this.status,
    this.statusLabel,
    this.notes,
    this.recordedAt,
  });

  final String id;
  final String testName;
  final String value;
  final String? unit;
  final String? referenceRange;
  final String? interpretation;
  final String? interpretationLabel;
  final String? specimenTypeLabel;
  final DateTime? specimenCollectedAt;
  final String? status;
  final String? statusLabel;
  final String? notes;
  final DateTime? recordedAt;

  @override
  List<Object?> get props => [
    id,
    testName,
    value,
    unit,
    referenceRange,
    interpretation,
    interpretationLabel,
    specimenTypeLabel,
    specimenCollectedAt,
    status,
    statusLabel,
    notes,
    recordedAt,
  ];
}

class ProcedureRecord extends Equatable {
  const ProcedureRecord({
    required this.id,
    required this.name,
    this.notes,
    this.recordedAt,
  });

  final String id;
  final String name;
  final String? notes;
  final DateTime? recordedAt;

  @override
  List<Object?> get props => [id, name, notes, recordedAt];
}

class PrescriptionRecord extends Equatable {
  const PrescriptionRecord({
    required this.id,
    required this.medication,
    this.dosage,
    this.startDate,
    this.endDate,
    this.instructions,
    this.recordedAt,
  });

  final String id;
  final String medication;
  final String? dosage;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? instructions;
  final DateTime? recordedAt;

  @override
  List<Object?> get props => [
    id,
    medication,
    dosage,
    startDate,
    endDate,
    instructions,
    recordedAt,
  ];
}

class ImmunizationRecord extends Equatable {
  const ImmunizationRecord({
    required this.id,
    required this.vaccineName,
    this.doseNumber,
    this.status,
    this.notes,
    this.recordedAt,
  });

  final String id;
  final String vaccineName;
  final String? doseNumber;
  final String? status;
  final String? notes;
  final DateTime? recordedAt;

  @override
  List<Object?> get props => [
    id,
    vaccineName,
    doseNumber,
    status,
    notes,
    recordedAt,
  ];
}
