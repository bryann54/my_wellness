import 'package:equatable/equatable.dart';
import 'package:my_wellness/features/auth/domain/entities/user_entity.dart';

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
  final UserEntity user;
  const LaunchAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class LaunchError extends LaunchState {
  final String message;
  const LaunchError(this.message);
  @override
  List<Object?> get props => [message];
}
