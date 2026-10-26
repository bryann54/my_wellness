import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/features/offline_sync/domain/repositories/sync_repository.dart';

part 'sync_event.dart';
part 'sync_state.dart';

@injectable
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncRepository _repository;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _restoredTimer;

  SyncBloc(this._repository, this._connectivity) : super(const SyncState()) {
    on<StartSyncMonitoringEvent>(_onStart);
    on<TriggerSyncEvent>(_onTrigger);
    on<ConnectivityChangedEvent>(_onConnectivityChanged);
    on<DismissConnectivityRestoredEvent>((event, emit) {
      if (state.status == SyncStatus.restored) {
        emit(state.copyWith(status: SyncStatus.idle));
      }
    });

    _connectivitySub = _connectivity.onConnectivityChanged.listen((result) {
      add(ConnectivityChangedEvent(result));
    });
  }

  Future<void> _onStart(
    StartSyncMonitoringEvent event,
    Emitter<SyncState> emit,
  ) async {
    await _refreshCount(emit);
    add(const TriggerSyncEvent());
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChangedEvent event,
    Emitter<SyncState> emit,
  ) async {
    final hasNetwork = event.results.any((r) => r != ConnectivityResult.none);

    if (hasNetwork) {
      if (state.status == SyncStatus.offline) {
        emit(
          state.copyWith(
            status: SyncStatus.restored,
            pendingCount: 0,
            clearError: true,
          ),
        );
        _restoredTimer?.cancel();
        _restoredTimer = Timer(const Duration(seconds: 3), () {
          if (!isClosed) add(const DismissConnectivityRestoredEvent());
        });
      }
      add(const TriggerSyncEvent());
    } else {
      emit(state.copyWith(status: SyncStatus.offline));
    }
  }

  Future<void> _onTrigger(
    TriggerSyncEvent event,
    Emitter<SyncState> emit,
  ) async {
    if (state.status == SyncStatus.syncing) return;

    final connectivityResult = await _connectivity.checkConnectivity();
    final hasNetwork = connectivityResult.any(
      (r) => r != ConnectivityResult.none,
    );

    if (!hasNetwork) {
      emit(state.copyWith(status: SyncStatus.offline));
      return;
    }

    final pendingRes = await _repository.getPendingCount();
    final pending = pendingRes.getOrElse(() => 0);

    if (pending == 0) {
      if (state.status == SyncStatus.restored) return;
      emit(state.copyWith(status: SyncStatus.idle, pendingCount: 0));
      return;
    }

    emit(state.copyWith(status: SyncStatus.syncing, pendingCount: pending));

    final result = await _repository.processQueue();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SyncStatus.error,
          errorMessage: failure.toString(),
        ),
      ),
      (syncedCount) async {
        await _refreshCount(emit);
      },
    );
  }

  Future<void> _refreshCount(Emitter<SyncState> emit) async {
    final res = await _repository.getPendingCount();
    final count = res.getOrElse(() => 0);
    emit(
      state.copyWith(
        pendingCount: count,
        status: count == 0 ? SyncStatus.idle : state.status,
      ),
    );
  }

  @override
  Future<void> close() {
    _restoredTimer?.cancel();
    _connectivitySub?.cancel();
    return super.close();
  }
}
