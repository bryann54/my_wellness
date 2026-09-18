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
      firstName: json['first_name'] as String,
      surname: json['surname'] as String,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      nationalIdNumber: json['national_id_number'] as String?,
    );

Map<String, dynamic> _$SignupRequestModelToJson(SignupRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'phone': instance.phone,
      'password': instance.password,
      'first_name': instance.firstName,
      'surname': instance.surname,
      'gender': instance.gender,
      'date_of_birth': instance.dateOfBirth,
      'national_id_number': instance.nationalIdNumber,
    };
