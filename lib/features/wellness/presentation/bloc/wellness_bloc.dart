import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'wellness_event.dart';
part 'wellness_state.dart';

class WellnessBloc extends Bloc<WellnessEvent, WellnessState> {
  WellnessBloc() : super(WellnessInitial()) {
    on<WellnessEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
