part of 'sync_bloc.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();
  @override
  List<Object?> get props => [];
}

class StartSyncMonitoringEvent extends SyncEvent {
  const StartSyncMonitoringEvent();
}

class TriggerSyncEvent extends SyncEvent {
  const TriggerSyncEvent();
}

class ConnectivityChangedEvent extends SyncEvent {
  final List<ConnectivityResult> results;
  const ConnectivityChangedEvent(this.results);
  @override
  List<Object?> get props => [results];
}

class DismissConnectivityRestoredEvent extends SyncEvent {
  const DismissConnectivityRestoredEvent();
}
