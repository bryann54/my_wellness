// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationSideEffectsModel _$MedicationSideEffectsModelFromJson(
  Map<String, dynamic> json,
) => MedicationSideEffectsModel(
  genericName: json['generic_name'] as String,
  drugClass: json['drug_class'] as String?,
  sideEffects: json['sideEffects'] as String,
  safetyCaution: json['safety_caution'] as String?,
);

Map<String, dynamic> _$MedicationSideEffectsModelToJson(
  MedicationSideEffectsModel instance,
) => <String, dynamic>{
  'generic_name': instance.genericName,
  'drug_class': instance.drugClass,
  'sideEffects': instance.sideEffects,
  'safety_caution': instance.safetyCaution,
};

MedicationModel _$MedicationModelFromJson(Map<String, dynamic> json) =>
    MedicationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      condition: json['condition'] as String?,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String? ?? '',
      notes: json['notes'] as String?,
      source: json['source'] as String? ?? 'manual',
      genericProductCode: json['generic_product_code'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      durationValue: (json['duration_value'] as num?)?.toInt(),
      durationUnit: json['duration_unit'] as String? ?? '',
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      prescription: json['prescription'] as String?,
      reminderTimes:
          (json['reminder_times'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      dosageForm: json['dosage_form'] as String?,
      quantityPerDose: (json['quantity_per_dose'] as num?)?.toInt(),
      quantityDispensed: (json['quantity_dispensed'] as num?)?.toInt(),
      lastRefilledAt: json['last_refilled_at'] == null
          ? null
          : DateTime.parse(json['last_refilled_at'] as String),
      refillDueDate: json['refill_due_date'] == null
          ? null
          : DateTime.parse(json['refill_due_date'] as String),
      sideEffects: json['side_effects'] == null
          ? null
          : MedicationSideEffectsModel.fromJson(
              json['side_effects'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MedicationModelToJson(MedicationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'condition': instance.condition,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'notes': instance.notes,
      'source': instance.source,
      'generic_product_code': instance.genericProductCode,
      'start_date': instance.startDate?.toIso8601String(),
      'duration_value': instance.durationValue,
      'duration_unit': instance.durationUnit,
      'end_date': instance.endDate?.toIso8601String(),
      'prescription': instance.prescription,
      'reminder_times': instance.reminderTimes,
      'dosage_form': instance.dosageForm,
      'quantity_per_dose': instance.quantityPerDose,
      'quantity_dispensed': instance.quantityDispensed,
      'last_refilled_at': instance.lastRefilledAt?.toIso8601String(),
      'refill_due_date': instance.refillDueDate?.toIso8601String(),
      'side_effects': instance.sideEffects,
      'created_at': instance.createdAt.toIso8601String(),
    };
