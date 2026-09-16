import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/features/launch/domain/usecases/restore_session_usecase.dart';

sealed class LaunchEvent {
  const LaunchEvent();
}

final class LaunchStarted extends LaunchEvent {
  const LaunchStarted();
}

sealed class LaunchState {
  const LaunchState();
}

final class LaunchLoading extends LaunchState {
  const LaunchLoading();
}

final class LaunchUnauthenticated extends LaunchState {
  const LaunchUnauthenticated();
}

final class LaunchAuthenticated extends LaunchState {
  const LaunchAuthenticated();
}

@injectable
class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  LaunchBloc(this._restoreSession) : super(const LaunchLoading()) {
    on<LaunchStarted>((event, emit) async {
      final hasApprovedSession = await _restoreSession();
      emit(hasApprovedSession
          ? const LaunchAuthenticated()
          : const LaunchUnauthenticated());
    });
  }

  final RestoreSessionUseCase _restoreSession;
}
