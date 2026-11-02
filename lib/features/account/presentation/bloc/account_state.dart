part of 'account_bloc.dart';

enum AccountStatus {
  initial,
  loading,
  loaded,
  updating,
  updated,
  deleting,
  deleted,
  cancelling,
  exporting,
  declaringCancerDiagnosis,
  error,
}

class AccountState extends Equatable {
  final AccountStatus status;
  final HealthProfile? profile;
  final String? errorMessage;
  final String? successMessage;
  final String currentLang;

  /// True once the current session has declared a cancer diagnosis
  /// (either loaded from the profile or set on this state after a
  /// successful `DeclareCancerDiagnosisEvent`). `_ReviewView` in the
  /// pricing feature reads this so the cancer question is not asked
  /// twice for the same user.
  final bool cancerDiagnosisDeclared;

  const AccountState({
    this.status = AccountStatus.initial,
    this.profile,
    this.errorMessage,
    this.successMessage,
    this.currentLang = 'en',
    this.cancerDiagnosisDeclared = false,
  });

  AccountState copyWith({
    AccountStatus? status,
    HealthProfile? profile,
    String? errorMessage,
    String? successMessage,
    String? currentLang,
    bool? cancerDiagnosisDeclared,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AccountState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      currentLang: currentLang ?? this.currentLang,
      cancerDiagnosisDeclared:
          cancerDiagnosisDeclared ??
          (profile?.cancerDiagnosedDeclaredAt != null ||
              this.cancerDiagnosisDeclared),
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    errorMessage,
    successMessage,
    currentLang,
    cancerDiagnosisDeclared,
  ];
}
