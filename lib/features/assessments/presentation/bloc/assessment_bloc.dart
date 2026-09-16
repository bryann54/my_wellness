import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AssessmentEvent {
  const AssessmentEvent();
}

final class AssessmentRequested extends AssessmentEvent {
  const AssessmentRequested();
}

sealed class AssessmentState {
  const AssessmentState();
}

final class AssessmentCatalogueUnavailable extends AssessmentState {
  const AssessmentCatalogueUnavailable();
}

class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  AssessmentBloc() : super(const AssessmentCatalogueUnavailable()) {
    on<AssessmentRequested>(
        (event, emit) => emit(const AssessmentCatalogueUnavailable()));
  }
}
