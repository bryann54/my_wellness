import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'care_navigation_event.dart';
part 'care_navigation_state.dart';

class CareNavigationBloc
    extends Bloc<CareNavigationEvent, CareNavigationState> {
  CareNavigationBloc() : super(CareNavigationInitial()) {
    on<CareNavigationEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
