part of 'medications_bloc.dart';

abstract class MedicationsState extends Equatable {
  const MedicationsState();

  @override
  List<Object> get props => [];
}

class MedicationsInitial extends MedicationsState {}
