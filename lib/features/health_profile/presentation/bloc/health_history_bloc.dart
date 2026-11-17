import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/health_profile/domain/entities/health_history.dart';
import 'package:my_wellness/features/health_profile/domain/usecases/get_health_history.dart';

part 'health_history_event.dart';
part 'health_history_state.dart';

@lazySingleton
class HealthHistoryBloc extends Bloc<HealthHistoryEvent, HealthHistoryState> {
  HealthHistoryBloc(this._getHistory) : super(const HealthHistoryState()) {
    on<LoadHealthHistoryEvent>(_load, transformer: restartable());
    on<ClearHealthHistoryEvent>(_clear);
  }

  final GetHealthHistoryUseCase _getHistory;
  int _generation = 0;

  Future<void> _load(
    LoadHealthHistoryEvent event,
    Emitter<HealthHistoryState> emit,
  ) async {
    final generation = _generation;
    final silent = event.silent && state.history != null;
    emit(
      state.copyWith(
        status: silent ? state.status : HealthHistoryStatus.loading,
        refreshing: silent,
        clearError: true,
      ),
    );
    final result = await _getHistory(NoParams());
    if (generation != _generation) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: state.history == null
              ? HealthHistoryStatus.error
              : HealthHistoryStatus.ready,
          refreshing: false,
          errorMessage: mapFailure(failure),
        ),
      ),
      (history) => emit(
        state.copyWith(
          status: HealthHistoryStatus.ready,
          history: history,
          refreshing: false,
          clearError: true,
        ),
      ),
    );
  }

  void _clear(ClearHealthHistoryEvent event, Emitter<HealthHistoryState> emit) {
    _generation++;
    emit(const HealthHistoryState());
  }
}
