import 'package:equatable/equatable.dart';

class Facility extends Equatable {
  final String id;
  final String name;
  final String? town;
  final String? county;
  final int? kephLevel;
  final bool coversSha;

  const Facility({
    required this.id,
    required this.name,
    this.town,
    this.county,
    this.kephLevel,
    this.coversSha = false,
  });
  String get locality {
    final t = town?.trim();
    final c = county?.trim();
    if (t != null && t.isNotEmpty && c != null && c.isNotEmpty) {
      return '$t, $c';
    }
    return t?.isNotEmpty == true ? t! : (c ?? '');
  }

  @override
  List<Object?> get props => [id, name, town, county, kephLevel, coversSha];
}

class Appointment extends Equatable {
  final String id;
  final String? condition;

  final String clinicName;
  final Facility? facility;
  final String appointmentDate;
  final String appointmentTime;
  final String? notes;
  final String source;
  final String? booking;
  final String createdAt;

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
