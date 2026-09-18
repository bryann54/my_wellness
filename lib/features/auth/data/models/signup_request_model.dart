import 'package:json_annotation/json_annotation.dart';

part 'signup_request_model.g.dart';

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

  const SignupRequestModel({
    this.email,
    this.phone,
    required this.password,
    required this.firstName,
    required this.surname,
    this.gender,
    this.dateOfBirth,
    this.nationalIdNumber,
  }) : assert(
         email != null || phone != null,
         'At least one of email or phone must be provided',
       );

  factory SignupRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRequestModelToJson(this);
}
