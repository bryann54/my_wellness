import 'package:flutter_test/flutter_test.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/vitals/data/models/appointment_model.dart';
import 'package:my_wellness/features/appointments/presentation/pages/appointments_screen.dart';

void main() {
  group('appointment web contract', () {
    test('accepts an appointment without an optional time', () {
      final model = AppointmentModel.fromJson({
        'id': 'appointment-1',
        'condition': 'other',
        'clinic_name': 'General medical clinic',
        'appointment_date': '2026-11-09',
        'appointment_time': null,
        'notes': 'My Wellness Clinic',
        'source': 'manual',
        'booking': null,
        'created_at': '2026-11-07T10:00:00Z',
      });

      expect(model.appointmentTime, isNull);
      expect(model.toEntity().appointmentTime, isNull);
      expect(model.clinicName, 'General medical clinic');
      expect(model.notes, 'My Wellness Clinic');
    });

    test('parses a date when optional appointment time is absent', () {
      final value = parseDateTime('2026-11-09', null);

      expect(value, DateTime(2026, 11, 9));
    });

    test('empty state owns the only booking CTA', () {
      expect(
        shouldShowAppointmentsFab(hasAppointments: false, hasBookings: false),
        isFalse,
      );
      expect(
        shouldShowAppointmentsFab(hasAppointments: true, hasBookings: false),
        isTrue,
      );
      expect(
        shouldShowAppointmentsFab(hasAppointments: false, hasBookings: true),
        isTrue,
      );
    });
  });
}
