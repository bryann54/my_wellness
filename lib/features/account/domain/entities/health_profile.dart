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
  final bool? cancerDiagnosed;
  final DateTime? cancerDiagnosedDeclaredAt;

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
    this.cancerDiagnosed,
    this.cancerDiagnosedDeclaredAt,
  });

  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  HealthProfile copyWith({
    String? email,
    String? fullName,
    String? phone,
    int? age,
    bool? ageStale,
    String? dateOfBirth,
    double? weightKg,
    double? heightCm,
    bool? bmiStale,
    String? gender,
    String? county,
    int? subCounty,
    int? constituency,
    int? ward,
    String? occupation,
    String? memberCode,
    bool? healthProfileCompleted,
    bool? hasHypertension,
    bool? onHtnMedication,
    String? htnMedications,
    bool? hasDiabetes,
    bool? onDmMedication,
    String? dmMedications,
    bool? htnOnboardingSeen,
    bool? dmOnboardingSeen,
    String? shaBeneficiaryId,
    String? shaBeneficiaryIdType,
    String? nationalIdNumber,
    bool? analyticsOptOut,
    bool? shaDataSharingConsent,
    bool? cancerDiagnosed,
    DateTime? cancerDiagnosedDeclaredAt,
    bool clearCancerDiagnosis = false,
  }) => HealthProfile(
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    age: age ?? this.age,
    ageStale: ageStale ?? this.ageStale,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    weightKg: weightKg ?? this.weightKg,
    heightCm: heightCm ?? this.heightCm,
    bmiStale: bmiStale ?? this.bmiStale,
    gender: gender ?? this.gender,
    county: county ?? this.county,
    subCounty: subCounty ?? this.subCounty,
    constituency: constituency ?? this.constituency,
    ward: ward ?? this.ward,
    occupation: occupation ?? this.occupation,
    memberCode: memberCode ?? this.memberCode,
    healthProfileCompleted:
        healthProfileCompleted ?? this.healthProfileCompleted,
    hasHypertension: hasHypertension ?? this.hasHypertension,
    onHtnMedication: onHtnMedication ?? this.onHtnMedication,
    htnMedications: htnMedications ?? this.htnMedications,
    hasDiabetes: hasDiabetes ?? this.hasDiabetes,
    onDmMedication: onDmMedication ?? this.onDmMedication,
    dmMedications: dmMedications ?? this.dmMedications,
    htnOnboardingSeen: htnOnboardingSeen ?? this.htnOnboardingSeen,
    dmOnboardingSeen: dmOnboardingSeen ?? this.dmOnboardingSeen,
    shaBeneficiaryId: shaBeneficiaryId ?? this.shaBeneficiaryId,
    shaBeneficiaryIdType: shaBeneficiaryIdType ?? this.shaBeneficiaryIdType,
    nationalIdNumber: nationalIdNumber ?? this.nationalIdNumber,
    analyticsOptOut: analyticsOptOut ?? this.analyticsOptOut,
    shaDataSharingConsent: shaDataSharingConsent ?? this.shaDataSharingConsent,
    cancerDiagnosed: clearCancerDiagnosis
        ? null
        : (cancerDiagnosed ?? this.cancerDiagnosed),
    cancerDiagnosedDeclaredAt: clearCancerDiagnosis
        ? null
        : (cancerDiagnosedDeclaredAt ?? this.cancerDiagnosedDeclaredAt),
  );

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
    cancerDiagnosed,
    cancerDiagnosedDeclaredAt,
  ];
}
