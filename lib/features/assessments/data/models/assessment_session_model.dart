
import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';

part 'assessment_session_model.g.dart';

@JsonSerializable()
class AssessmentSessionModel {
  final String id;

  @JsonKey(name: 'assessment_slug')
  final String assessmentSlug;

  final String status;

  @JsonKey(name: 'current_index')
  final int currentIndex;

  @JsonKey(name: 'total_questions')
  final int totalQuestions;

  @JsonKey(name: 'completion_pct')
  final int completionPct;

  @JsonKey(name: 'reference_number')
  final String? referenceNumber;

  @JsonKey(name: 'paid_at')
  final String? paidAt;

  @JsonKey(name: 'started_at')
  final String? startedAt;

  @JsonKey(name: 'completed_at')
  final String? completedAt;

  @JsonKey(name: 'navigator_alerted_at')
  final String? navigatorAlertedAt;

  const AssessmentSessionModel({
    required this.id,
    required this.assessmentSlug,
    required this.status,
    required this.currentIndex,
    required this.totalQuestions,
    required this.completionPct,
    this.referenceNumber,
    this.paidAt,
    this.startedAt,
    this.completedAt,
    this.navigatorAlertedAt,
  });

  factory AssessmentSessionModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentSessionModelToJson(this);

  AssessmentSession toEntity() => AssessmentSession(
    id: id,
    assessmentSlug: assessmentSlug,
    status: AssessmentSession.parseStatus(status),
    currentIndex: currentIndex,
    totalQuestions: totalQuestions,
    completionPct: completionPct,
    referenceNumber: referenceNumber,
    paidAt: paidAt,
    startedAt: startedAt,
    completedAt: completedAt,
    navigatorAlertedAt: navigatorAlertedAt,
  );
}
