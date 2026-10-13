// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verified_identity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifiedIdentityModel _$VerifiedIdentityModelFromJson(
  Map<String, dynamic> json,
) => VerifiedIdentityModel(
  verificationId: json['verification_id'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  otherName: json['other_name'] as String?,
  gender: json['gender'] as String?,
  dateOfBirth: json['date_of_birth'] as String?,
  phone: json['phone'] as String?,
  fromAfyaConnect: json['from_afyaconnect'] as bool? ?? false,
  countyId: (json['county_id'] as num?)?.toInt(),
  subCountyId: (json['sub_county_id'] as num?)?.toInt(),
  constituencyId: (json['constituency_id'] as num?)?.toInt(),
  wardId: (json['ward_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$VerifiedIdentityModelToJson(
  VerifiedIdentityModel instance,
) => <String, dynamic>{
  'verification_id': instance.verificationId,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'other_name': instance.otherName,
  'gender': instance.gender,
  'date_of_birth': instance.dateOfBirth,
  'phone': instance.phone,
  'from_afyaconnect': instance.fromAfyaConnect,
  'county_id': instance.countyId,
  'sub_county_id': instance.subCountyId,
  'constituency_id': instance.constituencyId,
  'ward_id': instance.wardId,
};
