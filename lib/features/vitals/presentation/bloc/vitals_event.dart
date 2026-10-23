part of 'vitals_bloc.dart';

abstract class VitalsEvent extends Equatable {
  const VitalsEvent();
  @override
  List<Object?> get props => [];
}

class LoadVitalsEvent extends VitalsEvent {
  const LoadVitalsEvent();
}

class LoadVitalsSummaryEvent extends VitalsEvent {
  const LoadVitalsSummaryEvent();
}

class AddBpReadingEvent extends VitalsEvent {
  const AddBpReadingEvent(this.payload);
  final Map<String, dynamic> payload;
  @override
  List<Object?> get props => [payload];
}

class AddBsReadingEvent extends VitalsEvent {
  const AddBsReadingEvent(this.payload);
  final Map<String, dynamic> payload;
  @override
  List<Object?> get props => [payload];
}

class DeleteBpReadingEvent extends VitalsEvent {
  const DeleteBpReadingEvent(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class DeleteBsReadingEvent extends VitalsEvent {
  const DeleteBsReadingEvent(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class ClearVitalsErrorEvent extends VitalsEvent {
  const ClearVitalsErrorEvent();
}

class ClearToastEvent extends VitalsEvent {
  const ClearToastEvent();
}
