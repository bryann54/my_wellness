import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication_scan.dart';

part 'medication_scan_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MedicationScanModel {
  final List<MedicationCandidateModel> medications;

  @JsonKey(name: 'needs_confirmation')
  final List<MedicationCandidateModel> needsConfirmation;

  final String? message;

  const MedicationScanModel({
    this.medications = const [],
    this.needsConfirmation = const [],
    this.message,
  });

  factory MedicationScanModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationScanModelFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationScanModelToJson(this);

  MedicationScanResult toEntity() => MedicationScanResult(
    confirmed: medications.map((m) => m.toEntity()).toList(growable: false),
    needsConfirmation: needsConfirmation
        .map((m) => m.toEntity())
        .toList(growable: false),
    message: message,
  );
}

@JsonSerializable()
class MedicationCandidateModel {
  @JsonKey(name: 'raw_name')
  final String? rawName;

  final String? name;
  final String? dosage;
  final String? frequency;
  final String? notes;
  final List<MedicationCandidateOptionModel> candidates;

  const MedicationCandidateModel({
    this.rawName,
    this.name,
    this.dosage,
    this.frequency,
    this.notes,
    this.candidates = const [],
  });

  factory MedicationCandidateModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationCandidateModelFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationCandidateModelToJson(this);

  MedicationCandidate toEntity() => MedicationCandidate(
    rawName: rawName,
    name: name,
    dosage: dosage,
    frequency: frequency,
    notes: notes,
    candidates: candidates.map((c) => c.toEntity()).toList(growable: false),
  );
}

@JsonSerializable()
class MedicationCandidateOptionModel {
  final String id;
  final String name;
  final String? dosage;
  final String? frequency;

  const MedicationCandidateOptionModel({
    required this.id,
    required this.name,
    this.dosage,
    this.frequency,
  });

  factory MedicationCandidateOptionModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationCandidateOptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationCandidateOptionModelToJson(this);

  MedicationCandidateOption toEntity() => MedicationCandidateOption(
    id: id,
    name: name,
    dosage: dosage,
    frequency: frequency,
  );
}
