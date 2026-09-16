import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/features/auth/domain/usecases/begin_sign_in_usecase.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class SignInRequested extends AuthEvent {
  const SignInRequested();
}

sealed class AuthState {
  const AuthState();
}

final class AuthIdle extends AuthState {
  const AuthIdle();
}

final class AuthSubmitting extends AuthState {
  const AuthSubmitting();
}

final class AuthUnavailable extends AuthState {
  const AuthUnavailable();
}

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._beginSignIn) : super(const AuthIdle()) {
    on<SignInRequested>((event, emit) async {
      emit(const AuthSubmitting());
      await _beginSignIn();
      emit(const AuthUnavailable());
    });
  }
  final BeginSignInUseCase _beginSignIn;
}
