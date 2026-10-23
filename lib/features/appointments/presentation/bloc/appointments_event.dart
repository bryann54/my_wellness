part of 'appointments_bloc.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAppointmentsEvent extends AppointmentsEvent {
  const LoadAppointmentsEvent({this.query});
  final String? query;
  @override
  List<Object?> get props => [query];
}

class LoadMoreAppointmentsEvent extends AppointmentsEvent {
  const LoadMoreAppointmentsEvent({this.query});
  final String? query;
  @override
  List<Object?> get props => [query];
}

class AddAppointmentEvent extends AppointmentsEvent {
  const AddAppointmentEvent(this.payload);
  final Map<String, dynamic> payload;
  @override
  List<Object?> get props => [payload];
}

class DeleteAppointmentEvent extends AppointmentsEvent {
  const DeleteAppointmentEvent(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class ClearAppointmentsToastEvent extends AppointmentsEvent {
  const ClearAppointmentsToastEvent();
}
