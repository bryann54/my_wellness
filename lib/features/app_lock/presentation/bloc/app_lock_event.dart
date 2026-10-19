part of 'app_lock_bloc.dart';

abstract class AppLockEvent extends Equatable {
  const AppLockEvent();

  @override
  List<Object?> get props => [];
}

class AppLockEvaluated extends AppLockEvent {
  final String reason;
  const AppLockEvaluated({required this.reason});

  @override
  List<Object?> get props => [reason];
}

class AppLockSignedIn extends AppLockEvent {
  const AppLockSignedIn();
}

class AppLockSetupDismissed extends AppLockEvent {
  const AppLockSetupDismissed();
}

class AppLockUnlockRequested extends AppLockEvent {
  final String reason;
  const AppLockUnlockRequested({required this.reason});

  @override
  List<Object?> get props => [reason];
}

class AppLockToggleRequested extends AppLockEvent {
  final bool enabled;
  final String reason;
  const AppLockToggleRequested({required this.enabled, required this.reason});

  @override
  List<Object?> get props => [enabled, reason];
}

class AppLockBackgrounded extends AppLockEvent {
  const AppLockBackgrounded();
}

class AppLockResumed extends AppLockEvent {
  final String reason;
  const AppLockResumed({required this.reason});

  @override
  List<Object?> get props => [reason];
}

class AppLockReset extends AppLockEvent {
  const AppLockReset();
}
