import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';
import 'package:my_wellness/features/vitals/domain/entities/bp_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/bs_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication.dart';
import 'package:my_wellness/features/vitals/domain/repositories/vitals_repository.dart';

// ── Appointments ────────────────────────────────────────────────────────────

@lazySingleton
class GetAppointmentsByConditionUseCase
    implements UseCase<List<Appointment>, String> {
  final VitalsRepository _repo;
  GetAppointmentsByConditionUseCase(this._repo);
  @override
  Future<Either<Failure, List<Appointment>>> call(String condition) =>
      _repo.getAppointmentsByCondition(condition);
}

@lazySingleton
class GetAppointmentsPagedUseCase
    implements
        UseCase<
          ({List<Appointment> items, String? nextCursor}),
          ({String? cursor, String? query})
        > {
  final VitalsRepository _repo;
  GetAppointmentsPagedUseCase(this._repo);
  @override
  Future<Either<Failure, ({List<Appointment> items, String? nextCursor})>> call(
    ({String? cursor, String? query}) params,
  ) => _repo.getAppointmentsPaged(cursor: params.cursor, query: params.query);
}

@lazySingleton
class CreateAppointmentUseCase
    implements UseCase<Appointment, Map<String, dynamic>> {
  final VitalsRepository _repo;
  CreateAppointmentUseCase(this._repo);
  @override
  Future<Either<Failure, Appointment>> call(Map<String, dynamic> params) =>
      _repo.createAppointment(params);
}

@lazySingleton
class DeleteAppointmentUseCase implements UseCase<void, String> {
  final VitalsRepository _repo;
  DeleteAppointmentUseCase(this._repo);
  @override
  Future<Either<Failure, void>> call(String id) => _repo.deleteAppointment(id);
}

// ── Medications ─────────────────────────────────────────────────────────────

@lazySingleton
class GetMedicationsByConditionUseCase
    implements UseCase<List<Medication>, String> {
  final VitalsRepository _repo;
  GetMedicationsByConditionUseCase(this._repo);
  @override
  Future<Either<Failure, List<Medication>>> call(String condition) =>
      _repo.getMedicationsByCondition(condition);
}

@lazySingleton
class GetMedicationsPagedUseCase
    implements
        UseCase<
          ({List<Medication> items, String? nextCursor}),
          ({String? cursor, String? query})
        > {
  final VitalsRepository _repo;
  GetMedicationsPagedUseCase(this._repo);
  @override
  Future<Either<Failure, ({List<Medication> items, String? nextCursor})>> call(
    ({String? cursor, String? query}) params,
  ) => _repo.getMedicationsPaged(cursor: params.cursor, query: params.query);
}

@lazySingleton
class CreateMedicationUseCase
    implements UseCase<Medication, Map<String, dynamic>> {
  final VitalsRepository _repo;
  CreateMedicationUseCase(this._repo);
  @override
  Future<Either<Failure, Medication>> call(Map<String, dynamic> params) =>
      _repo.createMedication(params);
}

@lazySingleton
class DeleteMedicationUseCase implements UseCase<void, String> {
  final VitalsRepository _repo;
  DeleteMedicationUseCase(this._repo);
  @override
  Future<Either<Failure, void>> call(String id) => _repo.deleteMedication(id);
}

// ── Blood pressure ──────────────────────────────────────────────────────────

@lazySingleton
class GetBloodPressureReadingsUseCase
    implements UseCase<List<BpReading>, NoParams> {
  final VitalsRepository _repo;
  GetBloodPressureReadingsUseCase(this._repo);
  @override
  Future<Either<Failure, List<BpReading>>> call(NoParams params) =>
      _repo.getBloodPressureReadings();
}

@lazySingleton
class CreateBloodPressureReadingUseCase
    implements UseCase<BpReading, Map<String, dynamic>> {
  final VitalsRepository _repo;
  CreateBloodPressureReadingUseCase(this._repo);
  @override
  Future<Either<Failure, BpReading>> call(Map<String, dynamic> params) =>
      _repo.createBloodPressureReading(params);
}

@lazySingleton
class DeleteBloodPressureReadingUseCase implements UseCase<void, String> {
  final VitalsRepository _repo;
  DeleteBloodPressureReadingUseCase(this._repo);
  @override
  Future<Either<Failure, void>> call(String id) =>
      _repo.deleteBloodPressureReading(id);
}

// ── Blood sugar ─────────────────────────────────────────────────────────────

@lazySingleton
class GetBloodSugarReadingsUseCase
    implements UseCase<List<BsReading>, NoParams> {
  final VitalsRepository _repo;
  GetBloodSugarReadingsUseCase(this._repo);
  @override
  Future<Either<Failure, List<BsReading>>> call(NoParams params) =>
      _repo.getBloodSugarReadings();
}

@lazySingleton
class CreateBloodSugarReadingUseCase
    implements UseCase<BsReading, Map<String, dynamic>> {
  final VitalsRepository _repo;
  CreateBloodSugarReadingUseCase(this._repo);
  @override
  Future<Either<Failure, BsReading>> call(Map<String, dynamic> params) =>
      _repo.createBloodSugarReading(params);
}

@lazySingleton
class DeleteBloodSugarReadingUseCase implements UseCase<void, String> {
  final VitalsRepository _repo;
  DeleteBloodSugarReadingUseCase(this._repo);
  @override
  Future<Either<Failure, void>> call(String id) =>
      _repo.deleteBloodSugarReading(id);
}
