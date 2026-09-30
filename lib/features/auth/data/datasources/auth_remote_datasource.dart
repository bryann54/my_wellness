import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/auth/data/models/auth_session_model.dart';
import 'package:my_wellness/features/auth/data/models/signup_pending_model.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/data/models/verified_identity_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String identifier,
    required String password,
  });

  Future<SignupPendingModel> signup(SignupRequestModel req);

  Future<void> confirmSignupEmail({
    required String email,
    required String code,
  });
  Future<void> confirmSignupPhone({
    required String phone,
    required String code,
  });
  Future<void> resendSignupEmail({required String email});
  Future<void> resendSignupPhone({required String phone});

  Future<AuthSessionModel> refresh(String refreshToken);

  /// The server requires the refresh token so it can revoke the session.
  Future<void> logout({required String refresh});
  Future<void> logoutAll({required String refresh});

  Future<VerifiedIdentityModel> verifyIdentity({
    required String idType,
    required String idNumber,
  });
  Future<void> requestPasswordReset({required String identifier});
  Future<void> confirmPasswordReset({
    required String identifier,
    required String code,
    required String newPassword,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthSessionModel> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      url: ApiEndpoints.authLogin,
      payload: {'identifier': identifier, 'password': password},
    );
    return AuthSessionModel.fromJson(response);
  }

  @override
  Future<SignupPendingModel> signup(SignupRequestModel req) async {
    final response = await _client.post<Map<String, dynamic>>(
      url: ApiEndpoints.authSignup,
      payload: req.toJson(),
    );
    return SignupPendingModel.fromJson(response);
  }

  @override
  Future<VerifiedIdentityModel> verifyIdentity({
    required String idType,
    required String idNumber,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      url: ApiEndpoints.authKyc,
      payload: {'id_type': idType, 'id_number': idNumber},
    );
    return VerifiedIdentityModel.fromJson(response);
  }

  @override
  Future<void> confirmSignupEmail({
    required String email,
    required String code,
  }) async {
    await _client.post(
      url: ApiEndpoints.authSignupConfirm,
      payload: {'email': email, 'code': code},
    );
  }

  @override
  Future<void> confirmSignupPhone({
    required String phone,
    required String code,
  }) async {
    await _client.post(
      url: ApiEndpoints.authSignupPhoneConfirm,
      payload: {'phone': phone, 'code': code},
    );
  }

  @override
  Future<void> resendSignupEmail({required String email}) async {
    await _client.post(
      url: ApiEndpoints.authSignupResend,
      payload: {'email': email},
    );
  }

  @override
  Future<void> resendSignupPhone({required String phone}) async {
    await _client.post(
      url: ApiEndpoints.authSignupPhoneResend,
      payload: {'phone': phone},
    );
  }

  @override
  Future<AuthSessionModel> refresh(String refreshToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      url: ApiEndpoints.authTokenRefresh,
      payload: {'refresh': refreshToken},
    );
    return AuthSessionModel.fromJson(response);
  }

  @override
  Future<void> logout({required String refresh}) async {
    await _client.post(
      url: ApiEndpoints.authLogout,
      payload: {'refresh': refresh},
    );
  }

  @override
  Future<void> logoutAll({required String refresh}) async {
    await _client.post(
      url: ApiEndpoints.authLogoutAll,
      payload: {'refresh': refresh},
    );
  }

  @override
  Future<void> requestPasswordReset({required String identifier}) async {
    await _client.post(
      url: ApiEndpoints.authPasswordResetRequest,
      payload: {'identifier': identifier},
    );
  }

  @override
  Future<void> confirmPasswordReset({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    await _client.post(
      url: ApiEndpoints.authPasswordResetConfirm,
      payload: {
        'identifier': identifier,
        'code': code,
        'new_password': newPassword,
      },
    );
  }
}
