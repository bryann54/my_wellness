import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/auth/domain/usecases/auth_usecases.dart';
import 'package:my_wellness/features/subscriptions/presentation/bloc/subscriptions_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final ConfirmSignupEmailUseCase _confirmSignupEmailUseCase;
  final ConfirmSignupPhoneUseCase _confirmSignupPhoneUseCase;
  final ResendSignupEmailUseCase _resendSignupEmailUseCase;
  final ResendSignupPhoneUseCase _resendSignupPhoneUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetAuthStateUseCase _getAuthStateUseCase;
  final RequestPasswordResetUseCase _requestPasswordResetUseCase;
  final ConfirmPasswordResetUseCase _confirmPasswordResetUseCase;
  final SubscriptionsBloc _subscriptionsBloc;

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required ConfirmSignupEmailUseCase confirmSignupEmailUseCase,
    required ConfirmSignupPhoneUseCase confirmSignupPhoneUseCase,
    required ResendSignupEmailUseCase resendSignupEmailUseCase,
    required ResendSignupPhoneUseCase resendSignupPhoneUseCase,
    required SignOutUseCase signOutUseCase,
    required GetAuthStateUseCase getAuthStateUseCase,
    required RequestPasswordResetUseCase requestPasswordResetUseCase,
    required ConfirmPasswordResetUseCase confirmPasswordResetUseCase,
    required SubscriptionsBloc subscriptionsBloc,
  }) : _signInUseCase = signInUseCase,
       _signUpUseCase = signUpUseCase,
       _confirmSignupEmailUseCase = confirmSignupEmailUseCase,
       _confirmSignupPhoneUseCase = confirmSignupPhoneUseCase,
       _resendSignupEmailUseCase = resendSignupEmailUseCase,
       _resendSignupPhoneUseCase = resendSignupPhoneUseCase,
       _signOutUseCase = signOutUseCase,
       _getAuthStateUseCase = getAuthStateUseCase,
       _requestPasswordResetUseCase = requestPasswordResetUseCase,
       _confirmPasswordResetUseCase = confirmPasswordResetUseCase,
       _subscriptionsBloc = subscriptionsBloc,
       super(const AuthState()) {
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<ConfirmSignupEmailEvent>(_onConfirmSignupEmail);
    on<ConfirmSignupPhoneEvent>(_onConfirmSignupPhone);
    on<ResendSignupEmailEvent>(_onResendSignupEmail);
    on<ResendSignupPhoneEvent>(_onResendSignupPhone);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RequestPasswordResetEvent>(_onRequestPasswordReset);
    on<ConfirmPasswordResetEvent>(_onConfirmPasswordReset);
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _signInUseCase(
      identifier: event.identifier,
      password: event.password,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: mapFailureToMessage(failure),
        ),
      ),
      (session) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: session.user,
          clearPending: true,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _signUpUseCase(event.request);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: mapFailureToMessage(failure),
        ),
      ),
      (pending) => emit(
        state.copyWith(
          status: AuthStatus.awaitingSignupConfirmation,
          pendingSignup: pending,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onConfirmSignupEmail(
    ConfirmSignupEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _confirmSignupEmailUseCase(
      email: event.email,
      code: event.code,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.awaitingSignupConfirmation,
          errorMessage: mapFailureToMessage(failure),
        ),
      ),
      (_) => emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearPending: true),
      ),
    );
  }

  Future<void> _onConfirmSignupPhone(
    ConfirmSignupPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _confirmSignupPhoneUseCase(
      phone: event.phone,
      code: event.code,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.awaitingSignupConfirmation,
          errorMessage: mapFailureToMessage(failure),
        ),
      ),
      (_) => emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearPending: true),
      ),
    );
  }

  Future<void> _onResendSignupEmail(
    ResendSignupEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _resendSignupEmailUseCase(email: event.email);
    result.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: mapFailureToMessage(failure))),
      (_) => emit(state.copyWith(clearError: true)),
    );
  }

  Future<void> _onResendSignupPhone(
    ResendSignupPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _resendSignupPhoneUseCase(phone: event.phone);
    result.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: mapFailureToMessage(failure))),
      (_) => emit(state.copyWith(clearError: true)),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await emit.forEach(
      _getAuthStateUseCase(),
      onData: (user) {
        if (user != null) {
          return state.copyWith(status: AuthStatus.authenticated, user: user);
        }
        return state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        );
      },
      onError: (error, _) => state.copyWith(
        status: AuthStatus.error,
        errorMessage: error.toString(),
      ),
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _signOutUseCase(allDevices: event.allDevices);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: mapFailureToMessage(failure),
        ),
      ),
      (_) {
        _subscriptionsBloc.add(RCLogOut());
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            clearUser: true,
            clearPending: true,
          ),
        );
      },
    );
  }

  Future<void> _onRequestPasswordReset(
    RequestPasswordResetEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _requestPasswordResetUseCase(
      identifier: event.identifier,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: mapFailureToMessage(failure),
        ),
      ),
      (_) => emit(state.copyWith(status: AuthStatus.passwordResetRequested)),
    );
  }

  Future<void> _onConfirmPasswordReset(
    ConfirmPasswordResetEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _confirmPasswordResetUseCase(
      identifier: event.identifier,
      code: event.code,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: mapFailureToMessage(failure),
        ),
      ),
      (_) => emit(state.copyWith(status: AuthStatus.passwordResetCompleted)),
    );
  }
}
