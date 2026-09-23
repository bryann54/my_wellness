import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/vitals/data/models/facility_model.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';

part 'appointment_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AppointmentModel {
  final String id;
  final String? condition;

  @JsonKey(name: 'clinic_name')
  final String clinicName;

  final FacilityModel? facility;

  @JsonKey(name: 'appointment_date')
  final String appointmentDate;

  @JsonKey(name: 'appointment_time')
  final String appointmentTime;

  final String? notes;
  final String source;
  final String? booking;

  @JsonKey(name: 'created_at')
  final String createdAt;

  const AppointmentModel({
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

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);

  Appointment toEntity() => Appointment(
    id: id,
    condition: condition,
    clinicName: clinicName,
    facility: facility?.toEntity(),
    appointmentDate: appointmentDate,
    appointmentTime: appointmentTime,
    notes: notes,
    source: source,
    booking: booking,
    createdAt: createdAt,
  );
}
