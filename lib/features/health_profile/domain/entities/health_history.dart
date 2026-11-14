import 'package:equatable/equatable.dart';

class HealthHistory extends Equatable {
  const HealthHistory({
    this.latestBloodPressure,
    this.latestBloodSugar,
    this.latestVitalSign,
    this.diagnoses = const [],
    this.allergies = const [],
    this.labResults = const [],
    this.procedures = const [],
    this.prescriptions = const [],
    this.immunizations = const [],
    this.journey = const [],
  });

  final HealthMeasurement? latestBloodPressure;
  final HealthMeasurement? latestBloodSugar;
  final HealthMeasurement? latestVitalSign;
  final List<HealthRecordItem> diagnoses;
  final List<HealthRecordItem> allergies;
  final List<HealthRecordItem> labResults;
  final List<HealthRecordItem> procedures;
  final List<HealthRecordItem> prescriptions;
  final List<HealthRecordItem> immunizations;
  final List<HealthJourneyItem> journey;

  bool get isEmpty =>
      latestBloodPressure == null &&
      latestBloodSugar == null &&
      latestVitalSign == null &&
      diagnoses.isEmpty &&
      allergies.isEmpty &&
      labResults.isEmpty &&
      procedures.isEmpty &&
      prescriptions.isEmpty &&
      immunizations.isEmpty &&
      journey.isEmpty;

  @override
  List<Object?> get props => [
    latestBloodPressure,
    latestBloodSugar,
    latestVitalSign,
    diagnoses,
    allergies,
    labResults,
    procedures,
    prescriptions,
    immunizations,
    journey,
  ];
}

class HealthMeasurement extends Equatable {
  const HealthMeasurement({
    required this.label,
    required this.value,
    this.unit,
    this.detail,
    this.recordedAt,
    this.needsAttention = false,
  });

  final String label;
  final String value;
  final String? unit;
  final String? detail;
  final DateTime? recordedAt;
  final bool needsAttention;

  @override
  List<Object?> get props => [
    label,
    value,
    unit,
    detail,
    recordedAt,
    needsAttention,
  ];
}

class HealthRecordItem extends Equatable {
  const HealthRecordItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.detail,
    this.recordedAt,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? detail;
  final DateTime? recordedAt;

  @override
  List<Object?> get props => [id, title, subtitle, detail, recordedAt];
}

class HealthJourneyItem extends Equatable {
  const HealthJourneyItem({
    required this.sessionId,
    required this.assessmentSlug,
    required this.completedAt,
    this.band,
    this.bandLabel,
    this.summary,
    this.hasActiveWarning = false,
    this.referralStatus,
    this.referralFacility,
  });

  final String sessionId;
  final String assessmentSlug;
  final DateTime completedAt;
  final String? band;
  final String? bandLabel;
  final String? summary;
  final bool hasActiveWarning;
  final String? referralStatus;
  final String? referralFacility;

  @override
  List<Object?> get props => [
    sessionId,
    assessmentSlug,
    completedAt,
    band,
    bandLabel,
    summary,
    hasActiveWarning,
    referralStatus,
    referralFacility,
  ];
}
