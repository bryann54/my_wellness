import 'package:flutter_bloc/flutter_bloc.dart';

sealed class ConsentEvent {
  const ConsentEvent();
}

final class ConsentAcknowledged extends ConsentEvent {
  const ConsentAcknowledged();
}

sealed class ConsentState {
  const ConsentState();
}

final class ConsentReviewRequired extends ConsentState {
  const ConsentReviewRequired();
}

final class ConsentContractUnavailable extends ConsentState {
  const ConsentContractUnavailable();
}

class ConsentBloc extends Bloc<ConsentEvent, ConsentState> {
  ConsentBloc() : super(const ConsentReviewRequired()) {
    on<ConsentAcknowledged>(
        (event, emit) => emit(const ConsentContractUnavailable()));
  }
}
