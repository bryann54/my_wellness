part of 'home_bloc.dart';

enum HomeDashboardStatus { initial, loading, ready, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeDashboardStatus.initial,
    this.sessions = const [],
    this.errorMessage,
  });

  final HomeDashboardStatus status;
  final List<DashboardSession> sessions;
  final String? errorMessage;

  HomeState copyWith({
    HomeDashboardStatus? status,
    List<DashboardSession>? sessions,
    String? errorMessage,
    bool clearError = false,
  }) => HomeState(
    status: status ?? this.status,
    sessions: sessions ?? this.sessions,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, sessions, errorMessage];
}
