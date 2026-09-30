import 'package:equatable/equatable.dart';

class VerifiedIdentity extends Equatable {
  final String verificationId;
  final String firstName;
  final String lastName;
  final String? otherName;
  final String? gender;
  final String? dateOfBirth;

  const VerifiedIdentity({
    required this.verificationId,
    required this.firstName,
    required this.lastName,
    this.otherName,
    this.gender,
    this.dateOfBirth,
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
  ];
}
