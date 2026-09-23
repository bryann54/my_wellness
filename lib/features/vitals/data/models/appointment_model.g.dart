// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) =>
    AppointmentModel(
      id: json['id'] as String,
      condition: json['condition'] as String?,
      clinicName: json['clinic_name'] as String,
      facility: json['facility'] == null
          ? null
          : FacilityModel.fromJson(json['facility'] as Map<String, dynamic>),
      appointmentDate: json['appointment_date'] as String,
      appointmentTime: json['appointment_time'] as String,
      notes: json['notes'] as String?,
      source: json['source'] as String? ?? 'manual',
      booking: json['booking'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$AppointmentModelToJson(AppointmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'condition': instance.condition,
      'clinic_name': instance.clinicName,
      'facility': instance.facility?.toJson(),
      'appointment_date': instance.appointmentDate,
      'appointment_time': instance.appointmentTime,
      'notes': instance.notes,
      'source': instance.source,
      'booking': instance.booking,
      'created_at': instance.createdAt,
    };
