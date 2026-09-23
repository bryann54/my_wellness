import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/vitals/domain/entities/bs_reading.dart';

part 'bs_reading_model.g.dart';

@JsonSerializable()
class BsReadingModel {
  final String id;
  final String value;
  final String unit;

  @JsonKey(name: 'reading_type')
  final String readingType;

  @JsonKey(name: 'meal_timing')
  final String? mealTiming;

  @JsonKey(name: 'weight_kg')
  final String? weightKg;

  final String classification;

  @JsonKey(name: 'taken_at')
  final String takenAt;

  final String? notes;

  @JsonKey(name: 'created_at')
  final String createdAt;

  const BsReadingModel({
    required this.id,
    required this.value,
    required this.unit,
    required this.readingType,
    this.mealTiming,
    this.weightKg,
    required this.classification,
    required this.takenAt,
    this.notes,
    required this.createdAt,
  });

  factory BsReadingModel.fromJson(Map<String, dynamic> json) =>
      _$BsReadingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BsReadingModelToJson(this);

  BsReading toEntity() => BsReading(
    id: id,
    value: value,
    unit: unit,
    readingType: readingType,
    mealTiming: mealTiming,
    weightKg: weightKg,
    classification: classification,
    takenAt: takenAt,
    notes: notes,
    createdAt: createdAt,
  );
}
