part of 'vitals_bloc.dart';

abstract class VitalsEvent extends Equatable {
  const VitalsEvent();

  @override
  List<Object?> get props => [];
}

class LoadVitalsEvent extends VitalsEvent {
  const LoadVitalsEvent();
}

class LoadMoreAppointmentsEvent extends VitalsEvent {
  final String? query;
  const LoadMoreAppointmentsEvent({this.query});

  @override
  List<Object?> get props => [query];
}

class LoadMoreMedicationsEvent extends VitalsEvent {
  final String? query;
  const LoadMoreMedicationsEvent({this.query});

  @override
  List<Object?> get props => [query];
}

class AddBpReadingEvent extends VitalsEvent {
  final Map<String, dynamic> payload;
  const AddBpReadingEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

class AddBsReadingEvent extends VitalsEvent {
  final Map<String, dynamic> payload;
  const AddBsReadingEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

class AddMedicationEvent extends VitalsEvent {
  final Map<String, dynamic> payload;
  const AddMedicationEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

class AddAppointmentEvent extends VitalsEvent {
  final Map<String, dynamic> payload;
  const AddAppointmentEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

class DeleteBpReadingEvent extends VitalsEvent {
  final String id;
  const DeleteBpReadingEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteBsReadingEvent extends VitalsEvent {
  final String id;
  const DeleteBsReadingEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteMedicationEvent extends VitalsEvent {
  final String id;
  const DeleteMedicationEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteAppointmentEvent extends VitalsEvent {
  final String id;
  const DeleteAppointmentEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearVitalsErrorEvent extends VitalsEvent {
  const ClearVitalsErrorEvent();
}

class ClearToastEvent extends VitalsEvent {
  const ClearToastEvent();
}
