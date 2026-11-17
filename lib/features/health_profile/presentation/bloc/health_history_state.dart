part of 'health_history_bloc.dart';

enum HealthHistoryStatus { initial, loading, ready, error }

class HealthHistoryState extends Equatable {
  const HealthHistoryState({
    this.status = HealthHistoryStatus.initial,
    this.history,
    this.refreshing = false,
    this.errorMessage,
  });

  final HealthHistoryStatus status;
  final HealthHistory? history;
  final bool refreshing;
  final String? errorMessage;

  HealthHistoryState copyWith({
    HealthHistoryStatus? status,
    HealthHistory? history,
    bool? refreshing,
    String? errorMessage,
    bool clearError = false,
  }) => HealthHistoryState(
    status: status ?? this.status,
    history: history ?? this.history,
    refreshing: refreshing ?? this.refreshing,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [status, history, refreshing, errorMessage];
}
