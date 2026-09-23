// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bp_reading_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BpReadingModel _$BpReadingModelFromJson(Map<String, dynamic> json) =>
    BpReadingModel(
      id: json['id'] as String,
      systolic: (json['systolic'] as num).toInt(),
      diastolic: (json['diastolic'] as num).toInt(),
      pulse: (json['pulse'] as num?)?.toInt(),
      pulseClassification: json['pulse_classification'] as String?,
      weightKg: json['weight_kg'] as String?,
      classification: json['classification'] as String,
      dialysisPhase: json['dialysis_phase'] as String?,
      takenAt: json['taken_at'] as String,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$BpReadingModelToJson(BpReadingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'systolic': instance.systolic,
      'diastolic': instance.diastolic,
      'pulse': instance.pulse,
      'pulse_classification': instance.pulseClassification,
      'weight_kg': instance.weightKg,
      'classification': instance.classification,
      'dialysis_phase': instance.dialysisPhase,
      'taken_at': instance.takenAt,
      'notes': instance.notes,
      'created_at': instance.createdAt,
    };
