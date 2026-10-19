import 'package:equatable/equatable.dart';

class BsReading extends Equatable {
  final String id;
  final String? classificationLabel;
  final String value;

  /// 'mmol/L' | 'mg/dL'
  final String unit;

  /// 'fasting' | 'random' | 'post_meal' | ...
  final String readingType;

  /// 'less_than_2h' | 'more_than_2h' | ... — optional.
  final String? mealTiming;

  final String? weightKg;

  /// Server-classified: 'blue' | 'green' | 'yellow' | 'orange' | 'red'.
  final String classification;

  final String takenAt;
  final String? notes;
  final String createdAt;

  const BsReading({
    required this.id,
    required this.value,
    this.classificationLabel,
    required this.unit,
    required this.readingType,
    this.mealTiming,
    this.weightKg,
    required this.classification,
    required this.takenAt,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    value,
    unit,
    classificationLabel,
    readingType,
    mealTiming,
    weightKg,
    classification,
    takenAt,
    notes,
    createdAt,
  ];
}
