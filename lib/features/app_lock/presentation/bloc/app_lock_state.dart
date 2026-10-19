part of 'app_lock_bloc.dart';

enum AppLockPhase { initial, inactive, authenticating, unlocked, locked }

enum AppLockIssue { lockedOut, failed }

enum AppLockSignIn { idle, setupRequired, ready }

class AppLockState extends Equatable {
  final AppLockPhase phase;
  final AppLockIssue? issue;
  final DeviceSecurity security;
  final AppLockSignIn signIn;
  final UnlockOutcome? toggleOutcome;

  const AppLockState({
    this.phase = AppLockPhase.initial,
    this.issue,
    this.security = DeviceSecurity.unsecured,
    this.signIn = AppLockSignIn.idle,
    this.toggleOutcome,
  });

  bool get isLocked =>
      phase == AppLockPhase.locked || phase == AppLockPhase.authenticating;

  AppLockState copyWith({
    AppLockPhase? phase,
    AppLockIssue? issue,
    DeviceSecurity? security,
    AppLockSignIn? signIn,
    UnlockOutcome? toggleOutcome,
    bool clearIssue = false,
    bool clearToggleOutcome = false,
  }) {
    return AppLockState(
      phase: phase ?? this.phase,
      issue: clearIssue ? null : issue ?? this.issue,
      security: security ?? this.security,
      signIn: signIn ?? this.signIn,
      toggleOutcome: clearToggleOutcome
          ? null
          : toggleOutcome ?? this.toggleOutcome,
    );
  }

  @override
  List<Object?> get props => [phase, issue, security, signIn, toggleOutcome];
}
