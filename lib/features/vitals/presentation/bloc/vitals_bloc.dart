import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'vitals_event.dart';
part 'vitals_state.dart';

class VitalsBloc extends Bloc<VitalsEvent, VitalsState> {
  VitalsBloc() : super(VitalsInitial()) {
    on<VitalsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
