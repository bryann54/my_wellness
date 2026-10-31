// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupRequestModel _$SignupRequestModelFromJson(Map<String, dynamic> json) =>
    SignupRequestModel(
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      password: json['password'] as String,
      nationalIdNumber: json['national_id_number'] as String?,
      county: json['county'] as String?,
      subCountyId: (json['sub_county'] as num?)?.toInt(),
      constituencyId: (json['constituency'] as num?)?.toInt(),
      wardId: (json['ward'] as num?)?.toInt(),
      identityVerificationId: json['identity_verification_id'] as String?,
      inviteToken: json['invite_token'] as String?,
      subdomain: json['subdomain'] as String?,
    );

Map<String, dynamic> _$SignupRequestModelToJson(SignupRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'phone': instance.phone,
      'password': instance.password,
      'national_id_number': instance.nationalIdNumber,
      'county': instance.county,
      'sub_county': instance.subCountyId,
      'constituency': instance.constituencyId,
      'ward': instance.wardId,
      'identity_verification_id': instance.identityVerificationId,
      'invite_token': instance.inviteToken,
      'subdomain': instance.subdomain,
    };
