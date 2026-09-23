// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bs_reading_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BsReadingModel _$BsReadingModelFromJson(Map<String, dynamic> json) =>
    BsReadingModel(
      id: json['id'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String,
      readingType: json['reading_type'] as String,
      mealTiming: json['meal_timing'] as String?,
      weightKg: json['weight_kg'] as String?,
      classification: json['classification'] as String,
      takenAt: json['taken_at'] as String,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$BsReadingModelToJson(BsReadingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'unit': instance.unit,
      'reading_type': instance.readingType,
      'meal_timing': instance.mealTiming,
      'weight_kg': instance.weightKg,
      'classification': instance.classification,
      'taken_at': instance.takenAt,
      'notes': instance.notes,
      'created_at': instance.createdAt,
    };
