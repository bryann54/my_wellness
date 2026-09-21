part of 'care_navigation_bloc.dart';

abstract class CareNavigationState extends Equatable {
  const CareNavigationState();

  @override
  List<Object> get props => [];
}

class CareNavigationInitial extends CareNavigationState {}
