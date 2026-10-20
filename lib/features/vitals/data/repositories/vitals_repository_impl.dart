import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/offline_sync/domain/repositories/sync_repository.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_remote_datasource.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';
import 'package:my_wellness/features/vitals/domain/entities/bp_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/bs_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication_scan.dart';
import 'package:my_wellness/features/vitals/domain/repositories/vitals_repository.dart';

@LazySingleton(as: VitalsRepository)
class VitalsRepositoryImpl implements VitalsRepository {
  final VitalsRemoteDataSource _remote;
  final SyncRepository _sync;

  VitalsRepositoryImpl(this._remote, this._sync);

  @override
  Future<Either<Failure, MedicationScanResult>> scanMedication({
    required String filePath,
    required String condition,
  }) async {
    try {
      return Right(
        (await _remote.scanMedication(
          filePath: filePath,
          condition: condition,
        )).toEntity(),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getAppointmentsByCondition(
    String condition,
  ) async {
    try {
      return Right(
        (await _remote.getAppointmentsByCondition(
          condition,
        )).map((model) => model.toEntity()).toList(growable: false),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<Facility>>> searchFacilities(String query) async {
    try {
      return Right(
        (await _remote.searchFacilities(
          query,
        )).map((model) => model.toEntity()).toList(growable: false),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, ({List<Appointment> items, String? nextCursor})>>
  getAppointmentsPaged({String? cursor, String? query}) async {
    try {
      final page = await _remote.getAppointmentsPaged(
        cursor: cursor,
        query: query,
      );
      return Right((
        items: page.items
            .map((model) => model.toEntity())
            .toList(growable: false),
        nextCursor: page.nextCursor,
      ));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Appointment>> createAppointment(
    Map<String, dynamic> data,
  ) async {
    try {
      return Right((await _remote.createAppointment(data)).toEntity());
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
      return Right((await _remote.updateAppointment(id, data)).toEntity());
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

  @override
  Future<Either<Failure, List<Medication>>> getMedicationsByCondition(
    String condition,
  ) async {
    try {
      return Right(
        (await _remote.getMedicationsByCondition(
          condition,
        )).map((model) => model.toEntity()).toList(growable: false),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, ({List<Medication> items, String? nextCursor})>>
  getMedicationsPaged({String? cursor, String? query}) async {
    try {
      final page = await _remote.getMedicationsPaged(
        cursor: cursor,
        query: query,
      );
      return Right((
        items: page.items
            .map((model) => model.toEntity())
            .toList(growable: false),
        nextCursor: page.nextCursor,
      ));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Medication>> createMedication(
    Map<String, dynamic> data,
  ) async {
    try {
      return Right((await _remote.createMedication(data)).toEntity());
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
      return Right((await _remote.updateMedication(id, data)).toEntity());
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

  @override
  Future<Either<Failure, List<BpReading>>> getBloodPressureReadings() async {
    try {
      return Right(
        (await _remote.getBloodPressureReadings())
            .map((model) => model.toEntity())
            .toList(growable: false),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, BpReading>> createBloodPressureReading(
    Map<String, dynamic> data,
  ) async {
    try {
      return Right((await _remote.createBloodPressureReading(data)).toEntity());
    } on NetworkException {
      final enqueued = await _sync.enqueueAction(
        actionType: 'create_bp',
        endpoint: ApiEndpoints.vitalsOfflineBp,
        payload: data,
      );
      return enqueued.fold((f) => Left(f), (_) => Right(BpReading.local(data)));
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

  @override
  Future<Either<Failure, List<BsReading>>> getBloodSugarReadings() async {
    try {
      return Right(
        (await _remote.getBloodSugarReadings())
            .map((model) => model.toEntity())
            .toList(growable: false),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, BsReading>> createBloodSugarReading(
    Map<String, dynamic> data,
  ) async {
    try {
      return Right((await _remote.createBloodSugarReading(data)).toEntity());
    } on NetworkException {
      final enqueued = await _sync.enqueueAction(
        actionType: 'create_bs',
        endpoint: ApiEndpoints.vitalsOfflineBs,
        payload: data,
      );
      return enqueued.fold((f) => Left(f), (_) => Right(BsReading.local(data)));
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
