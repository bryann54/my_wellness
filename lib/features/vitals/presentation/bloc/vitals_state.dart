part of 'vitals_bloc.dart';

enum VitalsStatus { initial, loading, loaded, error }

enum ToastType { success, error, warning, info }

class VitalsState extends Equatable {
  const VitalsState({
    this.status = VitalsStatus.initial,
    this.bpReadings = const [],
    this.bsReadings = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.toastType,
    this.toastMessage,
    this.toastNonce = 0,
  });

  final VitalsStatus status;
  final List<BpReading> bpReadings;
  final List<BsReading> bsReadings;
  final String? errorMessage;
  final bool isSubmitting;
  final ToastType? toastType;
  final String? toastMessage;
  final int toastNonce;

  VitalsState copyWith({
    VitalsStatus? status,
    List<BpReading>? bpReadings,
    List<BsReading>? bsReadings,
    String? errorMessage,
    bool? isSubmitting,
    ToastType? toastType,
    String? toastMessage,
    int? toastNonce,
    bool clearError = false,
    bool clearToast = false,
  }) => VitalsState(
    status: status ?? this.status,
    bpReadings: bpReadings ?? this.bpReadings,
    bsReadings: bsReadings ?? this.bsReadings,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    toastType: clearToast ? null : toastType ?? this.toastType,
    toastMessage: clearToast ? null : toastMessage ?? this.toastMessage,
    toastNonce: clearToast ? 0 : toastNonce ?? this.toastNonce,
  );

  BpReading? get latestBp => bpReadings.isEmpty ? null : bpReadings.first;
  BsReading? get latestBs => bsReadings.isEmpty ? null : bsReadings.first;

  @override
  List<Object?> get props => [
    status,
    bpReadings,
    bsReadings,
    errorMessage,
    isSubmitting,
    toastType,
    toastMessage,
    toastNonce,
  ];
}
