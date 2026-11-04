import 'package:equatable/equatable.dart';

class MedicationSideEffects extends Equatable {
  final String genericName;
  final String? drugClass;
  final String sideEffects;
  final String? safetyCaution;

  const MedicationSideEffects({
    required this.genericName,
    this.drugClass,
    required this.sideEffects,
    this.safetyCaution,
  });

  @override
  List<Object?> get props => [
    genericName,
    drugClass,
    sideEffects,
    safetyCaution,
  ];
}

class Medication extends Equatable {
  final String id;
  final String? condition;
  final String name;
  final String? genericProductCode;
  final String dosage;
  final String frequency;

  final String? notes;
  final String source;
  final DateTime? startDate;

  final int? durationValue;
  final String? durationUnit;
  final DateTime? endDate;

  final String? prescription;

  // Refill / reminders
  final List<String> reminderTimes;
  final String? dosageForm;
  final int? quantityPerDose;
  final int? quantityDispensed;
  final DateTime? lastRefilledAt;
  final DateTime? refillDueDate;
  final MedicationSideEffects? sideEffects;

  final DateTime createdAt;

  const Medication({
    required this.id,
    this.condition,
    required this.name,
    this.genericProductCode,
    required this.dosage,
    this.frequency = '',
    this.notes,
    this.source = 'manual',
    this.startDate,
    this.durationValue,
    this.durationUnit,
    this.endDate,
    this.prescription,
    this.reminderTimes = const [],
    this.dosageForm,
    this.quantityPerDose,
    this.quantityDispensed,
    this.lastRefilledAt,
    this.refillDueDate,
    this.sideEffects,
    required this.createdAt,
  });

  bool get isRefillDueSoon {
    final due = refillDueDate;
    if (due == null) return false;
    final now = DateTime.now();
    return !due.isAfter(now.add(const Duration(days: 7)));
  }

  bool get isRefillOverdue {
    final due = refillDueDate;
    if (due == null) return false;
    return due.isBefore(DateTime.now());
  }

  @override
  List<Object?> get props => [
    id,
    condition,
    name,
    genericProductCode,
    dosage,
    frequency,
    notes,
    source,
    startDate,
    durationValue,
    durationUnit,
    endDate,
    prescription,
    reminderTimes,
    dosageForm,
    quantityPerDose,
    quantityDispensed,
    lastRefilledAt,
    refillDueDate,
    sideEffects,
    createdAt,
  ];
}
