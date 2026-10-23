part of 'medications_bloc.dart';

abstract class MedicationsEvent extends Equatable {
  const MedicationsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMedicationsEvent extends MedicationsEvent {
  const LoadMedicationsEvent({this.query});
  final String? query;
  @override
  List<Object?> get props => [query];
}

class LoadMoreMedicationsEvent extends MedicationsEvent {
  const LoadMoreMedicationsEvent({this.query});
  final String? query;
  @override
  List<Object?> get props => [query];
}

class AddMedicationEvent extends MedicationsEvent {
  const AddMedicationEvent(this.payload);
  final Map<String, dynamic> payload;
  @override
  List<Object?> get props => [payload];
}

class DeleteMedicationEvent extends MedicationsEvent {
  const DeleteMedicationEvent(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class ClearMedicationsToastEvent extends MedicationsEvent {
  const ClearMedicationsToastEvent();
}
