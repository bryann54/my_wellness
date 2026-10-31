import 'package:my_wellness/features/notifications/domain/entities/notification_preference.dart';

class NotificationPreferenceModel extends NotificationPreference {
  const NotificationPreferenceModel({
    required super.category,
    required super.label,
    required super.required,
    required super.push,
    required super.email,
    required super.sms,
    required super.whatsapp,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) =>
      NotificationPreferenceModel(
        category: json['category'] as String,
        label: json['label'] as String? ?? json['category'] as String,
        required: json['required'] as bool? ?? false,
        push: json['push'] as bool? ?? true,
        email: json['email'] as bool? ?? true,
        sms: json['sms'] as bool? ?? true,
        whatsapp: json['whatsapp'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
    'category': category,
    'push': push,
    'email': email,
    'sms': sms,
    'whatsapp': whatsapp,
  };
}
