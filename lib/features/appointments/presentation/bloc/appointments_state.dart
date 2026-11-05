part of 'appointments_bloc.dart';

enum CollectionStatus { initial, loading, loaded, error }

enum ToastType { success, error }

class AppointmentsState extends Equatable {
  const AppointmentsState({
    this.status = CollectionStatus.initial,
    this.appointments = const [],
    this.cursor,
    this.loadingMore = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.searchQuery = '',
    this.toastType,
    this.toastMessage,
    this.toastNonce = 0,
  });

  final CollectionStatus status;
  final List<Appointment> appointments;
  final String? cursor;
  final bool loadingMore;
  final bool isSubmitting;
  final String? errorMessage;
  final String searchQuery;
  final ToastType? toastType;
  final String? toastMessage;
  final int toastNonce;

  bool get isSearching => searchQuery.trim().isNotEmpty;

  List<Appointment> get filteredAppointments {
    final q = _normalize(searchQuery);
    if (q.isEmpty) return appointments;
    return appointments
        .where((a) {
          final facility = a.facility;
          return _matches(a.clinicName, q) ||
              _matches(a.condition, q) ||
              _matches(a.notes, q) ||
              _matches(facility?.name, q) ||
              _matches(facility?.locality, q);
        })
        .toList(growable: false);
  }

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll('_', ' ').trim();

  static bool _matches(String? value, String query) =>
      value != null && _normalize(value).contains(query);

  AppointmentsState copyWith({
    CollectionStatus? status,
    List<Appointment>? appointments,
    String? cursor,
    bool? loadingMore,
    bool? isSubmitting,
    String? errorMessage,
    String? searchQuery,
    ToastType? toastType,
    String? toastMessage,
    int? toastNonce,
    bool clearError = false,
    bool clearCursor = false,
    bool clearToast = false,
  }) => AppointmentsState(
    status: status ?? this.status,
    appointments: appointments ?? this.appointments,
    cursor: clearCursor ? null : cursor ?? this.cursor,
    loadingMore: loadingMore ?? this.loadingMore,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    searchQuery: searchQuery ?? this.searchQuery,
    toastType: clearToast ? null : toastType ?? this.toastType,
    toastMessage: clearToast ? null : toastMessage ?? this.toastMessage,
    toastNonce: clearToast ? 0 : toastNonce ?? this.toastNonce,
  );

  @override
  List<Object?> get props => [
    status,
    appointments,
    cursor,
    loadingMore,
    isSubmitting,
    errorMessage,
    searchQuery,
    toastType,
    toastMessage,
    toastNonce,
  ];
}
