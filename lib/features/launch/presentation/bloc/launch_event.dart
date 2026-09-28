import 'package:equatable/equatable.dart';

abstract class LaunchEvent extends Equatable {
  const LaunchEvent();
  @override
  List<Object?> get props => [];
}

class StartLaunchEvent extends LaunchEvent {
  const StartLaunchEvent();
}

class ContinueOfflineEvent extends LaunchEvent {
  const ContinueOfflineEvent();
}
