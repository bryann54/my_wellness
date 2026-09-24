// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmi_preview_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BmiPreviewModel _$BmiPreviewModelFromJson(Map<String, dynamic> json) =>
    BmiPreviewModel(
      bmi: json['bmi'] as num,
      classification: json['classification'] as String,
      deficitKg: json['deficit_kg'] as num,
    );

Map<String, dynamic> _$BmiPreviewModelToJson(BmiPreviewModel instance) =>
    <String, dynamic>{
      'bmi': instance.bmi,
      'classification': instance.classification,
      'deficit_kg': instance.deficitKg,
    };
