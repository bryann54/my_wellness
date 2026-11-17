import 'package:flutter_test/flutter_test.dart';
import 'package:my_wellness/features/account/data/models/health_profile_model.dart';

void main() {
  group('health profile contract', () {
    test(
      'phone-only and incomplete profiles tolerate nullable display fields',
      () {
        final profile = HealthProfileModel.fromJson(const {
          'email': null,
          'full_name': null,
          'phone': null,
          'gender': null,
          'member_code': null,
          'health_profile_completed': false,
        }).toEntity();

        expect(profile.email, isEmpty);
        expect(profile.fullName, isEmpty);
        expect(profile.phone, isEmpty);
        expect(profile.gender, isEmpty);
        expect(profile.memberCode, isEmpty);
        expect(profile.healthProfileCompleted, isFalse);
      },
    );

    test('string-like profile fields are normalized without unsafe casts', () {
      final profile = HealthProfileModel.fromJson(const {
        'email': 'person@example.com',
        'full_name': 'Person',
        'phone': 254700000000,
        'gender': 'female',
        'member_code': 12345,
      }).toEntity();

      expect(profile.phone, '254700000000');
      expect(profile.memberCode, '12345');
    });

    test('decodes raw account verification and SHA fields', () {
      final profile = HealthProfileModel.fromJson(const {
        'email': 'person@example.com',
        'full_name': 'Person',
        'phone': '+254700000001',
        'account_phone': '+254700000002',
        'country_of_residence': 'KE',
        'email_verified': false,
        'phone_verified': true,
        'pending_contact_verifications': ['email'],
        'gender': 'female',
        'member_code': 'MW-1',
        'sha_number': 'SHA-9',
        'sha_eligibility_checkable': true,
      }).toEntity();

      expect(profile.accountPhone, '+254700000002');
      expect(profile.pendingContactVerifications, ['email']);
      expect(profile.phoneVerified, isTrue);
      expect(profile.shaNumber, 'SHA-9');
      expect(profile.shaEligibilityCheckable, isTrue);
    });
  });
}
