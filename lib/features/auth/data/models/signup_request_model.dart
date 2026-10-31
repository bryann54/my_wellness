import 'package:json_annotation/json_annotation.dart';

part 'signup_request_model.g.dart';

enum IdType { nationalId, maisha }

@JsonSerializable()
class SignupRequestModel {
  final String? email;
  final String? phone;
  final String password;

  @JsonKey(name: 'national_id_number')
  final String? nationalIdNumber;

  @JsonKey(name: 'county')
  final String? county;

  @JsonKey(name: 'sub_county')
  final int? subCountyId;

  @JsonKey(name: 'constituency')
  final int? constituencyId;

  @JsonKey(name: 'ward')
  final int? wardId;

  @JsonKey(name: 'identity_verification_id')
  final String? identityVerificationId;

  @JsonKey(name: 'invite_token')
  final String? inviteToken;

  final String? subdomain;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final IdType? idType;

  const SignupRequestModel({
    this.email,
    this.phone,
    required this.password,
    this.nationalIdNumber,
    this.county,
    this.subCountyId,
    this.constituencyId,
    this.wardId,
    this.identityVerificationId,
    this.inviteToken,
    this.subdomain,
    this.idType,
  }) : assert(
         email != null || phone != null,
         'At least one of email or phone must be provided',
       );

  factory SignupRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRequestModelToJson(this);
}
