import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/auth/domain/entities/verified_identity.dart';

part 'verified_identity_model.g.dart';

@JsonSerializable()
class VerifiedIdentityModel {
  @JsonKey(name: 'verification_id')
  final String verificationId;

  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String lastName;

  @JsonKey(name: 'other_name')
  final String? otherName;

  final String? gender;

  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;

  const VerifiedIdentityModel({
    required this.verificationId,
    required this.firstName,
    required this.lastName,
    this.otherName,
    this.gender,
    this.dateOfBirth,
  });

  factory VerifiedIdentityModel.fromJson(Map<String, dynamic> json) =>
      _$VerifiedIdentityModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifiedIdentityModelToJson(this);

  VerifiedIdentity toEntity() => VerifiedIdentity(
    verificationId: verificationId,
    firstName: firstName,
    lastName: lastName,
    otherName: otherName,
    gender: gender,
    dateOfBirth: dateOfBirth,
  );
}
