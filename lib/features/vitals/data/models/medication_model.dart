import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication.dart';

part 'medication_model.g.dart';

@JsonSerializable()
class MedicationModel {
  final String id;
  final String name;
  final String dosage;

  @JsonKey(defaultValue: '')
  final String frequency;

  final String? notes;

  @JsonKey(defaultValue: 'manual')
  final String source;

  @JsonKey(defaultValue: 'other')
  final String condition;

  @JsonKey(name: 'start_date')
  final DateTime? startDate;

  @JsonKey(name: 'duration_value')
  final int? durationValue; // ← nullable

  @JsonKey(name: 'duration_unit', defaultValue: '')
  final String durationUnit;

  @JsonKey(name: 'end_date')
  final DateTime? endDate;

  final String? prescription;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    this.frequency = '',
    this.notes,
    this.source = 'manual',
    this.condition = 'other',
    this.startDate,
    this.durationValue,
    this.durationUnit = '',
    this.endDate,
    this.prescription,
    required this.createdAt,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationModelFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationModelToJson(this);

  Medication toEntity() => Medication(
    id: id,
    name: name,
    dosage: dosage,
    frequency: frequency,
    notes: notes,
    source: source,
    condition: condition,
    startDate: startDate,
    durationValue: durationValue,
    durationUnit: durationUnit,
    endDate: endDate,
    prescription: prescription,
    createdAt: createdAt,
  );
}
