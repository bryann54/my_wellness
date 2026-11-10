import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:my_wellness/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:my_wellness/features/auth/data/models/auth_session_model.dart';
import 'package:my_wellness/features/auth/data/models/signup_pending_model.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/data/models/user_model.dart';
import 'package:my_wellness/features/auth/data/models/verified_identity_model.dart';
import 'package:my_wellness/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';
import 'package:my_wellness/features/auth/domain/usecases/auth_usecases.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/mfa_verification_dialog.dart';

void main() {
  group('auth repository contract', () {
    late _FakeRemote remote;
    late _FakeLocal local;
    late AuthRepositoryImpl repository;

    setUp(() {
      remote = _FakeRemote();
      local = _FakeLocal();
      repository = AuthRepositoryImpl(remote, local);
    });

    test('unconfirmed email login becomes an email OTP result', () async {
      remote.loginError = ValidationException(
        'Confirm your email.',
        code: 'email_not_confirmed',
        details: const {'email': 'member@example.com'},
      );

      final result = await repository.signIn(
        identifier: 'member@example.com',
        password: 'legacy-password',
      );
      final signIn = result.fold((failure) => throw failure, (value) => value);

      expect(signIn.requiresSignupConfirmation, isTrue);
      expect(signIn.pendingSignup?.channel, SignupChannel.email);
      expect(signIn.pendingSignup?.destination, 'member@example.com');
      expect(local.savedAccess, isNull);
    });

    test('unverified phone login becomes a phone OTP result', () async {
      remote.loginError = ValidationException(
        'Confirm your phone.',
        code: 'phone_not_verified',
        details: const {'phone': '254700000000'},
      );

      final result = await repository.signIn(
        identifier: '254700000000',
        password: '123456',
      );
      final signIn = result.fold((failure) => throw failure, (value) => value);

      expect(signIn.pendingSignup?.channel, SignupChannel.phone);
      expect(signIn.pendingSignup?.destination, '254700000000');
    });

    test('MFA expiry code survives repository failure mapping', () async {
      remote.verifyMfaError = ValidationException(
        'This verification step has expired.',
        code: 'mfa_expired',
      );

      final result = await repository.verifyMfa(
        mfaToken: 'mfa-token',
        code: '123456',
      );
      final failure = result.fold(
        (value) => value,
        (_) => throw StateError('Expected failure'),
      );

      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).code, 'mfa_expired');
    });

    test(
      'trusted signup stores tokens and never returns an OTP step',
      () async {
        remote.signupResponse = const SignupPendingModel(
          nextStep: 'signed_in',
          access: 'access-token',
          refresh: 'refresh-token',
          user: UserModel(id: 'user-1', phone: '254700000000'),
        );

        final result = await repository.signUp(_signupRequest());
        final signup = result.fold(
          (failure) => throw failure,
          (value) => value,
        );

        expect(signup.session, isNotNull);
        expect(signup.pending, isNull);
        expect(local.savedAccess, 'access-token');
        expect(local.savedRefresh, 'refresh-token');
      },
    );

    test(
      'OTP signup returns the server channel without storing tokens',
      () async {
        remote.signupResponse = const SignupPendingModel(
          nextStep: 'otp',
          channel: 'sms',
          destination: '2547******00',
        );

        final result = await repository.signUp(_signupRequest());
        final signup = result.fold(
          (failure) => throw failure,
          (value) => value,
        );

        expect(signup.session, isNull);
        expect(signup.pending?.channel, SignupChannel.phone);
        expect(signup.pending?.destination, '2547******00');
        expect(local.savedAccess, isNull);
      },
    );

    test('incomplete trusted-signup response is rejected', () async {
      remote.signupResponse = const SignupPendingModel(nextStep: 'signed_in');

      final result = await repository.signUp(_signupRequest());
      final failure = result.fold(
        (value) => value,
        (_) => throw StateError('Expected failure'),
      );

      expect(failure, isA<GeneralFailure>());
      expect(
        (failure as GeneralFailure).error,
        'Signup response was incomplete',
      );
    });

    test('password-reset delivery channel reaches the remote source', () async {
      await repository.requestPasswordReset(
        identifier: '254700000000',
        channel: 'sms',
      );

      expect(remote.resetIdentifier, '254700000000');
      expect(remote.resetChannel, 'sms');
    });

    test(
      'signout clears local auth even when remote revocation fails',
      () async {
        local.refreshToken = 'refresh-token';
        remote.logoutError = NetworkException('offline');

        final result = await repository.signOut();

        expect(result.isRight(), isTrue);
        expect(local.clearCount, 1);
      },
    );

    test(
      'invalid refresh clears auth but a network failure preserves it',
      () async {
        local.refreshToken = 'refresh-token';
        remote.refreshError = ValidationException('Invalid refresh token');

        final invalid = await repository.refreshToken();

        expect(invalid.fold((f) => f, (_) => null), isA<UnauthorizedFailure>());
        expect(local.clearCount, 1);

        local.clearCount = 0;
        remote.refreshError = NetworkException('offline');
        final offline = await repository.refreshToken();

        expect(offline.fold((f) => f, (_) => null), isA<NetworkFailure>());
        expect(local.clearCount, 0);
      },
    );
  });

  group('auth bloc contract', () {
    late _FakeRemote remote;
    late _FakeLocal local;
    late AuthRepositoryImpl repository;
    late AuthBloc bloc;

    setUp(() {
      remote = _FakeRemote();
      local = _FakeLocal();
      repository = AuthRepositoryImpl(remote, local);
      bloc = _authBloc(repository);
    });

    tearDown(() => bloc.close());

    test('login confirmation error routes to the OTP state', () async {
      remote.loginError = ValidationException(
        'Confirm your email.',
        code: 'email_not_confirmed',
        details: const {'email': 'member@example.com'},
      );
      final next = bloc.stream.firstWhere(
        (state) => state.status == AuthStatus.awaitingSignupConfirmation,
      );

      bloc.add(
        const SignInEvent(
          identifier: 'member@example.com',
          password: 'legacy-password',
        ),
      );
      final state = await next;

      expect(state.pendingSignup?.channel, SignupChannel.email);
      expect(state.pendingSignup?.destination, 'member@example.com');
      expect(state.errorMessage, isNull);
    });

    test('expired MFA clears the challenge and returns mfaExpired', () async {
      remote.loginResponse = const {
        'mfa_required': true,
        'mfa_token': 'mfa-token',
      };
      final challenged = bloc.stream.firstWhere(
        (state) => state.status == AuthStatus.mfaRequired,
      );
      bloc.add(
        const SignInEvent(identifier: 'member@example.com', password: '123456'),
      );
      await challenged;

      remote.verifyMfaError = ValidationException(
        'This verification step has expired.',
        code: 'mfa_expired',
      );
      final expired = bloc.stream.firstWhere(
        (state) => state.status == AuthStatus.mfaExpired,
      );
      bloc.add(const VerifyMfaEvent(value: '123456'));
      final state = await expired;

      expect(state.mfaToken, isNull);
      expect(state.errorMessage, contains('expired'));
    });

    testWidgets('MFA dialog enforces exact authenticator and backup formats', (
      tester,
    ) async {
      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const MaterialApp(
            home: Scaffold(body: MfaVerificationDialog()),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '12345');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(find.text('Enter the 6-digit code.'), findsOneWidget);

      await tester.tap(find.text('auth.mfaUseBackup'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'ABCDEF1234');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(
        find.text('Enter a valid 10-character backup code.'),
        findsOneWidget,
      );
    });
  });
}

