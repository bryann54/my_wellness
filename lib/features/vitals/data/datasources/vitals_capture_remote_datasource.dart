import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/assessments/data/models/referral_model.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';

import 'package:my_wellness/features/vitals/data/models/vitals_access_model.dart';
import 'package:my_wellness/features/vitals/data/models/vitals_capture_content_model.dart';
import 'package:my_wellness/features/vitals/data/models/vitals_capture_result_model.dart';

import 'package:my_wellness/features/vitals/domain/entities/vitals_access.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_capture_content.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_capture_result.dart';

enum VitalsCaptureKind { bp, bs }

abstract class VitalsCaptureRemoteDataSource {
  Future<VitalsCaptureContent> getContent(VitalsCaptureKind kind);

  Future<VitalsCaptureResult> createSession(
    VitalsCaptureKind kind,
    Map<String, dynamic> payload,
  );

  Future<Referral?> getReferralFromReading(
    VitalsCaptureKind kind,
    String readingId,
  );

  // Access gate
  Future<VitalsAccess> getAccess();
  Future<VitalsAccess> alertNavigator();

  // Live classify preview — returns the `classification` string.
  Future<String> classifyPreview(Map<String, dynamic> payload);

  // Monitoring profile
  Future<Map<String, dynamic>> getMonitoringProfile(VitalsCaptureKind kind);
  Future<Map<String, dynamic>> setMonitoringProfile(
    VitalsCaptureKind kind,
    Map<String, dynamic> payload,
  );

  // Session sub-steps
  Future<VitalsCaptureResult> addSecondReading(
    String sessionId,
    Map<String, dynamic> payload,
  );
  Future<VitalsCaptureResult> addWellbeing(String sessionId, bool answer);

  // Referral facility candidates + booking
  Future<
    ({
      List<Map<String, dynamic>> candidates,
      List<String> requiredServices,
      String? reason,
    })
  >
  facilityCandidates(
    VitalsCaptureKind kind,
    String readingId, {
    double? userLat,
    double? userLng,
  });

  Future<Referral> createReferralFromReading(
    VitalsCaptureKind kind,
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  });

  // Report
  Future<({List<int> bytes, Map<String, List<String>> headers})> downloadReport(
    String reportType,
  );
  Future<String?> reportEmailPrefill();
  Future<void> emailReport(String email, String reportType);
}

