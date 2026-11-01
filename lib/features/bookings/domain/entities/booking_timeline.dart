import 'package:equatable/equatable.dart';
import 'service_booking.dart';

class BookingTimeline {
  final BookingSummary booking;
  final List<TimelineEntry> timeline;
  final bool isOwner;

  const BookingTimeline({
    required this.booking,
    required this.timeline,
    this.isOwner = true,
  });
}

class TimelineEntry extends Equatable {
  final String type;
  final DateTime? createdAt;
  final Map<String, dynamic> data;

  const TimelineEntry({
    required this.type,
    this.createdAt,
    this.data = const {},
  });

  String? get eventType => data['event_type']?.toString();
  String? get text =>
      data['text']?.toString() ??
      data['note']?.toString() ??
      data['description']?.toString();

  @override
  List<Object?> get props => [type, createdAt, data];
}
