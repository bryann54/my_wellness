import 'package:equatable/equatable.dart';

class VerifiedIdentity extends Equatable {
  final String verificationId;
  final String firstName;
  final String lastName;
  final String? otherName;
  final String? gender;
  final String? dateOfBirth;
  final String? phone;
  final bool fromAfyaConnect;
  final int? countyId;
  final int? subCountyId;
  final int? constituencyId;
  final int? wardId;

  const VerifiedIdentity({
    required this.verificationId,
    required this.firstName,
    required this.lastName,
    this.otherName,
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.fromAfyaConnect = false,
    this.countyId,
    this.subCountyId,
    this.constituencyId,
    this.wardId,
  });

  String get fullSurname => [
    lastName,
    if (otherName != null && otherName!.isNotEmpty) otherName,
  ].join(' ').trim();

  @override
  List<Object?> get props => [
    verificationId,
    firstName,
    lastName,
    otherName,
    gender,
    dateOfBirth,
    phone,
    fromAfyaConnect,
    countyId,
    subCountyId,
    constituencyId,
    wardId,
  ];
}
