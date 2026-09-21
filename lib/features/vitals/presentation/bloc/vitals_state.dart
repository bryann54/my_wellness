part of 'vitals_bloc.dart';

abstract class VitalsState extends Equatable {
  const VitalsState();

  @override
  List<Object> get props => [];
}

class VitalsInitial extends VitalsState {}
