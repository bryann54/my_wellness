// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_timeline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingTimelineModel _$BookingTimelineModelFromJson(
  Map<String, dynamic> json,
) => BookingTimelineModel(
  booking: BookingSummaryModel.fromJson(
    json['booking'] as Map<String, dynamic>,
  ),
  timeline: (json['timeline'] as List<dynamic>)
      .map((e) => TimelineEntryModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  isOwner: json['is_owner'] as bool? ?? true,
);

Map<String, dynamic> _$BookingTimelineModelToJson(
  BookingTimelineModel instance,
) => <String, dynamic>{
  'booking': instance.booking.toJson(),
  'timeline': instance.timeline.map((e) => e.toJson()).toList(),
  'is_owner': instance.isOwner,
};

TimelineEntryModel _$TimelineEntryModelFromJson(Map<String, dynamic> json) =>
    TimelineEntryModel(
      type: json['type'] as String,
      createdAt: _dateOrNull(json['created_at']),
      data: json['data'] as Map<String, dynamic>? ?? {},
    );

Map<String, dynamic> _$TimelineEntryModelToJson(TimelineEntryModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'created_at': instance.createdAt?.toIso8601String(),
      'data': instance.data,
    };
