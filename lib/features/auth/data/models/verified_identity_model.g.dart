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
};
