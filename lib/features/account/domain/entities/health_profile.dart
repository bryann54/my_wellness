import 'package:equatable/equatable.dart';

class HealthProfile extends Equatable {
  final String email;
  final String fullName;
  final String phone;

  final int? age;
  final bool ageStale;

  final String? dateOfBirth;
  final double? weightKg;
  final double? heightCm;
  final bool bmiStale;

  final String gender;

  final String? county;
  final int? subCounty;
  final int? constituency;
  final int? ward;
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

  const HealthProfile({
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

  /// Convenience display name — prefers `fullName`, falls back to the email
  /// local part.
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
