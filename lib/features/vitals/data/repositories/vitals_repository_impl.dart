import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_remote_datasource.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';
import 'package:my_wellness/features/vitals/domain/entities/bp_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/bs_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication.dart';
import 'package:my_wellness/features/vitals/domain/repositories/vitals_repository.dart';

@LazySingleton(as: VitalsRepository)
class VitalsRepositoryImpl implements VitalsRepository {
  final VitalsRemoteDataSource _remote;
  VitalsRepositoryImpl(this._remote);

  // ── Appointments ────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<Appointment>>> getAppointmentsByCondition(
    String condition,
  ) async {
    try {
      return Right(await _remote.getAppointmentsByCondition(condition));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, ({List<Appointment> items, String? nextCursor})>>
  getAppointmentsPaged({String? cursor, String? query}) async {
    try {
      return Right(
        await _remote.getAppointmentsPaged(cursor: cursor, query: query),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Appointment>> createAppointment(
    Map<String, dynamic> data,
  ) async {
    try {
      return Right(await _remote.createAppointment(data));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Appointment>> updateAppointment(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      return Right(await _remote.updateAppointment(id, data));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAppointment(String id) async {
    try {
      await _remote.deleteAppointment(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  // ── Medications ─────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<Medication>>> getMedicationsByCondition(
    String condition,
  ) async {
    try {
      return Right(await _remote.getMedicationsByCondition(condition));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, ({List<Medication> items, String? nextCursor})>>
  getMedicationsPaged({String? cursor, String? query}) async {
    try {
      return Right(
        await _remote.getMedicationsPaged(cursor: cursor, query: query),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Medication>> createMedication(
    Map<String, dynamic> data,
  ) async {
    try {
      return Right(await _remote.createMedication(data));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Medication>> updateMedication(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      return Right(await _remote.updateMedication(id, data));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedication(String id) async {
    try {
      await _remote.deleteMedication(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  // ── Blood pressure ──────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<BpReading>>> getBloodPressureReadings() async {
    try {
      return Right(await _remote.getBloodPressureReadings());
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, BpReading>> createBloodPressureReading(
    Map<String, dynamic> data,
  ) async {
    try {
      return Right(await _remote.createBloodPressureReading(data));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBloodPressureReading(String id) async {
    try {
      await _remote.deleteBloodPressureReading(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  // ── Blood sugar ─────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<BsReading>>> getBloodSugarReadings() async {
    try {
      return Right(await _remote.getBloodSugarReadings());
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, BsReading>> createBloodSugarReading(
    Map<String, dynamic> data,
  ) async {
    try {
      return Right(await _remote.createBloodSugarReading(data));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBloodSugarReading(String id) async {
    try {
      await _remote.deleteBloodSugarReading(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  Failure _map(Exception e) {
    if (e is UnauthorizedException) return const UnauthorizedFailure();
    if (e is ValidationException) return ValidationFailure(error: e.message);
    if (e is NotFoundException) return NotFoundFailure(error: e.message);
    if (e is NetworkException) return const NetworkFailure();
    if (e is ServerException) return const ServerFailure();
    return GeneralFailure(error: e.toString());
  }
}
