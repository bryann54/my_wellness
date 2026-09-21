import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'medications_event.dart';
part 'medications_state.dart';

class MedicationsBloc extends Bloc<MedicationsEvent, MedicationsState> {
  MedicationsBloc() : super(MedicationsInitial()) {
    on<MedicationsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
