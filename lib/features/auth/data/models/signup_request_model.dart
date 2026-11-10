import 'package:json_annotation/json_annotation.dart';

part 'signup_request_model.g.dart';

enum IdType { nationalId, maisha }

@JsonSerializable()
class SignupRequestModel {
  @JsonKey(includeIfNull: false)
  final String? email;

  @JsonKey(includeIfNull: false)
  final String? phone;

  final String password;

  @JsonKey(name: 'first_name', includeIfNull: false)
  final String? firstName;

  @JsonKey(includeIfNull: false)
  final String? surname;

  @JsonKey(includeIfNull: false)
  final String? gender;

  @JsonKey(name: 'date_of_birth', includeIfNull: false)
  final String? dateOfBirth;

  @JsonKey(name: 'national_id_number', includeIfNull: false)
  final String? nationalIdNumber;

  @JsonKey(includeIfNull: false)
  final String? county;

  @JsonKey(name: 'sub_county', includeIfNull: false)
  final int? subCountyId;

  @JsonKey(name: 'constituency', includeIfNull: false)
  final int? constituencyId;

  @JsonKey(name: 'ward', includeIfNull: false)
  final int? wardId;

  @JsonKey(name: 'identity_verification_id', includeIfNull: false)
  final String? identityVerificationId;

  @JsonKey(name: 'invite_token', includeIfNull: false)
  final String? inviteToken;

  @JsonKey(name: 'accepted_terms')
  final bool acceptedTerms;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final IdType? idType;

  const SignupRequestModel({
    this.email,
    this.phone,
    required this.password,
    this.firstName,
    this.surname,
    this.gender,
    this.dateOfBirth,
    this.nationalIdNumber,
    this.county,
    this.subCountyId,
    this.constituencyId,
    this.wardId,
    this.identityVerificationId,
    this.inviteToken,
    required this.acceptedTerms,
    this.idType,
  }) : assert(
         email != null || phone != null,
         'At least one of email or phone must be provided',
       );

  factory SignupRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRequestModelToJson(this);
}
