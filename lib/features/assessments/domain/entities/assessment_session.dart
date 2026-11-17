import 'package:equatable/equatable.dart';
import 'package:my_wellness/features/assessments/domain/repositories/assessments_repository.dart';

enum AssessmentSessionStatus {
  needsPreScreening,
  awaitingPayment,
  awaitingCall,
  inProgress,
  completed,
  terminated,
  unknown,
}

class AssessmentSession extends Equatable {
  final String id;
  final String assessmentSlug;
  final AssessmentSessionStatus status;
  final int currentIndex;
  final int totalQuestions;
  final int completionPct;
  final String? referenceNumber;
  final String? paidAt;
  final String? startedAt;
  final String? completedAt;
  final String? navigatorAlertedAt;

  const AssessmentSession({
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

  static AssessmentSessionStatus parseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'needs_pre_screening':
        return AssessmentSessionStatus.needsPreScreening;
      case 'awaiting_payment':
        return AssessmentSessionStatus.awaitingPayment;
      case 'awaiting_call':
        return AssessmentSessionStatus.awaitingCall;
      case 'in_progress':
        return AssessmentSessionStatus.inProgress;
      case 'completed':
        return AssessmentSessionStatus.completed;
      case 'terminated':
        return AssessmentSessionStatus.terminated;
      default:
        return AssessmentSessionStatus.unknown;
    }
  }

  bool get isCompleted => status == AssessmentSessionStatus.completed;
  bool get isInProgress => status == AssessmentSessionStatus.inProgress;
  bool get isLocked =>
      status == AssessmentSessionStatus.awaitingPayment ||
      status == AssessmentSessionStatus.awaitingCall;

  AssessmentSession applyResult(SubmitAnswerResult r) {
    final nextIndex = r.nextIndex;
    return AssessmentSession(
      id: id,
      assessmentSlug: assessmentSlug,
      status: r.completed
          ? AssessmentSessionStatus.completed
          : (r.terminate
                ? AssessmentSessionStatus.terminated
                : AssessmentSessionStatus.inProgress),
      currentIndex: nextIndex,
      totalQuestions: totalQuestions,
      completionPct: totalQuestions == 0
          ? 0
          : ((nextIndex / totalQuestions) * 100).round().clamp(0, 100),
      referenceNumber: r.reference ?? referenceNumber,
      paidAt: paidAt,
      startedAt: startedAt,
      completedAt: r.completed ? DateTime.now().toIso8601String() : completedAt,
      navigatorAlertedAt: navigatorAlertedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    assessmentSlug,
    status,
    currentIndex,
    totalQuestions,
    completionPct,
    referenceNumber,
    paidAt,
    startedAt,
    completedAt,
    navigatorAlertedAt,
  ];
}
