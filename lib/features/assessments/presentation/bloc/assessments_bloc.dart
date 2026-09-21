import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'assessments_event.dart';
part 'assessments_state.dart';

class AssessmentsBloc extends Bloc<AssessmentsEvent, AssessmentsState> {
  AssessmentsBloc() : super(AssessmentsInitial()) {
    on<AssessmentsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
