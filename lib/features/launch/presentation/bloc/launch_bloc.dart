import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/auth/domain/usecases/auth_usecases.dart';
import 'package:my_wellness/features/launch/domain/usecases/check_connectivity_usecase.dart';

import 'launch_event.dart';
import 'launch_state.dart';

@injectable
class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  final CheckConnectivityUsecase _checkConnectivityUsecase;
  final RestoreSessionUseCase _restoreSessionUseCase;

  LaunchBloc(this._checkConnectivityUsecase, this._restoreSessionUseCase)
    : super(LaunchInitial()) {
    on<StartLaunchEvent>(_onStart);
    on<ContinueOfflineEvent>(_onContinueOffline);
  }

  Future<void> _onStart(
    StartLaunchEvent event,
    Emitter<LaunchState> emit,
  ) async {
    emit(LaunchLoading());

    final connectivity = await _checkConnectivityUsecase.call(NoParams());
    if (connectivity.isLeft()) {
      emit(LaunchOffline());
      return;
    }

    await _resolveAuth(emit);
  }

  Future<void> _onContinueOffline(
    ContinueOfflineEvent event,
    Emitter<LaunchState> emit,
  ) async {
    emit(LaunchLoading());
    await _resolveAuth(emit);
  }

  Future<void> _resolveAuth(Emitter<LaunchState> emit) async {
    final result = await _restoreSessionUseCase.call();
    result.fold(
      (failure) => failure is UnauthorizedFailure
          ? emit(LaunchUnauthenticated())
          : emit(LaunchError('Unable to restore your session.')),
      (_) => emit(LaunchAuthenticated()),
    );
  }
}
