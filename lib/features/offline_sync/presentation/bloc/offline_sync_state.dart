part of 'offline_sync_bloc.dart';

abstract class OfflineSyncState extends Equatable {
  const OfflineSyncState();

  @override
  List<Object> get props => [];
}

class OfflineSyncInitial extends OfflineSyncState {}
