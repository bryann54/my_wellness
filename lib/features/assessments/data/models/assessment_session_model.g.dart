// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentSessionModel _$AssessmentSessionModelFromJson(
  Map<String, dynamic> json,
) => AssessmentSessionModel(
  id: json['id'] as String,
  assessmentSlug: json['assessment_slug'] as String,
  status: json['status'] as String,
  currentIndex: (json['current_index'] as num).toInt(),
  totalQuestions: (json['total_questions'] as num).toInt(),
  completionPct: (json['completion_pct'] as num).toInt(),
  referenceNumber: json['reference_number'] as String?,
  paidAt: json['paid_at'] as String?,
  startedAt: json['started_at'] as String?,
  completedAt: json['completed_at'] as String?,
  navigatorAlertedAt: json['navigator_alerted_at'] as String?,
);

Map<String, dynamic> _$AssessmentSessionModelToJson(
  AssessmentSessionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'assessment_slug': instance.assessmentSlug,
  'status': instance.status,
  'current_index': instance.currentIndex,
  'total_questions': instance.totalQuestions,
  'completion_pct': instance.completionPct,
  'reference_number': instance.referenceNumber,
  'paid_at': instance.paidAt,
  'started_at': instance.startedAt,
  'completed_at': instance.completedAt,
  'navigator_alerted_at': instance.navigatorAlertedAt,
};
