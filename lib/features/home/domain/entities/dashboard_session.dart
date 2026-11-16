import 'package:equatable/equatable.dart';

enum DashboardSessionStatus { notStarted, pending, inProgress, completed }

/// Minimal dashboard projection of a health-check card. Sensitive result,
/// score, and follow-up fields are intentionally omitted.
class DashboardSession extends Equatable {
  const DashboardSession({
    required this.id,
    this.sessionId,
    required this.assessmentSlug,
    required this.title,
    required this.family,
    required this.currentIndex,
    required this.totalQuestions,
    required this.completionPercent,
    required this.status,
  });

  final String id;
  final String? sessionId;
  final String assessmentSlug;
  final String title;
  final String family;
  final int currentIndex;
  final int totalQuestions;
  final int completionPercent;
  final DashboardSessionStatus status;

  bool get isWorkplaceWellbeing {
    final searchable = '$assessmentSlug $title $family'.toLowerCase();
    return searchable.contains('corporate-wellbeing') ||
        searchable.contains('workplace wellbeing') ||
        searchable.contains('workplace-wellbeing');
  }

  @override
  List<Object?> get props => [
    id,
    sessionId,
    assessmentSlug,
    title,
    family,
    currentIndex,
    totalQuestions,
    completionPercent,
    status,
  ];
}
