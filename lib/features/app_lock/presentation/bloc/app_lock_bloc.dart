import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/features/app_lock/domain/entities/app_lock_status.dart';
import 'package:my_wellness/features/app_lock/domain/usecases/app_lock_usecases.dart';

part 'app_lock_event.dart';
part 'app_lock_state.dart';

@injectable
class AppLockBloc extends Bloc<AppLockEvent, AppLockState> {
  final GetAppLockStatusUseCase _getStatus;
  final AuthenticateAppLockUseCase _authenticate;
  final SetAppLockEnabledUseCase _setEnabled;
  final MarkAppLockPromptedUseCase _markPrompted;
  final ClearAppLockUseCase _clear;

  static const _relockAfter = Duration(minutes: 1);
  DateTime? _backgroundedAt;

  AppLockBloc({
    required GetAppLockStatusUseCase getStatus,
    required AuthenticateAppLockUseCase authenticate,
    required SetAppLockEnabledUseCase setEnabled,
    required MarkAppLockPromptedUseCase markPrompted,
    required ClearAppLockUseCase clear,
  }) : _getStatus = getStatus,
       _authenticate = authenticate,
       _setEnabled = setEnabled,
       _markPrompted = markPrompted,
       _clear = clear,
       super(const AppLockState()) {
    on<AppLockEvaluated>(_onEvaluated);
    on<AppLockSignedIn>(_onSignedIn);
    on<AppLockSetupDismissed>(_onSetupDismissed);
    on<AppLockUnlockRequested>(_onUnlockRequested);
    on<AppLockToggleRequested>(_onToggleRequested);
    on<AppLockBackgrounded>(_onBackgrounded);
    on<AppLockResumed>(_onResumed);
    on<AppLockReset>(_onReset);
  }

  Future<void> _onEvaluated(
    AppLockEvaluated event,
    Emitter<AppLockState> emit,
  ) async {
    final status = await _loadStatus();
    if (status == null) {
      emit(
        state.copyWith(phase: AppLockPhase.locked, issue: AppLockIssue.failed),
      );
      return;
    }
    if (!status.shouldLock) {
      emit(state.copyWith(phase: AppLockPhase.inactive, clearIssue: true));
      return;
    }
    await _unlock(event.reason, emit);
  }

  Future<void> _onSignedIn(
    AppLockSignedIn event,
    Emitter<AppLockState> emit,
  ) async {
    final status = await _loadStatus();
    emit(
      state.copyWith(
        phase: status?.shouldLock == true
            ? AppLockPhase.unlocked
            : AppLockPhase.inactive,
        security: status?.security ?? DeviceSecurity.unsecured,
        signIn: status != null && !status.prompted
            ? AppLockSignIn.setupRequired
            : AppLockSignIn.ready,
        clearIssue: true,
      ),
    );
  }

  Future<void> _onSetupDismissed(
    AppLockSetupDismissed event,
    Emitter<AppLockState> emit,
  ) async {
    await _markPrompted();
    emit(state.copyWith(signIn: AppLockSignIn.ready));
  }

  Future<void> _onUnlockRequested(
    AppLockUnlockRequested event,
    Emitter<AppLockState> emit,
  ) async {
    if (state.phase == AppLockPhase.authenticating) return;
    await _unlock(event.reason, emit);
  }

  Future<void> _onToggleRequested(
    AppLockToggleRequested event,
    Emitter<AppLockState> emit,
  ) async {
    emit(state.copyWith(clearToggleOutcome: true));

    final auth = await _authenticate(reason: event.reason);
    final outcome = auth.getOrElse(() => UnlockOutcome.failed);
    if (outcome != UnlockOutcome.success) {
      emit(state.copyWith(toggleOutcome: outcome));
      return;
    }

    final saved = await _setEnabled(event.enabled);
    if (saved.isLeft()) {
      emit(state.copyWith(toggleOutcome: UnlockOutcome.failed));
      return;
    }

    emit(
      state.copyWith(
        phase: event.enabled ? AppLockPhase.unlocked : AppLockPhase.inactive,
        toggleOutcome: UnlockOutcome.success,
      ),
    );
  }

  void _onBackgrounded(AppLockBackgrounded event, Emitter<AppLockState> emit) {
    if (state.phase == AppLockPhase.unlocked) _backgroundedAt = DateTime.now();
  }

  Future<void> _onResumed(
    AppLockResumed event,
    Emitter<AppLockState> emit,
  ) async {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since == null || state.phase != AppLockPhase.unlocked) return;
    if (DateTime.now().difference(since) >= _relockAfter) {
      await _unlock(event.reason, emit);
    }
  }

  Future<void> _onReset(AppLockReset event, Emitter<AppLockState> emit) async {
    _backgroundedAt = null;
    await _clear();
    emit(const AppLockState());
  }

  Future<AppLockStatus?> _loadStatus() async =>
      (await _getStatus()).fold((_) => null, (status) => status);

  Future<void> _unlock(String reason, Emitter<AppLockState> emit) async {
    emit(state.copyWith(phase: AppLockPhase.authenticating, clearIssue: true));
    final result = await _authenticate(reason: reason);
    emit(
      result.fold<AppLockState>(
        (_) => state.copyWith(
          phase: AppLockPhase.locked,
          issue: AppLockIssue.failed,
        ),
        _resolve,
      ),
    );
  }

  AppLockState _resolve(UnlockOutcome outcome) => switch (outcome) {
    UnlockOutcome.success => state.copyWith(
      phase: AppLockPhase.unlocked,
      clearIssue: true,
    ),
    UnlockOutcome.cancelled => state.copyWith(
      phase: AppLockPhase.locked,
      clearIssue: true,
    ),
    UnlockOutcome.lockedOut => state.copyWith(
      phase: AppLockPhase.locked,
      issue: AppLockIssue.lockedOut,
    ),
    UnlockOutcome.unavailable => state.copyWith(
      phase: AppLockPhase.inactive,
      clearIssue: true,
    ),
    UnlockOutcome.failed => state.copyWith(
      phase: AppLockPhase.locked,
      issue: AppLockIssue.failed,
    ),
  };
}
