// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationModel _$MedicationModelFromJson(Map<String, dynamic> json) =>
    MedicationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String? ?? '',
      notes: json['notes'] as String?,
      source: json['source'] as String? ?? 'manual',
      condition: json['condition'] as String? ?? 'other',
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      durationValue: (json['duration_value'] as num?)?.toInt(),
      durationUnit: json['duration_unit'] as String? ?? '',
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      prescription: json['prescription'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MedicationModelToJson(MedicationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'notes': instance.notes,
      'source': instance.source,
      'condition': instance.condition,
      'start_date': instance.startDate?.toIso8601String(),
      'duration_value': instance.durationValue,
      'duration_unit': instance.durationUnit,
      'end_date': instance.endDate?.toIso8601String(),
      'prescription': instance.prescription,
      'created_at': instance.createdAt.toIso8601String(),
    };
