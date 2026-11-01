import 'package:json_annotation/json_annotation.dart';
import 'service_booking_model.dart';

part 'booking_timeline_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class BookingTimelineModel {
  final BookingSummaryModel booking;
  final List<TimelineEntryModel> timeline;
  @JsonKey(defaultValue: true)
  final bool isOwner;

  const BookingTimelineModel({
    required this.booking,
    required this.timeline,
    this.isOwner = true,
  });

  factory BookingTimelineModel.fromJson(Map<String, dynamic> json) {
    final viewer =
        (json['viewer'] as Map?)?.cast<String, dynamic>() ?? const {};
    final copy = Map<String, dynamic>.of(json)
      ..['is_owner'] = viewer['is_owner'] == true;
    return _$BookingTimelineModelFromJson(copy);
  }

  Map<String, dynamic> toJson() => _$BookingTimelineModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class TimelineEntryModel {
  final String type;
  @JsonKey(fromJson: _dateOrNull)
  final DateTime? createdAt;
  @JsonKey(defaultValue: <String, dynamic>{})
  final Map<String, dynamic> data;

  const TimelineEntryModel({
    required this.type,
    this.createdAt,
    this.data = const {},
  });

  factory TimelineEntryModel.fromJson(Map<String, dynamic> json) =>
      _$TimelineEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineEntryModelToJson(this);
}

DateTime? _dateOrNull(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}
