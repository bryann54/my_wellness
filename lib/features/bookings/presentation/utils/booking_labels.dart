import 'package:flutter/widgets.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';

String bookingServiceLabel(
  BuildContext context,
  ServiceType type,
  String fallback, {
  String clinicianTier = '',
}) {
  String t(String key) => AppLocalizations.getString(context, key);
  return switch (type) {
    ServiceType.navigator => t('bookings.service.navigator'),
    ServiceType.screening => t('bookings.service.screening'),
    ServiceType.checkup => t('bookings.service.checkup'),
    ServiceType.dnaTest => t('bookings.service.dnaTest'),
    ServiceType.secondOpinion => switch (clinicianTier) {
      'gp' =>
        '${t('bookings.service.secondOpinion')} — ${t('bookings.form.clinicianGp')}',
      'consultant' =>
        '${t('bookings.service.secondOpinion')} — ${t('bookings.form.clinicianConsultant')}',
      _ => t('bookings.service.secondOpinion'),
    },
    ServiceType.referralVisit || ServiceType.unknown => fallback,
  };
}

String formatKes(BuildContext context, int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return AppLocalizations.t(context, 'bookings.priceKes', {
    'amount': buffer.toString(),
  });
}

String formatStamp(DateTime value) {
  final d = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}
