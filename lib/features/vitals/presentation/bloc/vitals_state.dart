part of 'vitals_bloc.dart';

enum VitalsStatus { initial, loading, loaded, error }

enum ToastType { success, error, warning, info }

class VitalsState extends Equatable {
  final VitalsStatus status;
  final List<Medication> medications;
  final List<Appointment> appointments;
  final List<BpReading> bpReadings;
  final List<BsReading> bsReadings;
  final String? medicationsCursor;
  final String? appointmentsCursor;
  final String? errorMessage;
  final bool isSubmitting;
  final ToastType? toastType;
  final String? toastMessage;
  final int toastNonce;

  const VitalsState({
    this.status = VitalsStatus.initial,
    this.medications = const [],
    this.appointments = const [],
    this.bpReadings = const [],
    this.bsReadings = const [],
    this.medicationsCursor,
    this.appointmentsCursor,
    this.errorMessage,
    this.isSubmitting = false,
    this.toastType,
    this.toastMessage,
    this.toastNonce = 0,
  });

  VitalsState copyWith({
    VitalsStatus? status,
    List<Medication>? medications,
    List<Appointment>? appointments,
    List<BpReading>? bpReadings,
    List<BsReading>? bsReadings,
    String? medicationsCursor,
    String? appointmentsCursor,
    String? errorMessage,
    bool? isSubmitting,
    ToastType? toastType,
    String? toastMessage,
    int? toastNonce,
    bool clearError = false,
    bool clearToast = false,
  }) {
    return VitalsState(
      status: status ?? this.status,
      medications: medications ?? this.medications,
      appointments: appointments ?? this.appointments,
      bpReadings: bpReadings ?? this.bpReadings,
      bsReadings: bsReadings ?? this.bsReadings,
      medicationsCursor: medicationsCursor ?? this.medicationsCursor,
      appointmentsCursor: appointmentsCursor ?? this.appointmentsCursor,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      toastType: clearToast ? null : (toastType ?? this.toastType),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      toastNonce: clearToast ? 0 : (toastNonce ?? this.toastNonce),
    );
  }

  BpReading? get latestBp => bpReadings.isEmpty ? null : bpReadings.first;
  BsReading? get latestBs => bsReadings.isEmpty ? null : bsReadings.first;

  @override
  List<Object?> get props => [
    status,
    medications,
    appointments,
    bpReadings,
    bsReadings,
    medicationsCursor,
    appointmentsCursor,
    errorMessage,
    isSubmitting,
    toastType,
    toastMessage,
    toastNonce,
  ];
}
