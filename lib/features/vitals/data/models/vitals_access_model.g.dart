// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vitals_access_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VitalsAccessModel _$VitalsAccessModelFromJson(Map<String, dynamic> json) =>
    VitalsAccessModel(
      hasAccess: json['has_access'] as bool,
      demoRestricted: json['demo_restricted'] as bool,
      navigatorAlertedAt: json['navigator_alerted_at'] as String?,
    );

Map<String, dynamic> _$VitalsAccessModelToJson(VitalsAccessModel instance) =>
    <String, dynamic>{
      'has_access': instance.hasAccess,
      'demo_restricted': instance.demoRestricted,
      'navigator_alerted_at': instance.navigatorAlertedAt,
    };
