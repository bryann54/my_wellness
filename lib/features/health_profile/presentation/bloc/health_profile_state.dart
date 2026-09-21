part of 'health_profile_bloc.dart';

abstract class HealthProfileState extends Equatable {
  const HealthProfileState();

  @override
  List<Object> get props => [];
}

class HealthProfileInitial extends HealthProfileState {}
