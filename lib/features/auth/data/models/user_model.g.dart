// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String?,
  email: json['email'] as String?,
  firstName: json['first_name'] as String?,
  surname: json['surname'] as String?,
  phone: json['phone'] as String?,
  gender: json['gender'] as String?,
  dateOfBirth: json['date_of_birth'] as String?,
  nationalIdNumber: json['national_id_number'] as String?,
  isEmailVerified: json['is_email_verified'] as bool?,
  isPhoneVerified: json['is_phone_verified'] as bool?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'first_name': instance.firstName,
  'surname': instance.surname,
  'phone': instance.phone,
  'gender': instance.gender,
  'date_of_birth': instance.dateOfBirth,
  'national_id_number': instance.nationalIdNumber,
  'is_email_verified': instance.isEmailVerified,
  'is_phone_verified': instance.isPhoneVerified,
};
