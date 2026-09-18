import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String surname;
  final String phone;
  final String gender;
  final String? dateOfBirth; // ISO yyyy-MM-dd
  final String? nationalIdNumber;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.surname,
    required this.phone,
    required this.gender,
    this.dateOfBirth,
    this.nationalIdNumber,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  String get fullName =>
      [firstName, surname].where((s) => s.isNotEmpty).join(' ').trim();

  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    surname,
    phone,
    gender,
    dateOfBirth,
    nationalIdNumber,
    isEmailVerified,
    isPhoneVerified,
  ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? firstName,
    String? surname,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? nationalIdNumber,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationalIdNumber: nationalIdNumber ?? this.nationalIdNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }
}