@LazySingleton(as: VitalsCaptureRemoteDataSource)
class VitalsCaptureRemoteDataSourceImpl
    implements VitalsCaptureRemoteDataSource {
  final ApiClient _api;
  VitalsCaptureRemoteDataSourceImpl(this._api);

  @override
  Future<VitalsCaptureContent> getContent(VitalsCaptureKind kind) async {
    final res = await _api.get<Map<String, dynamic>>(
      url: _contentUrl(kind),
      options: ApiClient.protected,
    );
    return VitalsCaptureContentModel.fromJson(res).toEntity();
  }

  @override
  Future<VitalsCaptureResult> createSession(
    VitalsCaptureKind kind,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.post<Map<String, dynamic>>(
      url: _sessionUrl(kind),
      payload: payload,
      options: ApiClient.protected,
    );
    return VitalsCaptureResultModel.fromJson(res).toEntity();
  }

  @override
  Future<Referral?> getReferralFromReading(
    VitalsCaptureKind kind,
    String readingId,
  ) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        url: _referralUrl(kind, readingId),
        payload: const <String, dynamic>{},
        options: ApiClient.protected.copyWith(
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 90),
        ),
      );
      return ReferralModel.fromJson(res).toEntity();
    } on Exception {
      return null;
    }
  }

  @override
  Future<VitalsAccess> getAccess() async {
    final res = await _api.get<Map<String, dynamic>>(
      url: ApiEndpoints.vitalsAccess,
      options: ApiClient.protected,
    );
    return VitalsAccessModel.fromJson(res).toEntity();
  }

  @override
  Future<VitalsAccess> alertNavigator() async {
    final res = await _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.vitalsAlertNavigator,
      payload: const <String, dynamic>{},
      options: ApiClient.protected,
    );
    return VitalsAccessModel.fromJson(res).toEntity();
  }

  @override
  Future<String> classifyPreview(Map<String, dynamic> payload) async {
    final res = await _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.vitalsClassifyPreview,
      payload: payload,
      options: ApiClient.protected,
    );
    // BMI preview returns a map; BP/BS/pulse return `classification`.
    return res['classification'] as String? ??
        res['bmi_classification'] as String? ??
        'neutral';
  }

  @override
  Future<Map<String, dynamic>> getMonitoringProfile(
    VitalsCaptureKind kind,
  ) async {
    final res = await _api.get<Map<String, dynamic>>(
      url: _monitoringProfileUrl(kind),
      options: ApiClient.protected,
    );
    return res;
  }

  @override
  Future<Map<String, dynamic>> setMonitoringProfile(
    VitalsCaptureKind kind,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.put<Map<String, dynamic>>(
      url: _monitoringProfileUrl(kind),
      payload: payload,
      options: ApiClient.protected,
    );
    return res;
  }

  @override
  Future<VitalsCaptureResult> addSecondReading(
    String sessionId,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.bpSessionSecondReading(sessionId),
      payload: payload,
      options: ApiClient.protected,
    );
    return VitalsCaptureResultModel.fromJson(res).toEntity();
  }

  @override
  Future<VitalsCaptureResult> addWellbeing(
    String sessionId,
    bool answer,
  ) async {
    final res = await _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.bpSessionWellbeing(sessionId),
      payload: {'answer': answer},
      options: ApiClient.protected,
    );
    return VitalsCaptureResultModel.fromJson(res).toEntity();
  }

  @override
  Future<
    ({
      List<Map<String, dynamic>> candidates,
      List<String> requiredServices,
      String? reason,
    })
  >
  facilityCandidates(
    VitalsCaptureKind kind,
    String readingId, {
    double? userLat,
    double? userLng,
  }) async {
    final res = await _api.get<Map<String, dynamic>>(
      url: kind == VitalsCaptureKind.bp
          ? ApiEndpoints.referralFacilityCandidatesFromBpReading(readingId)
          : ApiEndpoints.referralFacilityCandidatesFromBsReading(readingId),
      query: {'user_lat': ?userLat, 'user_lng': ?userLng},
      options: ApiClient.protected,
    );
    return (
      candidates: ((res['candidates'] as List<dynamic>?) ?? const [])
          .map((e) => e as Map<String, dynamic>)
          .toList(growable: false),
      requiredServices:
          ((res['required_services'] as List<dynamic>?) ?? const [])
              .map((e) => e.toString())
              .toList(growable: false),
      reason: res['reason'] as String?,
    );
  }

  @override
  Future<Referral> createReferralFromReading(
    VitalsCaptureKind kind,
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      url: _referralUrl(kind, readingId),
      payload: {
        'user_lat': ?userLat,
        'user_lng': ?userLng,
        'facility_id': ?facilityId,
      },
      options: ApiClient.protected.copyWith(
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 90),
      ),
    );
    return ReferralModel.fromJson(res).toEntity();
  }

  @override
  Future<({List<int> bytes, Map<String, List<String>> headers})> downloadReport(
    String reportType,
  ) async {
    final res = await _api.postBytes(
      url: ApiEndpoints.vitalsReport,
      payload: {'report_type': reportType},
      options: ApiClient.protected,
    );
    return (bytes: res.bytes, headers: res.headers);
  }

  @override
  Future<String?> reportEmailPrefill() async {
    final res = await _api.get<Map<String, dynamic>>(
      url: ApiEndpoints.vitalsReportEmailPrefill,
      options: ApiClient.protected,
    );
    return res['email'] as String?;
  }

  @override
  Future<void> emailReport(String email, String reportType) async {
    await _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.vitalsReportEmail,
      payload: {'email': email, 'report_type': reportType},
      options: ApiClient.protected,
    );
  }

  String _contentUrl(VitalsCaptureKind kind) => switch (kind) {
    VitalsCaptureKind.bp => ApiEndpoints.bpContent,
    VitalsCaptureKind.bs => ApiEndpoints.bsContent,
  };

  String _sessionUrl(VitalsCaptureKind kind) => switch (kind) {
    VitalsCaptureKind.bp => ApiEndpoints.bpSessions,
    VitalsCaptureKind.bs => ApiEndpoints.bloodSugar,
  };

  String _referralUrl(VitalsCaptureKind kind, String readingId) =>
      switch (kind) {
        VitalsCaptureKind.bp => ApiEndpoints.referralFromBpReading(readingId),
        VitalsCaptureKind.bs => ApiEndpoints.referralFromBsReading(readingId),
      };

  String _monitoringProfileUrl(VitalsCaptureKind kind) => switch (kind) {
    VitalsCaptureKind.bp => ApiEndpoints.bpMonitoringProfile,
    VitalsCaptureKind.bs => ApiEndpoints.bloodSugarMonitoringProfile,
  };
}
