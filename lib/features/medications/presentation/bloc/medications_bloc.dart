import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication_scan.dart';
import 'package:my_wellness/features/vitals/domain/usecases/vitals_usecases.dart';

part 'medications_event.dart';
part 'medications_state.dart';

@injectable
class MedicationsBloc extends Bloc<MedicationsEvent, MedicationsState> {
  MedicationsBloc(
    this._getMedications,
    this._createMedication,
    this._deleteMedication,
    this._scanMedication,
  ) : super(const MedicationsState()) {
    on<LoadMedicationsEvent>(_load);
    on<LoadMoreMedicationsEvent>(_loadMore);
    on<AddMedicationEvent>(_add);
    on<DeleteMedicationEvent>(_delete);
    on<ClearMedicationsToastEvent>(
      (_, emit) => emit(state.copyWith(clearToast: true)),
    );
  }

  final GetMedicationsPagedUseCase _getMedications;
  final CreateMedicationUseCase _createMedication;
  final DeleteMedicationUseCase _deleteMedication;
  final ScanMedicationUseCase _scanMedication;

  Future<void> _load(
    LoadMedicationsEvent event,
    Emitter<MedicationsState> emit,
  ) async {
    if (state.status == CollectionStatus.loading) return;
    emit(state.copyWith(status: CollectionStatus.loading, clearError: true));
    final result = await _getMedications((cursor: null, query: event.query));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CollectionStatus.error,
          errorMessage: mapFailure(failure),
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: CollectionStatus.loaded,
          medications: page.items,
          cursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
        ),
      ),
    );
  }

  Future<void> _loadMore(
    LoadMoreMedicationsEvent event,
    Emitter<MedicationsState> emit,
  ) async {
    final cursor = state.cursor;
    if (cursor == null || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    final result = await _getMedications((cursor: cursor, query: event.query));
    result.fold(
      (failure) => emit(
        _toast(
          state.copyWith(loadingMore: false),
          ToastType.error,
          mapFailure(failure),
        ),
      ),
      (page) => emit(
        state.copyWith(
          medications: [...state.medications, ...page.items],
          cursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          loadingMore: false,
        ),
      ),
    );
  }

  Future<void> _add(
    AddMedicationEvent event,
    Emitter<MedicationsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _createMedication(event.payload);
    result.fold(
      (failure) => emit(
        _toast(
          state.copyWith(
            isSubmitting: false,
            errorMessage: mapFailure(failure),
          ),
          ToastType.error,
          mapFailure(failure),
        ),
      ),
      (medication) => emit(
        _toast(
          state.copyWith(
            isSubmitting: false,
            medications: [medication, ...state.medications],
          ),
          ToastType.success,
          'Medication added.',
        ),
      ),
    );
  }

  Future<void> _delete(
    DeleteMedicationEvent event,
    Emitter<MedicationsState> emit,
  ) async {
    final result = await _deleteMedication(event.id);
    result.fold(
      (failure) => emit(_toast(state, ToastType.error, mapFailure(failure))),
      (_) => emit(
        _toast(
          state.copyWith(
            medications: state.medications
                .where((m) => m.id != event.id)
                .toList(growable: false),
          ),
          ToastType.success,
          'Medication deleted.',
        ),
      ),
    );
  }

  Future<Either<String, MedicationScanResult>> scanMedication({
    required String filePath,
    required String condition,
  }) async {
    final result = await _scanMedication((
      filePath: filePath,
      condition: condition,
    ));
    return result.fold((failure) => Left(mapFailure(failure)), Right.new);
  }

  MedicationsState _toast(
    MedicationsState source,
    ToastType type,
    String message,
  ) => source.copyWith(
    toastType: type,
    toastMessage: message,
    toastNonce: source.toastNonce + 1,
  );
}
