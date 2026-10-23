import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/vitals/domain/entities/bp_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/bs_reading.dart';
import 'package:my_wellness/features/vitals/domain/usecases/vitals_usecases.dart';
part 'vitals_event.dart';
part 'vitals_state.dart';

@injectable
class VitalsBloc extends Bloc<VitalsEvent, VitalsState> {
  final GetBloodPressureReadingsUseCase _getBp;
  final GetBloodSugarReadingsUseCase _getBs;
  final CreateBloodPressureReadingUseCase _createBp;
  final CreateBloodSugarReadingUseCase _createBs;
  final DeleteBloodPressureReadingUseCase _deleteBp;
  final DeleteBloodSugarReadingUseCase _deleteBs;

  VitalsBloc(
    this._getBp,
    this._getBs,
    this._createBp,
    this._createBs,
    this._deleteBp,
    this._deleteBs,
  ) : super(const VitalsState()) {
    on<LoadVitalsEvent>(_onLoad);
    on<LoadVitalsSummaryEvent>(_onLoadSummary);
    on<AddBpReadingEvent>(_onAddBp);
    on<AddBsReadingEvent>(_onAddBs);
    on<DeleteBpReadingEvent>(_onDeleteBp);
    on<DeleteBsReadingEvent>(_onDeleteBs);
    on<ClearVitalsErrorEvent>(
      (_, emit) => emit(state.copyWith(clearError: true)),
    );
    on<ClearToastEvent>((_, emit) => emit(state.copyWith(clearToast: true)));
  }
  VitalsState _toast(
    VitalsState s, {
    required ToastType type,
    required String message,
  }) {
    return s.copyWith(
      toastType: type,
      toastMessage: message,
      toastNonce: s.toastNonce + 1,
    );
  }

  VitalsState _toastError(VitalsState s, String message) =>
      _toast(s, type: ToastType.error, message: message);

  VitalsState _toastSuccess(VitalsState s, String message) =>
      _toast(s, type: ToastType.success, message: message);

  Future<void> _onLoadSummary(
    LoadVitalsSummaryEvent event,
    Emitter<VitalsState> emit,
  ) async {
    if (state.status == VitalsStatus.loading ||
        state.status == VitalsStatus.loaded) {
      return;
    }

    emit(state.copyWith(status: VitalsStatus.loading, clearError: true));
    final bp = await _getBp(NoParams());
    final bs = await _getBs(NoParams());
    final failure =
        bp.fold<Failure?>((failure) => failure, (_) => null) ??
        bs.fold<Failure?>((failure) => failure, (_) => null);

    if (failure != null) {
      emit(
        state.copyWith(
          status: VitalsStatus.error,
          errorMessage: mapFailure(failure),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: VitalsStatus.loaded,
        bpReadings: bp.getOrElse(() => const []),
        bsReadings: bs.getOrElse(() => const []),
      ),
    );
  }

  Future<void> _onLoad(LoadVitalsEvent event, Emitter<VitalsState> emit) async {
    emit(state.copyWith(status: VitalsStatus.loading, clearError: true));

    final bp = await _getBp(NoParams());
    final bs = await _getBs(NoParams());

    final failure =
        bp.fold<Failure?>((f) => f, (_) => null) ??
        bs.fold<Failure?>((f) => f, (_) => null);

    if (failure != null) {
      emit(
        state.copyWith(
          status: VitalsStatus.error,
          errorMessage: mapFailure(failure),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: VitalsStatus.loaded,
        bpReadings: bp.getOrElse(() => const []),
        bsReadings: bs.getOrElse(() => const []),
      ),
    );
  }

  Future<void> _onAddBp(
    AddBpReadingEvent event,
    Emitter<VitalsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _createBp(event.payload);
    result.fold(
      (f) => emit(
        _toastError(
          state.copyWith(isSubmitting: false, errorMessage: mapFailure(f)),
          mapFailure(f),
        ),
      ),
      (reading) => emit(
        _toastSuccess(
          state.copyWith(
            isSubmitting: false,
            bpReadings: [reading, ...state.bpReadings],
          ),
          'Blood pressure reading saved.',
        ),
      ),
    );
  }

  Future<void> _onAddBs(
    AddBsReadingEvent event,
    Emitter<VitalsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _createBs(event.payload);
    result.fold(
      (f) => emit(
        _toastError(
          state.copyWith(isSubmitting: false, errorMessage: mapFailure(f)),
          mapFailure(f),
        ),
      ),
      (reading) => emit(
        _toastSuccess(
          state.copyWith(
            isSubmitting: false,
            bsReadings: [reading, ...state.bsReadings],
          ),
          'Blood sugar reading saved.',
        ),
      ),
    );
  }

  Future<void> _onDeleteBp(
    DeleteBpReadingEvent event,
    Emitter<VitalsState> emit,
  ) async {
    final result = await _deleteBp(event.id);
    result.fold(
      (f) => emit(_toastError(state, mapFailure(f))),
      (_) => emit(
        _toastSuccess(
          state.copyWith(
            bpReadings: state.bpReadings
                .where((r) => r.id != event.id)
                .toList(growable: false),
          ),
          'Reading deleted.',
        ),
      ),
    );
  }

  Future<void> _onDeleteBs(
    DeleteBsReadingEvent event,
    Emitter<VitalsState> emit,
  ) async {
    final result = await _deleteBs(event.id);
    result.fold(
      (f) => emit(_toastError(state, mapFailure(f))),
      (_) => emit(
        _toastSuccess(
          state.copyWith(
            bsReadings: state.bsReadings
                .where((r) => r.id != event.id)
                .toList(growable: false),
          ),
          'Reading deleted.',
        ),
      ),
    );
  }
}
