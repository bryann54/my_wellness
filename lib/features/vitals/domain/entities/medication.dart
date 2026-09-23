import 'package:equatable/equatable.dart';

class Medication extends Equatable {
  final String id;
  final String? condition;
  final String name;
  final String dosage;
  final String frequency;

  final String? notes;
  final String source;
  final DateTime? startDate;

  final int? durationValue;
  final String? durationUnit;
  final DateTime? endDate;

  final String? prescription;
  final DateTime createdAt;

  const Medication({
    required this.id,
    this.condition,
    required this.name,
    required this.dosage,
    this.frequency = '',
    this.notes,
    this.source = 'manual',
    this.startDate,
    this.durationValue,
    this.durationUnit,
    this.endDate,
    this.prescription,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    condition,
    name,
    dosage,
    frequency,
    notes,
    source,
    startDate,
    durationValue,
    durationUnit,
    endDate,
    prescription,
    createdAt,
  ];
}
