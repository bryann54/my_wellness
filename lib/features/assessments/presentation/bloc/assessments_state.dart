part of 'assessments_bloc.dart';

enum AssessmentStatus { initial, loading, ready, submitting, completed, error }

enum ToastType { success, error, warning, info }

class AssessmentsState extends Equatable {
  final AssessmentStatus status;
  final VitalsAccess? access;
  final List<AssessmentSummary> assessments;
  final List<AssessmentSummary> filteredAssessments;
  final String searchQuery;

  final AssessmentDefinition? definition;
  final AssessmentSession? session;
  final CanStartResult? canStart;
  final List<AssessmentAnswer> answers;
  final AssessmentScore? score;
  final Referral? referral;
  final BmiPreview? bmiPreview;
  final bool bmiPreviewLoading;
  final String? bmiPreviewInputKey;

  final bool terminated;
  final String? terminationReference;
  final String? errorMessage;

  final ToastType? toastType;
  final String? toastMessage;
  final int toastNonce;

  final bool alreadyCompleted;
  final bool completionHandled;
  final bool reportDownloading;
  final bool reportEmailing;

  const AssessmentsState({
    this.status = AssessmentStatus.initial,
    this.access,
    this.assessments = const [],
    this.filteredAssessments = const [],
    this.searchQuery = '',
    this.definition,
    this.session,
    this.canStart,
    this.answers = const [],
    this.score,
    this.referral,
    this.bmiPreview,
    this.bmiPreviewLoading = false,
    this.bmiPreviewInputKey,
    this.terminated = false,
    this.terminationReference,
    this.errorMessage,
    this.toastType,
    this.toastMessage,
    this.toastNonce = 0,
    this.alreadyCompleted = false,
    this.completionHandled = false,
    this.reportDownloading = false,
    this.reportEmailing = false,
  });

  AssessmentQuestion? get currentQuestion =>
      definition?.questionByIndex(session?.currentIndex ?? -1);

  bool get shouldSkipIntro =>
      session?.status == AssessmentSessionStatus.completed;

  AssessmentsState copyWith({
    AssessmentStatus? status,
    VitalsAccess? access,
    List<AssessmentSummary>? assessments,
    List<AssessmentSummary>? filteredAssessments,
    String? searchQuery,
    AssessmentDefinition? definition,
    AssessmentSession? session,
    CanStartResult? canStart,
    List<AssessmentAnswer>? answers,
    AssessmentScore? score,
    Referral? referral,
    BmiPreview? bmiPreview,
    bool? bmiPreviewLoading,
    String? bmiPreviewInputKey,
    bool? terminated,
    String? terminationReference,
    String? errorMessage,
    ToastType? toastType,
    String? toastMessage,
    int? toastNonce,
    bool clearError = false,
    bool clearToast = false,
    bool clearBmiPreview = false,
    bool clearBmiPreviewInputKey = false,
    bool clearSession = false,
    bool? alreadyCompleted,
    bool? completionHandled,
    bool? reportDownloading,
    bool? reportEmailing,
    Referral? referralClear,
    bool clearReferral = false,
  }) {
    return AssessmentsState(
      status: status ?? this.status,
      access: access ?? this.access,
      assessments: assessments ?? this.assessments,
      filteredAssessments: filteredAssessments ?? this.filteredAssessments,
      searchQuery: searchQuery ?? this.searchQuery,
      definition: definition ?? this.definition,
      session: clearSession ? null : (session ?? this.session),
      canStart: canStart ?? this.canStart,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      referral: clearReferral ? null : (referral ?? this.referral),
      bmiPreview: clearBmiPreview ? null : (bmiPreview ?? this.bmiPreview),
      bmiPreviewLoading: bmiPreviewLoading ?? this.bmiPreviewLoading,
      bmiPreviewInputKey: clearBmiPreviewInputKey
          ? null
          : (bmiPreviewInputKey ?? this.bmiPreviewInputKey),
      terminated: terminated ?? this.terminated,
      terminationReference: terminationReference ?? this.terminationReference,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      toastType: clearToast ? null : (toastType ?? this.toastType),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      toastNonce: clearToast ? 0 : (toastNonce ?? this.toastNonce),
      alreadyCompleted: alreadyCompleted ?? this.alreadyCompleted,
      completionHandled: completionHandled ?? this.completionHandled,
      reportDownloading: reportDownloading ?? this.reportDownloading,
      reportEmailing: reportEmailing ?? this.reportEmailing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    access,
    assessments,
    filteredAssessments,
    searchQuery,
    definition,
    session,
    canStart,
    answers,
    score,
    referral,
    bmiPreview,
    bmiPreviewLoading,
    bmiPreviewInputKey,
    terminated,
    terminationReference,
    errorMessage,
    toastType,
    toastMessage,
    toastNonce,
    alreadyCompleted,
    completionHandled,
    reportDownloading,
    reportEmailing,
  ];
}
