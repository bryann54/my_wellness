import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';
import 'package:my_wellness/features/vitals/domain/entities/bp_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/bs_reading.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication.dart';
import 'package:my_wellness/features/vitals/domain/usecases/vitals_usecases.dart';

part 'vitals_event.dart';
part 'vitals_state.dart';

@injectable
class VitalsBloc extends Bloc<VitalsEvent, VitalsState> {
  final GetAppointmentsPagedUseCase _getAppointments;
  final GetMedicationsPagedUseCase _getMedications;
  final GetBloodPressureReadingsUseCase _getBp;
  final GetBloodSugarReadingsUseCase _getBs;
  final CreateBloodPressureReadingUseCase _createBp;
  final CreateBloodSugarReadingUseCase _createBs;
  final CreateMedicationUseCase _createMedication;
  final CreateAppointmentUseCase _createAppointment;
  final DeleteBloodPressureReadingUseCase _deleteBp;
  final DeleteBloodSugarReadingUseCase _deleteBs;
  final DeleteMedicationUseCase _deleteMedication;
  final DeleteAppointmentUseCase _deleteAppointment;

  VitalsBloc(
    this._getAppointments,
    this._getMedications,
    this._getBp,
    this._getBs,
    this._createBp,
    this._createBs,
    this._createMedication,
    this._createAppointment,
    this._deleteBp,
    this._deleteBs,
    this._deleteMedication,
    this._deleteAppointment,
  ) : super(const VitalsState()) {
    on<LoadVitalsEvent>(_onLoad);
    on<LoadMoreAppointmentsEvent>(_onLoadMoreAppointments);
    on<LoadMoreMedicationsEvent>(_onLoadMoreMedications);
    on<AddBpReadingEvent>(_onAddBp);
    on<AddBsReadingEvent>(_onAddBs);
    on<AddMedicationEvent>(_onAddMedication);
    on<AddAppointmentEvent>(_onAddAppointment);
    on<DeleteBpReadingEvent>(_onDeleteBp);
    on<DeleteBsReadingEvent>(_onDeleteBs);
    on<DeleteMedicationEvent>(_onDeleteMedication);
    on<DeleteAppointmentEvent>(_onDeleteAppointment);
    on<ClearVitalsErrorEvent>(
      (_, emit) => emit(state.copyWith(clearError: true)),
    );
    on<ClearToastEvent>((_, emit) => emit(state.copyWith(clearToast: true)));
  }
  //helpers
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

  //load
  Future<void> _onLoad(LoadVitalsEvent event, Emitter<VitalsState> emit) async {
    emit(state.copyWith(status: VitalsStatus.loading, clearError: true));

    final appts = await _getAppointments((cursor: null, query: null));
    final meds = await _getMedications((cursor: null, query: null));
    final bp = await _getBp(NoParams());
    final bs = await _getBs(NoParams());

    final failure =
        appts.fold<Failure?>((f) => f, (_) => null) ??
        meds.fold<Failure?>((f) => f, (_) => null) ??
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
        appointments: appts
            .getOrElse(() => (items: const [], nextCursor: null))
            .items,
        appointmentsCursor: appts
            .getOrElse(() => (items: const [], nextCursor: null))
            .nextCursor,
        medications: meds
            .getOrElse(() => (items: const [], nextCursor: null))
            .items,
        medicationsCursor: meds
            .getOrElse(() => (items: const [], nextCursor: null))
            .nextCursor,
        bpReadings: bp.getOrElse(() => const []),
        bsReadings: bs.getOrElse(() => const []),
      ),
    );
  }

  Future<void> _onLoadMoreAppointments(
    LoadMoreAppointmentsEvent event,
    Emitter<VitalsState> emit,
  ) async {
    if (state.appointmentsCursor == null) return;
    final result = await _getAppointments((
      cursor: state.appointmentsCursor,
      query: event.query,
    ));
    result.fold(
      (f) => emit(_toastError(state, mapFailure(f))),
      (page) => emit(
        state.copyWith(
          appointments: [...state.appointments, ...page.items],
          appointmentsCursor: page.nextCursor,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreMedications(
    LoadMoreMedicationsEvent event,
    Emitter<VitalsState> emit,
  ) async {
    if (state.medicationsCursor == null) return;
    final result = await _getMedications((
      cursor: state.medicationsCursor,
      query: event.query,
    ));
    result.fold(
      (f) => emit(_toastError(state, mapFailure(f))),
      (page) => emit(
        state.copyWith(
          medications: [...state.medications, ...page.items],
          medicationsCursor: page.nextCursor,
        ),
      ),
    );
  }

  //add
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

  Future<void> _onAddMedication(
    AddMedicationEvent event,
    Emitter<VitalsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _createMedication(event.payload);
    result.fold(
      (f) => emit(
        _toastError(
          state.copyWith(isSubmitting: false, errorMessage: mapFailure(f)),
          mapFailure(f),
        ),
      ),
      (med) => emit(
        _toastSuccess(
          state.copyWith(
            isSubmitting: false,
            medications: [med, ...state.medications],
          ),
          'Medication added.',
        ),
      ),
    );
  }

  Future<void> _onAddAppointment(
    AddAppointmentEvent event,
    Emitter<VitalsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _createAppointment(event.payload);
    result.fold(
      (f) => emit(
        _toastError(
          state.copyWith(isSubmitting: false, errorMessage: mapFailure(f)),
          mapFailure(f),
        ),
      ),
      (appt) => emit(
        _toastSuccess(
          state.copyWith(
            isSubmitting: false,
            appointments: [appt, ...state.appointments],
          ),
          'Appointment booked.',
        ),
      ),
    );
  }

  //delete
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

  Future<void> _onDeleteMedication(
    DeleteMedicationEvent event,
    Emitter<VitalsState> emit,
  ) async {
    final result = await _deleteMedication(event.id);
    result.fold(
      (f) => emit(_toastError(state, mapFailure(f))),
      (_) => emit(
        _toastSuccess(
          state.copyWith(
            medications: state.medications
                .where((m) => m.id != event.id)
                .toList(growable: false),
          ),
          'Medication deleted.',
        ),
      ),
    );
  }

  Future<void> _onDeleteAppointment(
    DeleteAppointmentEvent event,
    Emitter<VitalsState> emit,
  ) async {
    final result = await _deleteAppointment(event.id);
    result.fold(
      (f) => emit(_toastError(state, mapFailure(f))),
      (_) => emit(
        _toastSuccess(
          state.copyWith(
            appointments: state.appointments
                .where((a) => a.id != event.id)
                .toList(growable: false),
          ),
          'Appointment deleted.',
        ),
      ),
    );
  }
}
