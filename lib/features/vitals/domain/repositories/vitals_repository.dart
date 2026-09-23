import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';
import 'package:my_wellness/features/vitals/domain/entities/bp_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/bs_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication.dart';

abstract class VitalsRepository {
  Future<Either<Failure, List<Appointment>>> getAppointmentsByCondition(
    String condition,
  );
  Future<Either<Failure, ({List<Appointment> items, String? nextCursor})>>
  getAppointmentsPaged({String? cursor, String? query});
  Future<Either<Failure, Appointment>> createAppointment(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, Appointment>> updateAppointment(
    String id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteAppointment(String id);

  Future<Either<Failure, List<Medication>>> getMedicationsByCondition(
    String condition,
  );
  Future<Either<Failure, ({List<Medication> items, String? nextCursor})>>
  getMedicationsPaged({String? cursor, String? query});
  Future<Either<Failure, Medication>> createMedication(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, Medication>> updateMedication(
    String id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteMedication(String id);

  Future<Either<Failure, List<BpReading>>> getBloodPressureReadings();
  Future<Either<Failure, BpReading>> createBloodPressureReading(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteBloodPressureReading(String id);

  Future<Either<Failure, List<BsReading>>> getBloodSugarReadings();
  Future<Either<Failure, BsReading>> createBloodSugarReading(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteBloodSugarReading(String id);
}
