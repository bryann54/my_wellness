import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/geography/data/models/constituency_model.dart';
import 'package:my_wellness/features/geography/data/models/county_model.dart';
import 'package:my_wellness/features/geography/data/models/sub_county_model.dart';
import 'package:my_wellness/features/geography/data/models/ward_model.dart';
import 'package:my_wellness/features/geography/domain/entities/constituency.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/domain/entities/ward.dart';

abstract class GeographyRemoteDataSource {
  Future<List<County>> getCounties();
  Future<List<SubCounty>> getSubCounties();
  Future<List<Constituency>> getConstituencies();
  Future<List<Ward>> getWards();
}

@LazySingleton(as: GeographyRemoteDataSource)
class GeographyRemoteDataSourceImpl implements GeographyRemoteDataSource {
  final ApiClient _client;

  GeographyRemoteDataSourceImpl(this._client);

  @override
  Future<List<County>> getCounties() async {
    final response = await _client.get<List<dynamic>>(
      url: ApiEndpoints.geographyCounties,
      options: ApiClient.protected,
    );
    return response
        .map((e) => CountyModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<SubCounty>> getSubCounties() async {
    final response = await _client.get<List<dynamic>>(
      url: ApiEndpoints.geographySubCounties,
      options: ApiClient.protected,
    );
    return response
        .map(
          (e) => SubCountyModel.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<List<Constituency>> getConstituencies() async {
    final response = await _client.get<List<dynamic>>(
      url: ApiEndpoints.geographyConstituencies,
      options: ApiClient.protected,
    );
    return response
        .map(
          (e) =>
              ConstituencyModel.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<List<Ward>> getWards() async {
    final response = await _client.get<List<dynamic>>(
      url: ApiEndpoints.geographyWards,
      options: ApiClient.protected,
    );
    return response
        .map((e) => WardModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }
}
