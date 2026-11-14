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
      final response = await _remote.load();
      return Right(_map(response.clinical, response.journey));
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

  HealthHistory _map(Map<String, dynamic> clinical, List<dynamic> journey) {
    final bp = _maps(clinical['bp_readings']);
    final bs = _maps(clinical['bs_readings']);
    final vitals = _maps(clinical['vital_signs']);
    return HealthHistory(
      latestBloodPressure: bp.isEmpty ? null : _bloodPressure(bp.first),
      latestBloodSugar: bs.isEmpty ? null : _bloodSugar(bs.first),
      latestVitalSign: vitals.isEmpty ? null : _vital(vitals.first),
      diagnoses: _maps(clinical['diagnoses']).map(_diagnosis).toList(),
      allergies: _maps(clinical['allergies']).map(_allergy).toList(),
      labResults: _maps(clinical['lab_results']).map(_lab).toList(),
      procedures: _maps(clinical['procedure_records']).map(_procedure).toList(),
      prescriptions: _maps(
        clinical['prescriptions'],
      ).map(_prescription).toList(),
      immunizations: _maps(
        clinical['immunizations'],
      ).map(_immunization).toList(),
      journey: _maps(journey).map(_journey).toList(),
    );
  }

  List<Map<String, dynamic>> _maps(dynamic value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList(growable: false)
      : const [];

  String _text(dynamic value) => value?.toString().trim() ?? '';
  String? _optional(dynamic value) {
    final result = _text(value);
    return result.isEmpty ? null : result;
  }

  DateTime? _date(dynamic value) => DateTime.tryParse(_text(value));

  String _id(Map<String, dynamic> value) =>
      _optional(value['id']) ?? value.hashCode.toString();

  HealthMeasurement _bloodPressure(Map<String, dynamic> value) =>
      HealthMeasurement(
        label: 'Most recent blood pressure',
        value: '${_text(value['systolic'])}/${_text(value['diastolic'])}',
        unit: 'mmHg',
        detail: _optional(
          value['monitor_band_label'] ?? value['classification_label'],
        ),
        recordedAt: _date(value['taken_at']),
        needsAttention: value['needs_attention'] == true,
      );

  HealthMeasurement _bloodSugar(Map<String, dynamic> value) =>
      HealthMeasurement(
        label: 'Latest blood glucose',
        value: _text(value['value']),
        unit: _optional(value['unit']),
        detail: _optional(
          value['decision_title'] ?? value['classification_label'],
        ),
        recordedAt: _date(value['taken_at']),
        needsAttention: const {
          'orange',
          'red',
        }.contains(_text(value['decision_colour'])),
      );

  HealthMeasurement _vital(Map<String, dynamic> value) => HealthMeasurement(
    label: _optional(value['type_label'] ?? value['name']) ?? 'Latest vital',
    value: _text(value['value']),
    unit: _optional(value['unit']),
    detail: _optional(value['notes']),
    recordedAt: _date(value['recorded_at'] ?? value['created_at']),
  );

  HealthRecordItem _diagnosis(Map<String, dynamic> value) => HealthRecordItem(
    id: _id(value),
    title: _text(value['condition']),
    subtitle: _optional(value['severity']),
    detail: _optional(value['details']),
    recordedAt: _date(value['created_at']),
  );

  HealthRecordItem _allergy(Map<String, dynamic> value) => HealthRecordItem(
    id: _id(value),
    title: _text(value['allergen']),
    subtitle: _optional(value['severity']),
    detail: _join([
      if (_optional(value['reaction']) case final reaction?)
        'Reaction: $reaction',
      _optional(value['notes']),
    ]),
    recordedAt: _date(value['created_at']),
  );

  HealthRecordItem _lab(Map<String, dynamic> value) => HealthRecordItem(
    id: _id(value),
    title: _labTitle(value),
    subtitle: _optional(value['interpretation_label'] ?? value['status_label']),
    detail: _join([
      if (_optional(value['reference_range']) case final range?)
        'Reference range: $range',
      _optional(value['notes']),
    ]),
    recordedAt: _date(value['result_date'] ?? value['created_at']),
  );

  HealthRecordItem _procedure(Map<String, dynamic> value) => HealthRecordItem(
    id: _id(value),
    title: _text(value['procedure_name']),
    detail: _optional(value['notes']),
    recordedAt: _date(value['performed_date'] ?? value['created_at']),
  );

  HealthRecordItem _prescription(Map<String, dynamic> value) =>
      HealthRecordItem(
        id: _id(value),
        title: _text(value['medication']),
        subtitle: _optional(value['dosage']),
        detail: _optional(value['instructions']),
        recordedAt: _date(value['start_date'] ?? value['created_at']),
      );

  String _labTitle(Map<String, dynamic> value) {
    final unit = _optional(value['unit']);
    return '${_text(value['test_name'])}: ${_text(value['result_value'])}'
        '${unit == null ? '' : ' $unit'}';
  }

  HealthRecordItem _immunization(Map<String, dynamic> value) =>
      HealthRecordItem(
        id: _id(value),
        title: _text(value['vaccine_name']),
        subtitle: value['dose_number'] == null
            ? _optional(value['status'])
            : 'Dose ${value['dose_number']}',
        detail: _optional(value['notes']),
        recordedAt: _date(value['occurrence_date'] ?? value['created_at']),
      );

  HealthJourneyItem _journey(Map<String, dynamic> value) {
    final risk = value['risk_score'] is Map
        ? Map<String, dynamic>.from(value['risk_score'] as Map)
        : const <String, dynamic>{};
    final referral = value['referral'] is Map
        ? Map<String, dynamic>.from(value['referral'] as Map)
        : const <String, dynamic>{};
    final facility = referral['recommended_facility'] is Map
        ? Map<String, dynamic>.from(referral['recommended_facility'] as Map)
        : const <String, dynamic>{};
    return HealthJourneyItem(
      sessionId: _text(value['session_id']),
      assessmentSlug: _text(value['assessment_slug']),
      completedAt: _date(value['completed_at']) ?? DateTime(1970),
      band: _optional(risk['band']),
      bandLabel: _optional(risk['band_label']),
      summary: _optional(risk['band_blurb']),
      hasActiveWarning: risk['has_active_warning'] == true,
      referralStatus: _optional(referral['status']),
      referralFacility: _optional(facility['name']),
    );
  }

  String? _join(List<String?> parts) {
    final values = parts.whereType<String>().where((e) => e.isNotEmpty);
    return values.isEmpty ? null : values.join(' · ');
  }
}
