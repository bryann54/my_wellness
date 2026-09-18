// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/auth/domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'id')
  final String? id;

  final String? email;

  @JsonKey(name: 'first_name')
  final String? firstName;

  final String? surname;
  final String? phone;
  final String? gender;

  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;

  @JsonKey(name: 'national_id_number')
  final String? nationalIdNumber;

  @JsonKey(name: 'is_email_verified')
  final bool? isEmailVerified;

  @JsonKey(name: 'is_phone_verified')
  final bool? isPhoneVerified;

  const UserModel({
    this.id,
    this.email,
    this.firstName,
    this.surname,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.nationalIdNumber,
    this.isEmailVerified,
    this.isPhoneVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() => UserEntity(
    id: id ?? '',
    email: email ?? '',
    firstName: firstName ?? '',
    surname: surname ?? '',
    phone: phone ?? '',
    gender: gender ?? '',
    dateOfBirth: dateOfBirth,
    nationalIdNumber: nationalIdNumber,
    isEmailVerified: isEmailVerified ?? false,
    isPhoneVerified: isPhoneVerified ?? false,
  );
}
