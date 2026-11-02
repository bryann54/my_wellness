// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingSummaryModel _$BookingSummaryModelFromJson(Map<String, dynamic> json) =>
    BookingSummaryModel(
      id: json['id'] as String,
      status: json['status'] as String,
      serviceLabel: json['service_label'] as String,
      preferredDate: json['preferred_date'] as String?,
      checkedInAt: _dateOrNull(json['checked_in_at']),
      isHieManaged: json['is_hie_managed'] as bool? ?? false,
      followUpTo: _idOrNull(json['follow_up_to']),
    );

Map<String, dynamic> _$BookingSummaryModelToJson(
  BookingSummaryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'service_label': instance.serviceLabel,
  'preferred_date': instance.preferredDate,
  'checked_in_at': instance.checkedInAt?.toIso8601String(),
  'is_hie_managed': instance.isHieManaged,
  'follow_up_to': instance.followUpTo,
};

ServiceBookingModel _$ServiceBookingModelFromJson(Map<String, dynamic> json) =>
    ServiceBookingModel(
      id: json['id'] as String,
      serviceType: json['service_type'] as String,
      serviceLabel: json['service_label'] as String,
      priceKes: _priceToInt(json['price_kes']),
      status: json['status'] as String,
      requiresScheduling: json['requires_scheduling'] as bool,
      dnaTestKind: json['dna_test_kind'] as String? ?? '',
      clinicianTier: json['clinician_tier'] as String? ?? '',
      preferredLawFirm: json['preferred_law_firm'] as String? ?? '',
      preferredDate: json['preferred_date'] as String?,
      appointmentTime: _dateOrNull(json['appointment_time']),
      preferredFacility: json['preferred_facility'] as String? ?? '',
      facility: json['facility'] == null
          ? null
          : FacilityModel.fromJson(json['facility'] as Map<String, dynamic>),
      checkedInAt: _dateOrNull(json['checked_in_at']),
      contactPhone: json['contact_phone'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      followUpTo: _idOrNull(json['follow_up_to']),
      followUps:
          (json['follow_ups'] as List<dynamic>?)
              ?.map(
                (e) => BookingSummaryModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      createdAt: _dateOrNull(json['created_at']),
      isHieManaged: json['is_hie_managed'] as bool? ?? false,
      referralId: _idOrNull(json['referral']),
    );

Map<String, dynamic> _$ServiceBookingModelToJson(
  ServiceBookingModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'service_type': instance.serviceType,
  'service_label': instance.serviceLabel,
  'price_kes': instance.priceKes,
  'status': instance.status,
  'requires_scheduling': instance.requiresScheduling,
  'dna_test_kind': instance.dnaTestKind,
  'clinician_tier': instance.clinicianTier,
  'preferred_law_firm': instance.preferredLawFirm,
  'preferred_date': instance.preferredDate,
  'appointment_time': instance.appointmentTime?.toIso8601String(),
  'preferred_facility': instance.preferredFacility,
  'facility': instance.facility?.toJson(),
  'checked_in_at': instance.checkedInAt?.toIso8601String(),
  'contact_phone': instance.contactPhone,
  'notes': instance.notes,
  'follow_up_to': instance.followUpTo,
  'follow_ups': instance.followUps.map((e) => e.toJson()).toList(),
  'created_at': instance.createdAt?.toIso8601String(),
  'is_hie_managed': instance.isHieManaged,
  'referral': instance.referralId,
};