AuthBloc _authBloc(AuthRepositoryImpl repository) => AuthBloc(
  signInUseCase: SignInUseCase(repository),
  signUpUseCase: SignUpUseCase(repository),
  confirmSignupEmailUseCase: ConfirmSignupEmailUseCase(repository),
  confirmSignupPhoneUseCase: ConfirmSignupPhoneUseCase(repository),
  resendSignupEmailUseCase: ResendSignupEmailUseCase(repository),
  resendSignupPhoneUseCase: ResendSignupPhoneUseCase(repository),
  signOutUseCase: SignOutUseCase(repository),
  requestPasswordResetUseCase: RequestPasswordResetUseCase(repository),
  confirmPasswordResetUseCase: ConfirmPasswordResetUseCase(repository),
  verifyIdentityUseCase: VerifyIdentityUseCase(repository),
  verifyMfaUseCase: VerifyMfaUseCase(repository),
);

SignupRequestModel _signupRequest() => const SignupRequestModel(
  phone: '254700000000',
  password: '123456',
  county: 'Nairobi',
  subCountyId: 1,
  constituencyId: 2,
  wardId: 3,
  identityVerificationId: 'verification-id',
  acceptedTerms: true,
);

class _FakeRemote implements AuthRemoteDataSource {
  Object? loginError;
  Map<String, dynamic> loginResponse = const {
    'access': 'access-token',
    'refresh': 'refresh-token',
    'user': {'id': 'user-1'},
  };
  Object? verifyMfaError;
  Object? refreshError;
  Object? logoutError;
  SignupPendingModel signupResponse = const SignupPendingModel(
    nextStep: 'otp',
    channel: 'email',
    destination: 'member@example.com',
  );
  String? resetIdentifier;
  String? resetChannel;

