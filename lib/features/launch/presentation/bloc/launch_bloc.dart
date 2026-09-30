import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/features/auth/domain/usecases/auth_usecases.dart';
import 'package:my_wellness/features/launch/domain/usecases/check_connectivity_usecase.dart';

import 'launch_event.dart';
import 'launch_state.dart';

@injectable
class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  final CheckConnectivityUsecase _checkConnectivityUsecase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  LaunchBloc(this._checkConnectivityUsecase, this._getCurrentUserUseCase)
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
    final result = await _getCurrentUserUseCase.call();
    result.fold((failure) => emit(LaunchError(failure.toString())), (user) {
      if (user == null) {
        emit(LaunchUnauthenticated());
      } else {
        emit(LaunchAuthenticated(user));
      }
    });
  }
}
