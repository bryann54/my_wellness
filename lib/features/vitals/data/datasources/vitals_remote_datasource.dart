import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/core/api_client/models/cursor_page.dart';
import 'package:my_wellness/features/vitals/data/models/appointment_model.dart';
import 'package:my_wellness/features/vitals/data/models/bp_reading_model.dart';
import 'package:my_wellness/features/vitals/data/models/bs_reading_model.dart';
import 'package:my_wellness/features/vitals/data/models/medication_model.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';
import 'package:my_wellness/features/vitals/domain/entities/bp_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/bs_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication.dart';

abstract class VitalsRemoteDataSource {
  Future<List<Appointment>> getAppointmentsByCondition(String condition);
  Future<({List<Appointment> items, String? nextCursor})> getAppointmentsPaged({
    String? cursor,
    String? query,
  });

  Future<Appointment> createAppointment(Map<String, dynamic> data);
  Future<Appointment> updateAppointment(String id, Map<String, dynamic> data);
  Future<void> deleteAppointment(String id);

  Future<List<Medication>> getMedicationsByCondition(String condition);

  Future<({List<Medication> items, String? nextCursor})> getMedicationsPaged({
    String? cursor,
    String? query,
  });

  Future<Medication> createMedication(Map<String, dynamic> data);
  Future<Medication> updateMedication(String id, Map<String, dynamic> data);
  Future<void> deleteMedication(String id);

  // Blood pressure
  Future<List<BpReading>> getBloodPressureReadings();
  Future<BpReading> createBloodPressureReading(Map<String, dynamic> data);
  Future<void> deleteBloodPressureReading(String id);

  // ── Blood sugar ───────────────────────────────────────────────────────────
  Future<List<BsReading>> getBloodSugarReadings();
  Future<BsReading> createBloodSugarReading(Map<String, dynamic> data);
  Future<void> deleteBloodSugarReading(String id);
}

@LazySingleton(as: VitalsRemoteDataSource)
class VitalsRemoteDataSourceImpl implements VitalsRemoteDataSource {
  final ApiClient _apiClient;

  VitalsRemoteDataSourceImpl(this._apiClient);

  // ── Appointments ──────────────────────────────────────────────────────────

  @override
  Future<List<Appointment>> getAppointmentsByCondition(String condition) async {
    final response = await _apiClient.get<List<dynamic>>(
      url: ApiEndpoints.appointments,
      query: {'condition': condition},
      options: ApiClient.protected,
    );
    return response
        .map(
          (e) =>
              AppointmentModel.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList(growable: false);
  }

  @override
  Future<({List<Appointment> items, String? nextCursor})> getAppointmentsPaged({
    String? cursor,
    String? query,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      url: ApiEndpoints.appointments,
      query: {
        if (cursor != null) 'cursor': cursor,
        if (query != null && query.isNotEmpty) 'q': query,
      },
      options: ApiClient.protected,
    );
    final page = CursorPage<Appointment>.fromJson(
      response,
      (json) =>
          AppointmentModel.fromJson(json as Map<String, dynamic>).toEntity(),
    );
    return (items: page.results, nextCursor: page.nextCursor);
  }

  @override
  Future<Appointment> createAppointment(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      url: ApiEndpoints.appointments,
      payload: data,
      options: ApiClient.protected,
    );
    return AppointmentModel.fromJson(response).toEntity();
  }

  @override
  Future<Appointment> updateAppointment(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      url: ApiEndpoints.appointmentDetail(id),
      payload: data,
      options: ApiClient.protected,
    );
    return AppointmentModel.fromJson(response).toEntity();
  }

  @override
  Future<void> deleteAppointment(String id) async {
    await _apiClient.delete(
      url: ApiEndpoints.appointmentDetail(id),
      options: ApiClient.protected,
    );
  }

//medication
  @override
  Future<List<Medication>> getMedicationsByCondition(String condition) async {
    final response = await _apiClient.get<List<dynamic>>(
      url: ApiEndpoints.medications,
      query: {'condition': condition},
      options: ApiClient.protected,
    );
    return response
        .map(
          (e) => MedicationModel.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList(growable: false);
  }

  @override
  Future<({List<Medication> items, String? nextCursor})> getMedicationsPaged({
    String? cursor,
    String? query,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      url: ApiEndpoints.medications,
      query: {
        if (cursor != null) 'cursor': cursor,
        if (query != null && query.isNotEmpty) 'q': query,
      },
      options: ApiClient.protected,
    );
    final results = (response['results'] as List<dynamic>? ?? const []);
    final nextUrl = response['next'] as String?;
    final nextCursor = nextUrl == null
        ? null
        : Uri.parse(nextUrl).queryParameters['cursor'];
    return (
      items: results
          .map(
            (e) =>
                MedicationModel.fromJson(e as Map<String, dynamic>).toEntity(),
          )
          .toList(growable: false),
      nextCursor: nextCursor,
    );
  }

  @override
  Future<Medication> createMedication(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      url: ApiEndpoints.medications,
      payload: data,
      options: ApiClient.protected,
    );
    return MedicationModel.fromJson(response).toEntity();
  }

  @override
  Future<Medication> updateMedication(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      url: ApiEndpoints.medicationDetail(id),
      payload: data,
      options: ApiClient.protected,
    );
    return MedicationModel.fromJson(response).toEntity();
  }

  @override
  Future<void> deleteMedication(String id) async {
    await _apiClient.delete(
      url: ApiEndpoints.medicationDetail(id),
      options: ApiClient.protected,
    );
  }

  //Blood pressure

  @override
  Future<List<BpReading>> getBloodPressureReadings() async {
    final response = await _apiClient.get<List<dynamic>>(
      url: ApiEndpoints.bloodPressure,
      options: ApiClient.protected,
    );
    return response
        .map(
          (e) => BpReadingModel.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList(growable: false);
  }

  @override
  Future<BpReading> createBloodPressureReading(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      url: ApiEndpoints.bloodPressure,
      payload: data,
      options: ApiClient.protected,
    );
    return BpReadingModel.fromJson(response).toEntity();
  }

  @override
  Future<void> deleteBloodPressureReading(String id) async {
    await _apiClient.delete(
      url: ApiEndpoints.bloodPressureDetail(id),
      options: ApiClient.protected,
    );
  }

//blood sugar
  @override
  Future<List<BsReading>> getBloodSugarReadings() async {
    final response = await _apiClient.get<List<dynamic>>(
      url: ApiEndpoints.bloodSugar,
      options: ApiClient.protected,
    );
    return response
        .map(
          (e) => BsReadingModel.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList(growable: false);
  }

  @override
  Future<BsReading> createBloodSugarReading(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      url: ApiEndpoints.bloodSugar,
      payload: data,
      options: ApiClient.protected,
    );
    return BsReadingModel.fromJson(response).toEntity();
  }

  @override
  Future<void> deleteBloodSugarReading(String id) async {
    await _apiClient.delete(
      url: ApiEndpoints.bloodSugarDetail(id),
      options: ApiClient.protected,
    );
  }
}
