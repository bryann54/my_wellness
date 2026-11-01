import 'package:json_annotation/json_annotation.dart';
import 'facility_model.dart';

part 'service_booking_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class BookingSummaryModel {
  final String id;
  final String status;
  final String serviceLabel;
  final String? preferredDate;
  @JsonKey(fromJson: _dateOrNull)
  final DateTime? checkedInAt;
  @JsonKey(name: 'is_hie_managed', defaultValue: false)
  final bool isHieManaged;
  @JsonKey(name: 'follow_up_to', fromJson: _idOrNull)
  final String? followUpTo;

  const BookingSummaryModel({
    required this.id,
    required this.status,
    required this.serviceLabel,
    this.preferredDate,
    this.checkedInAt,
    this.isHieManaged = false,
    this.followUpTo,
  });

  factory BookingSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$BookingSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingSummaryModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ServiceBookingModel {
  final String id;
  final String serviceType;
  final String serviceLabel;
  @JsonKey(fromJson: _priceToInt)
  final int priceKes;
  final String status;
  final bool requiresScheduling;
  @JsonKey(defaultValue: '')
  final String dnaTestKind;
  @JsonKey(defaultValue: '')
  final String clinicianTier;
  @JsonKey(defaultValue: '')
  final String preferredLawFirm;
  final String? preferredDate;
  @JsonKey(fromJson: _dateOrNull)
  final DateTime? appointmentTime;
  @JsonKey(defaultValue: '')
  final String preferredFacility;
  final FacilityModel? facility;
  @JsonKey(fromJson: _dateOrNull)
  final DateTime? checkedInAt;
  @JsonKey(defaultValue: '')
  final String contactPhone;
  @JsonKey(defaultValue: '')
  final String notes;
  @JsonKey(name: 'follow_up_to', fromJson: _idOrNull)
  final String? followUpTo;
  @JsonKey(name: 'follow_ups', defaultValue: <BookingSummaryModel>[])
  final List<BookingSummaryModel> followUps;
  @JsonKey(fromJson: _dateOrNull)
  final DateTime? createdAt;
  @JsonKey(name: 'is_hie_managed', defaultValue: false)
  final bool isHieManaged;
  @JsonKey(name: 'referral', fromJson: _idOrNull)
  final String? referralId;

  const ServiceBookingModel({
    required this.id,
    required this.serviceType,
    required this.serviceLabel,
    required this.priceKes,
    required this.status,
    required this.requiresScheduling,
    required this.dnaTestKind,
    required this.clinicianTier,
    required this.preferredLawFirm,
    this.preferredDate,
    this.appointmentTime,
    required this.preferredFacility,
    this.facility,
    this.checkedInAt,
    required this.contactPhone,
    required this.notes,
    this.followUpTo,
    this.followUps = const [],
    this.createdAt,
    this.isHieManaged = false,
    this.referralId,
  });

  factory ServiceBookingModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceBookingModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceBookingModelToJson(this);
}

int _priceToInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString().split('.').first) ?? 0;
}

DateTime? _dateOrNull(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

String? _idOrNull(dynamic v) {
  if (v == null) return null;
  if (v is String) return v.isEmpty ? null : v;
  if (v is Map && v['id'] != null) return v['id'].toString();
  return v.toString();
}
