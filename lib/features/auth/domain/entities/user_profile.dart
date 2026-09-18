import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String email;
  final String fullName;
  final String phone;

  /// Present on the server but stale for lack of weight/height inputs.
  final int? age;
  final bool ageStale;

  final String? dateOfBirth; // ISO yyyy-MM-dd
  final double? weightKg;
  final double? heightCm;
  final bool bmiStale;

  final String gender;

  final String? county;
  final int? subCounty;
  final String? constituency;
  final String? ward;
  final String occupation;

  final String memberCode;
  final bool healthProfileCompleted;

  final bool? hasHypertension;
  final bool? onHtnMedication;
  final String htnMedications;
  final bool? hasDiabetes;
  final bool? onDmMedication;
  final String dmMedications;

  final bool htnOnboardingSeen;
  final bool dmOnboardingSeen;

  final String shaBeneficiaryId;
  final String shaBeneficiaryIdType;
  final String? nationalIdNumber;

  final bool analyticsOptOut;
  final bool shaDataSharingConsent;

  const UserProfile({
    required this.email,
    required this.fullName,
    required this.phone,
    this.age,
    this.ageStale = false,
    this.dateOfBirth,
    this.weightKg,
    this.heightCm,
    this.bmiStale = false,
    required this.gender,
    this.county,
    this.subCounty,
    this.constituency,
    this.ward,
    this.occupation = '',
    required this.memberCode,
    this.healthProfileCompleted = false,
    this.hasHypertension,
    this.onHtnMedication,
    this.htnMedications = '',
    this.hasDiabetes,
    this.onDmMedication,
    this.dmMedications = '',
    this.htnOnboardingSeen = false,
    this.dmOnboardingSeen = false,
    this.shaBeneficiaryId = '',
    this.shaBeneficiaryIdType = '',
    this.nationalIdNumber,
    this.analyticsOptOut = false,
    this.shaDataSharingConsent = false,
  });

  /// Convenience for headers: try full name, fall back to email local part.
  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  @override
  List<Object?> get props => [
    email,
    fullName,
    phone,
    age,
    ageStale,
    dateOfBirth,
    weightKg,
    heightCm,
    bmiStale,
    gender,
    county,
    subCounty,
    constituency,
    ward,
    occupation,
    memberCode,
    healthProfileCompleted,
    hasHypertension,
    onHtnMedication,
    htnMedications,
    hasDiabetes,
    onDmMedication,
    dmMedications,
    htnOnboardingSeen,
    dmOnboardingSeen,
    shaBeneficiaryId,
    shaBeneficiaryIdType,
    nationalIdNumber,
    analyticsOptOut,
    shaDataSharingConsent,
  ];
}
