part of 'medications_bloc.dart';

enum CollectionStatus { initial, loading, loaded, error }

enum ToastType { success, error }

class MedicationsState extends Equatable {
  const MedicationsState({
    this.status = CollectionStatus.initial,
    this.medications = const [],
    this.cursor,
    this.loadingMore = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.toastType,
    this.toastMessage,
    this.toastNonce = 0,
  });

  final CollectionStatus status;
  final List<Medication> medications;
  final String? cursor;
  final bool loadingMore;
  final bool isSubmitting;
  final String? errorMessage;
  final ToastType? toastType;
  final String? toastMessage;
  final int toastNonce;

  MedicationsState copyWith({
    CollectionStatus? status,
    List<Medication>? medications,
    String? cursor,
    bool? loadingMore,
    bool? isSubmitting,
    String? errorMessage,
    ToastType? toastType,
    String? toastMessage,
    int? toastNonce,
    bool clearError = false,
    bool clearCursor = false,
    bool clearToast = false,
  }) => MedicationsState(
    status: status ?? this.status,
    medications: medications ?? this.medications,
    cursor: clearCursor ? null : cursor ?? this.cursor,
    loadingMore: loadingMore ?? this.loadingMore,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    toastType: clearToast ? null : toastType ?? this.toastType,
    toastMessage: clearToast ? null : toastMessage ?? this.toastMessage,
    toastNonce: clearToast ? 0 : toastNonce ?? this.toastNonce,
  );

  @override
  List<Object?> get props => [
    status,
    medications,
    cursor,
    loadingMore,
    isSubmitting,
    errorMessage,
    toastType,
    toastMessage,
    toastNonce,
  ];
}
