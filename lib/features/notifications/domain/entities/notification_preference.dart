import 'package:equatable/equatable.dart';

class NotificationPreference extends Equatable {
  final String category;
  final String label;
  final bool required;
  final bool push;
  final bool email;
  final bool sms;
  final bool whatsapp;

  const NotificationPreference({
    required this.category,
    required this.label,
    required this.required,
    required this.push,
    required this.email,
    required this.sms,
    required this.whatsapp,
  });

  bool get hasEnabledChannel => push || email || sms || whatsapp;

  NotificationPreference copyWith({
    bool? push,
    bool? email,
    bool? sms,
    bool? whatsapp,
  }) => NotificationPreference(
    category: category,
    label: label,
    required: required,
    push: push ?? this.push,
    email: email ?? this.email,
    sms: sms ?? this.sms,
    whatsapp: whatsapp ?? this.whatsapp,
  );

  @override
  List<Object?> get props => [
    category,
    label,
    required,
    push,
    email,
    sms,
    whatsapp,
  ];
}
