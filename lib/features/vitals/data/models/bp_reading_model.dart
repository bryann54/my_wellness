import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/vitals/domain/entities/bp_reading.dart';

part 'bp_reading_model.g.dart';

@JsonSerializable()
class BpReadingModel {
  final String id;
  final int systolic;
  final int diastolic;
  final int? pulse;

  @JsonKey(name: 'pulse_classification')
  final String? pulseClassification;

  @JsonKey(name: 'weight_kg')
  final String? weightKg;

  final String classification;

  @JsonKey(name: 'dialysis_phase')
  final String? dialysisPhase;

  @JsonKey(name: 'taken_at')
  final String takenAt;

  final String? notes;

  @JsonKey(name: 'created_at')
  final String createdAt;

  const BpReadingModel({
    required this.id,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.pulseClassification,
    this.weightKg,
    required this.classification,
    this.dialysisPhase,
    required this.takenAt,
    this.notes,
    required this.createdAt,
  });

  factory BpReadingModel.fromJson(Map<String, dynamic> json) =>
      _$BpReadingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BpReadingModelToJson(this);

  BpReading toEntity() => BpReading(
    id: id,
    systolic: systolic,
    diastolic: diastolic,
    pulse: pulse,
    pulseClassification: pulseClassification,
    weightKg: weightKg,
    classification: classification,
    dialysisPhase: dialysisPhase,
    takenAt: takenAt,
    notes: notes,
    createdAt: createdAt,
  );
}
