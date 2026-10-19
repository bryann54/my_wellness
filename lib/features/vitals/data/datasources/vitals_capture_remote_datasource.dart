import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/assessments/data/models/referral_model.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';

import 'package:my_wellness/features/vitals/data/models/vitals_capture_content_model.dart';
import 'package:my_wellness/features/vitals/data/models/vitals_capture_result_model.dart';

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

  String _contentUrl(VitalsCaptureKind kind) => switch (kind) {
    VitalsCaptureKind.bp => ApiEndpoints.bpContent,
    VitalsCaptureKind.bs => ApiEndpoints.bsContent,
  };

  String _sessionUrl(VitalsCaptureKind kind) => switch (kind) {
    VitalsCaptureKind.bp => ApiEndpoints.bpSessions,
    VitalsCaptureKind.bs => ApiEndpoints.bsSessions,
  };

  String _referralUrl(VitalsCaptureKind kind, String readingId) =>
      switch (kind) {
        VitalsCaptureKind.bp => ApiEndpoints.referralFromBpReading(readingId),
        VitalsCaptureKind.bs => ApiEndpoints.referralFromBsReading(readingId),
      };
}
