import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';

import '../models/booking_timeline_model.dart';
import '../models/facility_model.dart';
import '../models/referral_model.dart';
import '../models/service_booking_model.dart';

typedef BookingsPageDto = ({
  List<ServiceBookingModel> items,
  String? nextCursor,
});

abstract class BookingsRemoteDataSource {
  Future<ServiceBookingModel> createBooking(Map<String, dynamic> payload);
  Future<BookingsPageDto> getMyBookings({String? cursor});
  Future<BookingTimelineModel> getBookingTimeline(String bookingId);
  Future<ServiceBookingModel> completeBooking(String bookingId);

  Future<List<FacilityModel>> matchFacilities({
    required String serviceType,
    double? userLat,
    double? userLng,
    String? town,
    String? county,
  });
  Future<List<FacilityModel>> searchFacilities(String query);
  Future<FacilityModel> createFacility(Map<String, dynamic> payload);

  Future<List<ReferralModel>> getMyReferrals();
  Future<ReferralModel> getReferral(String id);
  Future<ReferralModel> generateReferralFromSession(
    String sessionId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  });
  Future<ReferralModel> generateReferralFromBpReading(
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  });
  Future<ReferralModel> generateReferralFromBsReading(
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  });

  Future<Map<String, dynamic>> stkPush(Map<String, dynamic> payload);
}

@LazySingleton(as: BookingsRemoteDataSource)
class BookingsRemoteDataSourceImpl implements BookingsRemoteDataSource {
  final ApiClient _api;
  BookingsRemoteDataSourceImpl(this._api);

  @override
  Future<ServiceBookingModel> createBooking(
    Map<String, dynamic> payload,
  ) async {
    final json = await _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.bookingsCreate,
      payload: payload,
      options: ApiClient.protected,
    );
    return ServiceBookingModel.fromJson(json);
  }

  @override
  Future<BookingsPageDto> getMyBookings({String? cursor}) async {
    final json = await _api.get<Map<String, dynamic>>(
      url: ApiEndpoints.bookingsMine,
      query: {'cursor': ?cursor},
      options: ApiClient.protected,
    );
    final items =
        (json['results'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(ServiceBookingModel.fromJson)
            .toList(growable: false) ??
        const <ServiceBookingModel>[];
    final next = json['next'];
    final nextCursor = next is String && next.isNotEmpty
        ? Uri.tryParse(next)?.queryParameters['cursor']
        : null;
    return (items: items, nextCursor: nextCursor);
  }

  @override
  Future<BookingTimelineModel> getBookingTimeline(String bookingId) async {
    final json = await _api.get<Map<String, dynamic>>(
      url: ApiEndpoints.bookingTimeline(bookingId),
      options: ApiClient.protected,
    );
    return BookingTimelineModel.fromJson(json);
  }

  @override
  Future<ServiceBookingModel> completeBooking(String bookingId) async {
    final json = await _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.bookingComplete(bookingId),
      payload: const <String, dynamic>{},
      options: ApiClient.protected,
    );
    return ServiceBookingModel.fromJson(json);
  }

  @override
  Future<List<FacilityModel>> matchFacilities({
    required String serviceType,
    double? userLat,
    double? userLng,
    String? town,
    String? county,
  }) async {
    final list = await _api.get<List<dynamic>>(
      url: ApiEndpoints.facilitiesMatch,
      query: {
        'service_type': serviceType,
        'user_lat': ?userLat,
        'user_lng': ?userLng,
        'town': ?town,
        'county': ?county,
      },
      options: ApiClient.protected,
    );
    return list
        .whereType<Map<String, dynamic>>()
        .map(FacilityModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<FacilityModel>> searchFacilities(String query) async {
    final list = await _api.get<List<dynamic>>(
      url: ApiEndpoints.facilitiesPatientSearch,
      query: {'q': query},
      options: ApiClient.protected,
    );
    return list
        .whereType<Map<String, dynamic>>()
        .map(FacilityModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<FacilityModel> createFacility(Map<String, dynamic> payload) async {
    final json = await _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.facilitiesCreate,
      payload: payload,
      options: ApiClient.protected,
    );
    return FacilityModel.fromJson(json);
  }

  @override
  Future<List<ReferralModel>> getMyReferrals() async {
    final list = await _api.get<List<dynamic>>(
      url: ApiEndpoints.referralsMine,
      options: ApiClient.protected,
    );
    return list
        .whereType<Map<String, dynamic>>()
        .map(ReferralModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<ReferralModel> getReferral(String id) async {
    final json = await _api.get<Map<String, dynamic>>(
      url: ApiEndpoints.referralDetail(id),
      options: ApiClient.protected,
    );
    return ReferralModel.fromJson(json);
  }

  @override
  Future<ReferralModel> generateReferralFromSession(
    String sessionId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  }) => _generate(
    ApiEndpoints.referralFromSession(sessionId),
    userLat: userLat,
    userLng: userLng,
    facilityId: facilityId,
  );

  @override
  Future<ReferralModel> generateReferralFromBpReading(
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  }) => _generate(
    ApiEndpoints.referralFromBpReading(readingId),
    userLat: userLat,
    userLng: userLng,
    facilityId: facilityId,
  );

  @override
  Future<ReferralModel> generateReferralFromBsReading(
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  }) => _generate(
    ApiEndpoints.referralFromBsReading(readingId),
    userLat: userLat,
    userLng: userLng,
    facilityId: facilityId,
  );

  Future<ReferralModel> _generate(
    String url, {
    double? userLat,
    double? userLng,
    String? facilityId,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      url: url,
      payload: {
        'user_lat': ?userLat,
        'user_lng': ?userLng,
        'facility_id': ?facilityId,
      },
      options: ApiClient.protected,
    );
    return ReferralModel.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> stkPush(Map<String, dynamic> payload) {
    return _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.paymentsStkPush,
      payload: payload,
      options: ApiClient.protected,
    );
  }
}
