import 'package:equatable/equatable.dart';

class Facility extends Equatable {
  final String id;
  final String name;
  final String? town;
  final String? county;

  const Facility({
    required this.id,
    required this.name,
    this.town,
    this.county,
  });

  @override
  List<Object?> get props => [id, name, town, county];
}

class Appointment extends Equatable {
  final String id;

  /// 'hypertension' | 'diabetes' | null (unconditioned)
  final String? condition;

  final String clinicName;
  final Facility? facility;
  final String appointmentDate; // yyyy-MM-dd
  final String appointmentTime; // ISO time
  final String? notes;
  final String source; // 'manual' | ...
  final String? booking; // booking UUID if linked
  final String createdAt; // ISO timestamp

  const Appointment({
    required this.id,
    this.condition,
    required this.clinicName,
    this.facility,
    required this.appointmentDate,
    required this.appointmentTime,
    this.notes,
    this.source = 'manual',
    this.booking,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    condition,
    clinicName,
    facility,
    appointmentDate,
    appointmentTime,
    notes,
    source,
    booking,
    createdAt,
  ];
}
