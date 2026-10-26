import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/home/domain/entities/dashboard_session.dart';
import 'package:my_wellness/features/home/domain/usecases/get_home_dashboard.dart';

part 'home_event.dart';
part 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDashboardUseCase _getHomeDashboard;

  HomeBloc(this._getHomeDashboard) : super(const HomeState()) {
    on<LoadHomeDashboardEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadHomeDashboardEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeDashboardStatus.loading));

    final result = await _getHomeDashboard(NoParams());

    result.fold(
      (failure) {
        if (state.sessions.isNotEmpty) {
          emit(
            state.copyWith(status: HomeDashboardStatus.ready, clearError: true),
          );
          return;
        }
        emit(
          state.copyWith(
            status: HomeDashboardStatus.error,
            errorMessage: mapFailure(failure),
          ),
        );
      },
      (sessions) {
        emit(
          state.copyWith(
            status: HomeDashboardStatus.ready,
            sessions: sessions,
            isFromCache: _getHomeDashboard.lastLoadWasFromCache,
            clearError: true,
          ),
        );
      },
    );
  }
}
