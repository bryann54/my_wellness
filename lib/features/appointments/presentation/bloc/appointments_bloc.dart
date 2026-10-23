import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';
import 'package:my_wellness/features/vitals/domain/usecases/vitals_usecases.dart';

part 'appointments_event.dart';
part 'appointments_state.dart';

@injectable
class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  AppointmentsBloc(
    this._getAppointments,
    this._createAppointment,
    this._deleteAppointment,
  ) : super(const AppointmentsState()) {
    on<LoadAppointmentsEvent>(_load);
    on<LoadMoreAppointmentsEvent>(_loadMore);
    on<AddAppointmentEvent>(_add);
    on<DeleteAppointmentEvent>(_delete);
    on<ClearAppointmentsToastEvent>(
      (_, emit) => emit(state.copyWith(clearToast: true)),
    );
  }

  final GetAppointmentsPagedUseCase _getAppointments;
  final CreateAppointmentUseCase _createAppointment;
  final DeleteAppointmentUseCase _deleteAppointment;

  Future<void> _load(
    LoadAppointmentsEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state.status == CollectionStatus.loading) return;
    emit(state.copyWith(status: CollectionStatus.loading, clearError: true));
    final result = await _getAppointments((cursor: null, query: event.query));
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
          appointments: page.items,
          cursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
        ),
      ),
    );
  }

  Future<void> _loadMore(
    LoadMoreAppointmentsEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    final cursor = state.cursor;
    if (cursor == null || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    final result = await _getAppointments((cursor: cursor, query: event.query));
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
          appointments: [...state.appointments, ...page.items],
          cursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          loadingMore: false,
        ),
      ),
    );
  }

  Future<void> _add(
    AddAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _createAppointment(event.payload);
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
      (appointment) => emit(
        _toast(
          state.copyWith(
            isSubmitting: false,
            appointments: [appointment, ...state.appointments],
          ),
          ToastType.success,
          'Appointment booked.',
        ),
      ),
    );
  }

  Future<void> _delete(
    DeleteAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    final result = await _deleteAppointment(event.id);
    result.fold(
      (failure) => emit(_toast(state, ToastType.error, mapFailure(failure))),
      (_) => emit(
        _toast(
          state.copyWith(
            appointments: state.appointments
                .where((a) => a.id != event.id)
                .toList(growable: false),
          ),
          ToastType.success,
          'Appointment deleted.',
        ),
      ),
    );
  }

  AppointmentsState _toast(
    AppointmentsState source,
    ToastType type,
    String message,
  ) => source.copyWith(
    toastType: type,
    toastMessage: message,
    toastNonce: source.toastNonce + 1,
  );
}
