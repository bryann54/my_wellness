import 'package:equatable/equatable.dart';

enum DashboardSessionStatus { pending, inProgress }

/// Minimal dashboard projection of a screening session. Sensitive score and
/// identity fields from the web dashboard response are intentionally omitted.
class DashboardSession extends Equatable {
  const DashboardSession({
    required this.id,
    required this.assessmentSlug,
    required this.currentIndex,
    required this.totalQuestions,
    required this.completionPercent,
    required this.status,
  });

  final String id;
  final String assessmentSlug;
  final int currentIndex;
  final int totalQuestions;
  final int completionPercent;
  final DashboardSessionStatus status;

  @override
  List<Object?> get props => [
    id,
    assessmentSlug,
    currentIndex,
    totalQuestions,
    completionPercent,
    status,
  ];
}
