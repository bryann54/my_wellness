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
  error,
}

class AccountState extends Equatable {
  final AccountStatus status;
  final HealthProfile? profile;
  final String? errorMessage;
  final String? successMessage;
  final String currentLang;

  const AccountState({
    this.status = AccountStatus.initial,
    this.profile,
    this.errorMessage,
    this.successMessage,
    this.currentLang = 'en',
  });

  AccountState copyWith({
    AccountStatus? status,
    HealthProfile? profile,
    String? errorMessage,
    String? successMessage,
    String? currentLang,
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
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    errorMessage,
    successMessage,
    currentLang,
  ];
}
