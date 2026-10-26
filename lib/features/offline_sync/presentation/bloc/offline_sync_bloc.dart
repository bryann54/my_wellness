import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'offline_sync_event.dart';
part 'offline_sync_state.dart';

class OfflineSyncBloc extends Bloc<OfflineSyncEvent, OfflineSyncState> {
  OfflineSyncBloc() : super(OfflineSyncInitial()) {
    on<OfflineSyncEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
