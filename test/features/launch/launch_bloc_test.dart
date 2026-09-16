import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wellness/features/launch/domain/usecases/restore_session_usecase.dart';
import 'package:my_wellness/features/launch/presentation/bloc/launch_bloc.dart';

void main() {
  blocTest<LaunchBloc, LaunchState>(
    'routes a build with no approved durable session to unauthenticated',
    build: () => LaunchBloc(RestoreSessionUseCase()),
    act: (bloc) => bloc.add(const LaunchStarted()),
    expect: () => [isA<LaunchUnauthenticated>()],
  );
}
