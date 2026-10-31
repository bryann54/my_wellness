import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/notifications/data/models/notification_preference_model.dart';

abstract class NotificationPreferencesRemoteDataSource {
  Future<List<NotificationPreferenceModel>> getPreferences();
  Future<List<NotificationPreferenceModel>> savePreferences(
    List<NotificationPreferenceModel> preferences,
  );
}

@LazySingleton(as: NotificationPreferencesRemoteDataSource)
class NotificationPreferencesRemoteDataSourceImpl
    implements NotificationPreferencesRemoteDataSource {
  final ApiClient _api;
  NotificationPreferencesRemoteDataSourceImpl(this._api);

  @override
  Future<List<NotificationPreferenceModel>> getPreferences() async {
    final response = await _api.get<List<dynamic>>(
      url: ApiEndpoints.pushPreferences,
      options: ApiClient.protected,
    );
    return response
        .map(
          (row) => NotificationPreferenceModel.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<NotificationPreferenceModel>> savePreferences(
    List<NotificationPreferenceModel> preferences,
  ) async {
    final response = await _api.put<List<dynamic>>(
      url: ApiEndpoints.pushPreferences,
      payload: preferences.map((preference) => preference.toJson()).toList(),
      options: ApiClient.protected,
    );
    return response
        .map(
          (row) => NotificationPreferenceModel.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList(growable: false);
  }
}
