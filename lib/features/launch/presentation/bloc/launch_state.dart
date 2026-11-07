import 'package:equatable/equatable.dart';

abstract class LaunchState extends Equatable {
  const LaunchState();
  @override
  List<Object?> get props => [];
}

class LaunchInitial extends LaunchState {}

class LaunchLoading extends LaunchState {}

class LaunchOffline extends LaunchState {}

class LaunchUnauthenticated extends LaunchState {}

class LaunchAuthenticated extends LaunchState {
  const LaunchAuthenticated();
}

class LaunchError extends LaunchState {
  final String message;
  const LaunchError(this.message);
  @override
  List<Object?> get props => [message];
}
