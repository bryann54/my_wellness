part of 'assessments_bloc.dart';

enum AssessmentStatus { initial, loading, ready, submitting, completed, error }

enum ToastType { success, error, warning, info }

enum AssessmentBlockKind {
  none,
  ageIneligible,
  genderIneligible,
  cancerDiagnosedBlocked,
  dependantConsentRequired,
  assessmentInProgress,
}

class AssessmentsState extends Equatable {
  final AssessmentStatus status;
  final VitalsAccess? access;

  final List<AssessmentSummary> assessments;
  final List<AssessmentSummary> filteredAssessments;
  final String searchQuery;

  final AssessmentDefinition? definition;
  final AssessmentSession? session;
  final List<AssessmentAnswer> answers;
  final AssessmentScore? score;
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
  final Referral? referral;

  final AssessmentBlockKind block;
  final String? blockingSlug;
  final String? blockingTitle;
  final String? dependantVariantSlug;

  final CanStartResult? canStart;

  const AssessmentsState({
    this.status = AssessmentStatus.initial,
    this.access,
    this.assessments = const [],
    this.filteredAssessments = const [],
    this.searchQuery = '',
    this.definition,
    this.session,
    this.answers = const [],
    this.score,
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
    this.referral,
    this.block = AssessmentBlockKind.none,
    this.blockingSlug,
    this.blockingTitle,
    this.dependantVariantSlug,
    this.canStart,
  });

  AssessmentsState copyWith({
    AssessmentStatus? status,
    VitalsAccess? access,
    List<AssessmentSummary>? assessments,
    List<AssessmentSummary>? filteredAssessments,
    String? searchQuery,
    AssessmentDefinition? definition,
    AssessmentSession? session,
    List<AssessmentAnswer>? answers,
    AssessmentScore? score,
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
    Referral? referral,
    bool clearReferral = false,
    AssessmentBlockKind? block,
    bool clearBlock = false,
    String? blockingSlug,
    String? blockingTitle,
    String? dependantVariantSlug,
    CanStartResult? canStart,
    bool clearCanStart = false,
  }) {
    return AssessmentsState(
      status: status ?? this.status,
      access: access ?? this.access,
      assessments: assessments ?? this.assessments,
      filteredAssessments: filteredAssessments ?? this.filteredAssessments,
      searchQuery: searchQuery ?? this.searchQuery,
      definition: definition ?? this.definition,
      session: clearSession ? null : (session ?? this.session),
      answers: answers ?? this.answers,
      score: score ?? this.score,
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
      referral: clearReferral ? null : (referral ?? this.referral),
      block: clearBlock ? AssessmentBlockKind.none : (block ?? this.block),
      blockingSlug: clearBlock ? null : (blockingSlug ?? this.blockingSlug),
      blockingTitle: clearBlock ? null : (blockingTitle ?? this.blockingTitle),
      dependantVariantSlug: clearBlock
          ? null
          : (dependantVariantSlug ?? this.dependantVariantSlug),
      canStart: clearCanStart ? null : (canStart ?? this.canStart),
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
    answers,
    score,
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
    referral,
    block,
    blockingSlug,
    blockingTitle,
    dependantVariantSlug,
    canStart,
  ];
}
