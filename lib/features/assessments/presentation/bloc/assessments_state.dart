part of 'assessments_bloc.dart';

enum AssessmentStatus { initial, loading, ready, submitting, completed, error }

enum ToastType { success, error, warning, info }

class AssessmentsState extends Equatable {
  final AssessmentStatus status;
  final VitalsAccess? access;
  final List<AssessmentSummary> assessments;
  final AssessmentDefinition? definition;
  final AssessmentSession? session;
  final List<AssessmentAnswer> answers;
  final AssessmentScore? score;
  final BmiPreview? bmiPreview;
  final bool terminated;
  final String? terminationReference;
  final String? errorMessage;
  final ToastType? toastType;
  final String? toastMessage;
  final int toastNonce;
  final bool alreadyCompleted;
  final bool completionHandled;
  final Referral? referral;

  const AssessmentsState({
    this.status = AssessmentStatus.initial,
    this.access,
    this.assessments = const [],
    this.definition,
    this.session,
    this.answers = const [],
    this.score,
    this.bmiPreview,
    this.terminated = false,
    this.terminationReference,
    this.errorMessage,
    this.toastType,
    this.toastMessage,
    this.toastNonce = 0,
    this.alreadyCompleted = false,
    this.completionHandled = false,
    this.referral,
  });

  AssessmentsState copyWith({
    AssessmentStatus? status,
    VitalsAccess? access,
    List<AssessmentSummary>? assessments,
    AssessmentDefinition? definition,
    AssessmentSession? session,
    List<AssessmentAnswer>? answers,
    AssessmentScore? score,
    BmiPreview? bmiPreview,
    bool? terminated,
    String? terminationReference,
    String? errorMessage,
    ToastType? toastType,
    String? toastMessage,
    int? toastNonce,
    bool clearError = false,
    bool clearToast = false,
    bool clearBmiPreview = false,
    bool clearSession = false,
    bool? alreadyCompleted,
    bool? completionHandled,
    Referral? referral,
    bool clearReferral = false,
  }) {
    return AssessmentsState(
      status: status ?? this.status,
      access: access ?? this.access,
      assessments: assessments ?? this.assessments,
      definition: definition ?? this.definition,
      session: clearSession ? null : (session ?? this.session),
      answers: answers ?? this.answers,
      score: score ?? this.score,
      bmiPreview: clearBmiPreview ? null : (bmiPreview ?? this.bmiPreview),
      terminated: terminated ?? this.terminated,
      terminationReference: terminationReference ?? this.terminationReference,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      toastType: clearToast ? null : (toastType ?? this.toastType),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      toastNonce: clearToast ? 0 : (toastNonce ?? this.toastNonce),
      alreadyCompleted: alreadyCompleted ?? this.alreadyCompleted,
      completionHandled: completionHandled ?? this.completionHandled,
      referral: clearReferral ? null : (referral ?? this.referral),
    );
  }

  @override
  List<Object?> get props => [
    status,
    access,
    assessments,
    definition,
    session,
    answers,
    score,
    bmiPreview,
    terminated,
    terminationReference,
    errorMessage,
    toastType,
    toastMessage,
    toastNonce,
    alreadyCompleted,
    completionHandled,
    referral,
  ];
}
