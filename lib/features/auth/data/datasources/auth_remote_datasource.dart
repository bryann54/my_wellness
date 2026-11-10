import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/auth/data/models/auth_session_model.dart';
import 'package:my_wellness/features/auth/data/models/signup_pending_model.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/data/models/verified_identity_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  });

  Future<SignupPendingModel> signup(SignupRequestModel req);

  Future<AuthSessionModel> confirmSignupEmail({
    required String email,
    required String code,
  });
  Future<AuthSessionModel> confirmSignupPhone({
    required String phone,
    required String code,
  });
  Future<void> resendSignupEmail({required String email});
  Future<void> resendSignupPhone({required String phone});

  Future<AuthSessionModel> refresh(String refreshToken);
  Future<AuthSessionModel> verifyMfa({
    required String mfaToken,
    String? code,
    String? backupCode,
  });

  /// The server requires the refresh token so it can revoke the session.
  Future<void> logout({required String refresh});
  Future<void> logoutAll({required String refresh});

  Future<VerifiedIdentityModel> verifyIdentity({
    required String idType,
    required String idNumber,
  });
  Future<void> requestPasswordReset({
    required String identifier,
    String? channel,
  });
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
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      url: ApiEndpoints.authLogin,
      payload: {'identifier': identifier, 'password': password},
      options: ApiClient.open,
    );
    return response;
  }

  @override
  Future<AuthSessionModel> verifyMfa({
    required String mfaToken,
    String? code,
    String? backupCode,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      url: ApiEndpoints.mfaVerify,
      payload: {
        'mfa_token': mfaToken,
        if (code != null) 'code': code,
        if (backupCode != null) 'backup_code': backupCode,
      },
      options: ApiClient.open,
    );
    return AuthSessionModel.fromJson(response);
  }

  @override
  Future<SignupPendingModel> signup(SignupRequestModel req) async {
    final response = await _client.post<Map<String, dynamic>>(
      url: ApiEndpoints.authSignup,
      payload: req.toJson(),
      options: ApiClient.open,
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
      options: ApiClient.open.copyWith(
        sendTimeout: const Duration(seconds: 65),
        receiveTimeout: const Duration(seconds: 65),
      ),
    );
    return VerifiedIdentityModel.fromJson(response);
  }

  @override
  Future<AuthSessionModel> confirmSignupEmail({
    required String email,
    required String code,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      url: ApiEndpoints.authSignupConfirm,
      payload: {'email': email, 'code': code},
      options: ApiClient.open,
    );
    return AuthSessionModel.fromJson(response);
  }

  @override
  Future<AuthSessionModel> confirmSignupPhone({
    required String phone,
    required String code,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      url: ApiEndpoints.authSignupPhoneConfirm,
      payload: {'phone': phone, 'code': code},
      options: ApiClient.open,
    );
    return AuthSessionModel.fromJson(response);
  }

  @override
  Future<void> resendSignupEmail({required String email}) async {
    await _client.post(
      url: ApiEndpoints.authSignupResend,
      payload: {'email': email},
      options: ApiClient.open,
    );
  }

  @override
  Future<void> resendSignupPhone({required String phone}) async {
    await _client.post(
      url: ApiEndpoints.authSignupPhoneResend,
      payload: {'phone': phone},
      options: ApiClient.open,
    );
  }

  @override
  Future<AuthSessionModel> refresh(String refreshToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      url: ApiEndpoints.authTokenRefresh,
      payload: {'refresh': refreshToken},
      options: ApiClient.open,
    );
    return AuthSessionModel.fromJson(response);
  }

  @override
  Future<void> logout({required String refresh}) async {
    await _client.post(
      url: ApiEndpoints.authLogout,
      payload: {'refresh': refresh},
      options: ApiClient.open,
    );
  }

  @override
  Future<void> logoutAll({required String refresh}) async {
    await _client.post(
      url: ApiEndpoints.authLogoutAll,
      payload: {'refresh': refresh},
      options: ApiClient.open,
    );
  }

  @override
  Future<void> requestPasswordReset({
    required String identifier,
    String? channel,
  }) async {
    final payload = <String, dynamic>{'identifier': identifier};
    if (channel != null) payload['channel'] = channel;
    await _client.post(
      url: ApiEndpoints.authPasswordResetRequest,
      payload: payload,
      options: ApiClient.open,
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
      options: ApiClient.open,
    );
  }
}
