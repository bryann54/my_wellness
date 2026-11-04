import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication.dart';

part 'medication_model.g.dart';

@JsonSerializable()
class MedicationSideEffectsModel {
  @JsonKey(name: 'generic_name')
  final String genericName;

  @JsonKey(name: 'drug_class')
  final String? drugClass;

  final String sideEffects;

  @JsonKey(name: 'safety_caution')
  final String? safetyCaution;

  const MedicationSideEffectsModel({
    required this.genericName,
    this.drugClass,
    required this.sideEffects,
    this.safetyCaution,
  });

  factory MedicationSideEffectsModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationSideEffectsModelFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationSideEffectsModelToJson(this);

  MedicationSideEffects toEntity() => MedicationSideEffects(
    genericName: genericName,
    drugClass: drugClass,
    sideEffects: sideEffects,
    safetyCaution: safetyCaution,
  );
}

@JsonSerializable()
class MedicationModel {
  final String id;
  final String name;
  final String? condition;
  final String dosage;

  @JsonKey(defaultValue: '')
  final String frequency;

  final String? notes;

  @JsonKey(defaultValue: 'manual')
  final String source;

  @JsonKey(name: 'generic_product_code')
  final String? genericProductCode;

  @JsonKey(name: 'start_date')
  final DateTime? startDate;

  @JsonKey(name: 'duration_value')
  final int? durationValue;
  @JsonKey(name: 'duration_unit', defaultValue: '')
  final String durationUnit;

  @JsonKey(name: 'end_date')
  final DateTime? endDate;

  final String? prescription;

  @JsonKey(name: 'reminder_times', defaultValue: <String>[])
  final List<String> reminderTimes;

  @JsonKey(name: 'dosage_form')
  final String? dosageForm;

  @JsonKey(name: 'quantity_per_dose')
  final int? quantityPerDose;

  @JsonKey(name: 'quantity_dispensed')
  final int? quantityDispensed;

  @JsonKey(name: 'last_refilled_at')
  final DateTime? lastRefilledAt;

  @JsonKey(name: 'refill_due_date')
  final DateTime? refillDueDate;

  @JsonKey(name: 'side_effects')
  final MedicationSideEffectsModel? sideEffects;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const MedicationModel({
    required this.id,
    required this.name,
    this.condition,
    required this.dosage,
    this.frequency = '',
    this.notes,
    this.source = 'manual',
    this.genericProductCode,
    this.startDate,
    this.durationValue,
    this.durationUnit = '',
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

  factory MedicationModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationModelFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationModelToJson(this);

  Medication toEntity() => Medication(
    id: id,
    name: name,
    condition: condition,
    dosage: dosage,
    frequency: frequency,
    notes: notes,
    source: source,
    genericProductCode: genericProductCode,
    startDate: startDate,
    durationValue: durationValue,
    durationUnit: durationUnit,
    endDate: endDate,
    prescription: prescription,
    reminderTimes: reminderTimes,
    dosageForm: dosageForm,
    quantityPerDose: quantityPerDose,
    quantityDispensed: quantityDispensed,
    lastRefilledAt: lastRefilledAt,
    refillDueDate: refillDueDate,
    sideEffects: sideEffects?.toEntity(),
    createdAt: createdAt,
  );
}
