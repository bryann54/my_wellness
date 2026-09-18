// lib/features/account/data/datasources/account_remote_datasource.dart

import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/account/data/models/health_profile_model.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';

abstract class AccountRemoteDataSource {
  Future<HealthProfile> getProfile();

  /// PATCH the current user's health profile. The server identifies the
  /// user from the auth token — do not pass a user id here.
  Future<HealthProfile> updateProfile(Map<String, dynamic> data);

  /// Schedule the account for deletion (grace-period flow).
  Future<void> requestAccountDeletion();

  /// Cancel a pending account deletion.
  Future<void> cancelAccountDeletion();

  /// Ask the server to export the user's data.
  Future<void> exportData();
}

@LazySingleton(as: AccountRemoteDataSource)
class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final ApiClient _apiClient;

  AccountRemoteDataSourceImpl(this._apiClient);

  @override
  Future<HealthProfile> getProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      url: ApiEndpoints.healthProfile,
      options: ApiClient.protected,
    );
    return HealthProfileModel.fromJson(response).toEntity();
  }

  @override
  Future<HealthProfile> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      url: ApiEndpoints.healthProfile,
      payload: data,
      options: ApiClient.protected,
    );
    return HealthProfileModel.fromJson(response).toEntity();
  }

  @override
  Future<void> requestAccountDeletion() async {
    await _apiClient.post(
      url: ApiEndpoints.deleteAccount,
      options: ApiClient.protected,
    );
  }

  @override
  Future<void> cancelAccountDeletion() async {
    await _apiClient.post(
      url: ApiEndpoints.deleteAccountCancel,
      options: ApiClient.protected,
    );
  }

  @override
  Future<void> exportData() async {
    await _apiClient.post(
      url: ApiEndpoints.exportData,
      options: ApiClient.protected,
    );
  }
}
