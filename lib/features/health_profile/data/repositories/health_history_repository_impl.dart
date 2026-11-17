import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/health_profile/data/datasources/health_history_remote_datasource.dart';
import 'package:my_wellness/features/health_profile/domain/entities/health_history.dart';
import 'package:my_wellness/features/health_profile/domain/repositories/health_history_repository.dart';

@LazySingleton(as: HealthHistoryRepository)
class HealthHistoryRepositoryImpl implements HealthHistoryRepository {
  const HealthHistoryRepositoryImpl(this._remote);

  final HealthHistoryRemoteDataSource _remote;

  @override
  Future<Either<Failure, HealthHistory>> load() async {
    try {
      return Right(_map(await _remote.load()));
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException {
      return const Left(ServerFailure());
    } on Exception catch (error) {
      return Left(GeneralFailure(error: error.toString()));
    }
  }

  HealthHistory _map(Map<String, dynamic> value) => HealthHistory(
    bpAttentionNotice: _optional(value['bp_attention_notice']),
    bloodPressureReadings: _maps(
      value['bp_readings'],
    ).map(_bloodPressure).toList(growable: false),
    bloodSugarReadings: _maps(
      value['bs_readings'],
    ).map(_bloodSugar).toList(growable: false),
    vitalSigns: _maps(
      value['vital_signs'],
    ).map(_vitalSign).toList(growable: false),
    diagnoses: _maps(
      value['diagnoses'],
    ).map(_diagnosis).toList(growable: false),
    allergies: _maps(value['allergies']).map(_allergy).toList(growable: false),
    labResults: _maps(
      value['lab_results'],
    ).map(_labResult).toList(growable: false),
    procedures: _maps(
      value['procedure_records'],
    ).map(_procedure).toList(growable: false),
    prescriptions: _maps(
      value['prescriptions'],
    ).map(_prescription).toList(growable: false),
    immunizations: _maps(
      value['immunizations'],
    ).map(_immunization).toList(growable: false),
  );

  BloodPressureRecord _bloodPressure(Map<String, dynamic> value) =>
      BloodPressureRecord(
        id: _id(value),
        systolic: _integer(value['systolic']),
        diastolic: _integer(value['diastolic']),
        pulse: _integer(value['pulse']),
        monitorBand: _optional(value['monitor_band']),
        monitorBandLabel: _optional(value['monitor_band_label']),
        dialysisPhase: _optional(value['dialysis_phase']),
        notes: _optional(value['notes']),
        takenAt: _date(value['taken_at']),
        needsAttention: value['needs_attention'] == true,
      );

  BloodSugarRecord _bloodSugar(Map<String, dynamic> value) => BloodSugarRecord(
    id: _id(value),
    value: _text(value['value']),
    unit: _optional(value['unit']),
    readingTypeLabel: _optional(value['reading_type_label']),
    classification: _optional(value['classification']),
    classificationLabel: _optional(value['classification_label']),
    displayColour: _optional(value['display_colour']),
    notes: _optional(value['notes']),
    takenAt: _date(value['taken_at']),
  );

  VitalSignRecord _vitalSign(Map<String, dynamic> value) => VitalSignRecord(
    id: _id(value),
    typeLabel:
        _optional(value['vital_type_label']) ??
        _optional(value['vital_type']) ??
        '',
    value: _text(value['value']),
    unit: _optional(value['unit']),
    notes: _optional(value['notes']),
    takenAt: _date(value['taken_at'] ?? value['created_at']),
  );

  DiagnosisRecord _diagnosis(Map<String, dynamic> value) => DiagnosisRecord(
    id: _id(value),
    condition: _text(value['condition']),
    severity: _optional(value['severity']),
    details: _optional(value['details']),
    recordedAt: _date(value['created_at']),
  );

  AllergyRecord _allergy(Map<String, dynamic> value) => AllergyRecord(
    id: _id(value),
    allergen: _text(value['allergen']),
    severity: _optional(value['severity']),
    reaction: _optional(value['reaction']),
    notes: _optional(value['notes']),
    recordedAt: _date(value['created_at']),
  );

  LabResultRecord _labResult(Map<String, dynamic> value) => LabResultRecord(
    id: _id(value),
    testName: _text(value['test_name']),
    value: _text(value['result_value']),
    unit: _optional(value['unit']),
    referenceRange: _optional(value['reference_range']),
    interpretation: _optional(value['interpretation']),
    interpretationLabel: _optional(value['interpretation_label']),
    specimenTypeLabel: _optional(value['specimen_type_label']),
    specimenCollectedAt: _date(value['specimen_collected_at']),
    status: _optional(value['status']),
    statusLabel: _optional(value['status_label']),
    notes: _optional(value['notes']),
    recordedAt: _date(value['result_date'] ?? value['created_at']),
  );

  ProcedureRecord _procedure(Map<String, dynamic> value) => ProcedureRecord(
    id: _id(value),
    name: _text(value['procedure_name']),
    notes: _optional(value['notes']),
    recordedAt: _date(value['performed_date'] ?? value['created_at']),
  );

  PrescriptionRecord _prescription(Map<String, dynamic> value) =>
      PrescriptionRecord(
        id: _id(value),
        medication: _text(value['medication']),
        dosage: _optional(value['dosage']),
        startDate: _date(value['start_date']),
        endDate: _date(value['end_date']),
        instructions: _optional(value['instructions']),
        recordedAt: _date(value['created_at']),
      );

  ImmunizationRecord _immunization(Map<String, dynamic> value) =>
      ImmunizationRecord(
        id: _id(value),
        vaccineName: _text(value['vaccine_name']),
        doseNumber: _optional(value['dose_number']),
        status: _optional(value['status']),
        notes: _optional(value['notes']),
        recordedAt: _date(value['occurrence_date'] ?? value['created_at']),
      );

  List<Map<String, dynamic>> _maps(dynamic value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList(growable: false)
      : const [];

  String _text(dynamic value) => value?.toString().trim() ?? '';

  String? _optional(dynamic value) {
    final result = _text(value);
    return result.isEmpty ? null : result;
  }

  int? _integer(dynamic value) => value is num
      ? value.toInt()
      : int.tryParse(value?.toString().trim() ?? '');

  DateTime? _date(dynamic value) => DateTime.tryParse(_text(value));

  String _id(Map<String, dynamic> value) =>
      _optional(value['id']) ?? value.hashCode.toString();
}
