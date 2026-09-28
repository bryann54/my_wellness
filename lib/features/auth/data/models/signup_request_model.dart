import 'package:json_annotation/json_annotation.dart';

part 'signup_request_model.g.dart';

enum IdType { nationalId, maisha }

@JsonSerializable()
class SignupRequestModel {
  final String? email;
  final String? phone;
  final String password;

  @JsonKey(name: 'first_name')
  final String firstName;

  final String surname;
  final String? gender;

  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;

  @JsonKey(name: 'national_id_number')
  final String? nationalIdNumber;

  @JsonKey(name: 'county')
  final int? countyId;
  @JsonKey(name: 'identity_verification_id')
  final String? identityVerificationId;
  @JsonKey(name: 'sub_county')
  final int? subCountyId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final IdType? idType;

  const SignupRequestModel({
    this.email,
    this.phone,
    required this.password,
    required this.firstName,
    required this.surname,
    this.gender,
    this.dateOfBirth,
    this.nationalIdNumber,
    this.countyId,
    this.subCountyId,
    this.identityVerificationId,
    this.idType,
  }) : assert(
         email != null || phone != null,
         'At least one of email or phone must be provided',
       );

  factory SignupRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRequestModelToJson(this);
}