  @override
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    if (loginError case final error?) throw error;
    return loginResponse;
  }

  @override
  Future<SignupPendingModel> signup(SignupRequestModel req) async =>
      signupResponse;

  @override
  Future<AuthSessionModel> verifyMfa({
    required String mfaToken,
    String? code,
    String? backupCode,
  }) async {
    if (verifyMfaError case final error?) throw error;
    return _session;
  }

  @override
  Future<AuthSessionModel> refresh(String refreshToken) async {
    if (refreshError case final error?) throw error;
    return _session;
  }

  @override
  Future<void> requestPasswordReset({
    required String identifier,
    String? channel,
  }) async {
    resetIdentifier = identifier;
    resetChannel = channel;
  }

  @override
  Future<void> logout({required String refresh}) async {
    if (logoutError case final error?) throw error;
  }

  @override
  Future<void> logoutAll({required String refresh}) => logout(refresh: refresh);

  @override
  Future<AuthSessionModel> confirmSignupEmail({
    required String email,
    required String code,
  }) async => _session;

  @override
  Future<AuthSessionModel> confirmSignupPhone({
    required String phone,
    required String code,
  }) async => _session;

  @override
  Future<void> resendSignupEmail({required String email}) async {}

  @override
  Future<void> resendSignupPhone({required String phone}) async {}

  @override
  Future<VerifiedIdentityModel> verifyIdentity({
    required String idType,
    required String idNumber,
  }) async => const VerifiedIdentityModel(
    verificationId: 'verification-id',
    firstName: 'Member',
    lastName: 'User',
  );

  @override
  Future<void> confirmPasswordReset({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {}
}

const _session = AuthSessionModel(
  access: 'access-token',
  refresh: 'refresh-token',
  user: UserModel(id: 'user-1'),
);

class _FakeLocal implements AuthLocalDataSource {
  String? savedAccess;
  String? savedRefresh;
  String? refreshToken;
  int clearCount = 0;

  @override
  bool get isLoggedIn => savedAccess != null;

  @override
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    savedAccess = access;
    savedRefresh = refresh;
  }

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> clearAuthData() async {
    clearCount++;
    savedAccess = null;
    savedRefresh = null;
  }

  @override
  Future<String?> getAccessToken() async => savedAccess;

  @override
  Future<UserModel?> getUser() async => null;

  @override
  Future<void> saveUser(UserModel user) async {}

  @override
  Future<void> savePendingSignup(SignupPendingEntity pending) async {}

  @override
  Future<SignupPendingEntity?> getPendingSignup() async => null;

  @override
  Future<void> clearPendingSignup() async {}
}
