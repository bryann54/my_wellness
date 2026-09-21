import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'health_profile_event.dart';
part 'health_profile_state.dart';

class HealthProfileBloc extends Bloc<HealthProfileEvent, HealthProfileState> {
  HealthProfileBloc() : super(HealthProfileInitial()) {
    on<HealthProfileEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
