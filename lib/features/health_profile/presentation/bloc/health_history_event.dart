part of 'health_history_bloc.dart';

sealed class HealthHistoryEvent extends Equatable {
  const HealthHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHealthHistoryEvent extends HealthHistoryEvent {
  const LoadHealthHistoryEvent({this.silent = false});

  final bool silent;

  @override
  List<Object?> get props => [silent];
}

class ClearHealthHistoryEvent extends HealthHistoryEvent {
  const ClearHealthHistoryEvent();
}
