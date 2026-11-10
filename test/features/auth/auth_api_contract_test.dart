import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/interceptors/auth_interceptor.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:my_wellness/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/data/models/user_model.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';

void main() {
  group('auth API contract', () {
    test('preserves structured confirmation errors for OTP routing', () async {
      final fixture = await _ServerFixture.start(
        statusCode: 400,
        response: const {
          'error': {
            'code': 'email_not_confirmed',
            'detail': {
              'message': 'Confirm your email address.',
              'email': 'member@example.com',
            },
          },
        },
      );
      addTearDown(fixture.close);

      try {
        await fixture.client.post<Map<String, dynamic>>(
          url: '/api/auth/login',
          payload: const {
            'identifier': 'member@example.com',
            'password': 'legacy-password',
          },
          options: ApiClient.open,
        );
        fail('Expected a ValidationException');
      } on ValidationException catch (error) {
        expect(error.code, 'email_not_confirmed');
        expect(error.message, 'Confirm your email address.');
        expect(error.details?['email'], 'member@example.com');
      }
    });

    test('signup sends the exact mobile contract payload', () async {
      final fixture = await _ServerFixture.start(
        response: const {
          'next_step': 'otp',
          'channel': 'email',
          'destination': 'member@example.com',
        },
      );
      addTearDown(fixture.close);
      final remote = AuthRemoteDataSourceImpl(fixture.client);

      await remote.signup(
        const SignupRequestModel(
          email: 'member@example.com',
          password: '123456',
          nationalIdNumber: '12345678',
          county: 'Nairobi',
          subCountyId: 1,
          constituencyId: 2,
          wardId: 3,
          identityVerificationId: 'verification-id',
          acceptedTerms: true,
        ),
      );
      final request = await fixture.request;

      expect(request.path, '/api/auth/signup/');
      expect(request.json['password'], '123456');
      expect(request.json['accepted_terms'], isTrue);
      expect(request.json['identity_verification_id'], 'verification-id');
      expect(request.json['ward'], 3);
      expect(request.json, isNot(contains('subdomain')));
    });

    test(
      'password reset request forwards the optional delivery channel',
      () async {
        final fixture = await _ServerFixture.start(response: const {});
        addTearDown(fixture.close);
        final remote = AuthRemoteDataSourceImpl(fixture.client);

        await remote.requestPasswordReset(
          identifier: '254700000000',
          channel: 'sms',
        );
        final request = await fixture.request;

        expect(request.path, '/api/auth/password-reset/request/');
        expect(request.json, {'identifier': '254700000000', 'channel': 'sms'});
      },
    );

    test(
      'password reset confirmation sends code and six-digit passcode',
      () async {
        final fixture = await _ServerFixture.start(response: const {});
        addTearDown(fixture.close);
        final remote = AuthRemoteDataSourceImpl(fixture.client);

        await remote.confirmPasswordReset(
          identifier: 'member@example.com',
          code: '654321',
          newPassword: '123456',
        );
        final request = await fixture.request;

        expect(request.path, '/api/auth/password-reset/confirm/');
        expect(request.json, {
          'identifier': 'member@example.com',
          'code': '654321',
          'new_password': '123456',
        });
      },
    );
  });
}

class _CapturedRequest {
  const _CapturedRequest({required this.path, required this.json});

  final String path;
  final Map<String, dynamic> json;
}

class _ServerFixture {
  _ServerFixture._({
    required this.server,
    required this.client,
    required this.request,
  });

  final HttpServer server;
  final ApiClient client;
  final Future<_CapturedRequest> request;

  static Future<_ServerFixture> start({
    required Map<String, dynamic> response,
    int statusCode = 200,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final requestCompleter = Completer<_CapturedRequest>();
    server.listen((request) async {
      final raw = await utf8.decoder.bind(request).join();
      final body = raw.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(raw) as Map<String, dynamic>;
      if (!requestCompleter.isCompleted) {
        requestCompleter.complete(
          _CapturedRequest(path: request.uri.path, json: body),
        );
      }
      request.response.statusCode = statusCode;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(response));
      await request.response.close();
    });

    final baseUrl = 'http://${server.address.host}:${server.port}';
    final local = _FakeAuthLocalDataSource();
    final client = ApiClient(baseUrl, AuthInterceptor(local, baseUrl));
    return _ServerFixture._(
      server: server,
      client: client,
      request: requestCompleter.future,
    );
  }

  Future<void> close() => server.close(force: true);
}

class _FakeAuthLocalDataSource implements AuthLocalDataSource {
  @override
  bool get isLoggedIn => false;

  @override
  Future<void> clearAuthData() async {}

  @override
  Future<void> clearPendingSignup() async {}

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<SignupPendingEntity?> getPendingSignup() async => null;

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<UserModel?> getUser() async => null;

  @override
  Future<void> savePendingSignup(SignupPendingEntity pending) async {}

  @override
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {}

  @override
  Future<void> saveUser(UserModel user) async {}
}
