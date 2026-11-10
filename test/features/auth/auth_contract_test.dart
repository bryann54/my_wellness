import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wellness/common/utils/auth_validators.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/auth/data/models/signup_pending_model.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/data/models/verified_identity_model.dart';
import 'package:my_wellness/features/auth/domain/entities/sign_in_result_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_credentials.dart';

void main() {
  group('auth contract', () {
    test('signup sends consent and never sends a subdomain', () {
      const request = SignupRequestModel(
        email: 'member@example.com',
        password: '123456',
        county: 'Nairobi',
        subCountyId: 1,
        constituencyId: 2,
        wardId: 3,
        identityVerificationId: 'verification-id',
        acceptedTerms: true,
      );

      final json = request.toJson();

      expect(json['accepted_terms'], isTrue);
      expect(json['identity_verification_id'], 'verification-id');
      expect(json['ward'], 3);
      expect(json, isNot(contains('subdomain')));
    });

    test('signup and reset passcodes are exactly six digits', () {
      expect(AuthValidators.isValidPasscode('123456'), isTrue);
      expect(AuthValidators.isValidPasscode('12345'), isFalse);
      expect(AuthValidators.isValidPasscode('1234567'), isFalse);
      expect(AuthValidators.isValidPasscode('12345a'), isFalse);
    });

    testWidgets('signup passcode fields accept input and submit six digits', (
      tester,
    ) async {
      String? submittedPassword;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegisterStepCredentials(
              initialEmail: 'member@example.com',
              onContinue:
                  ({
                    required email,
                    required phone,
                    required password,
                    required inviteToken,
                  }) {
                    submittedPassword = password;
                  },
            ),
          ),
        ),
      );

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(5));

      await tester.enterText(fields.at(2), 'abc123');
      expect(
        tester.widget<TextFormField>(fields.at(2)).controller?.text,
        'abc123',
        reason: 'Input must not be silently discarded by the passcode field.',
      );
      expect(
        tester
            .widget<AppPrimaryButton>(find.byType(AppPrimaryButton))
            .onPressed,
        isNull,
      );

      await tester.enterText(fields.at(2), '123456');
      await tester.enterText(fields.at(3), '123456');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(fields.at(2)).controller?.text,
        '123456',
      );
      final continueButton = tester.widget<AppPrimaryButton>(
        find.byType(AppPrimaryButton),
      );
      expect(continueButton.onPressed, isNotNull);
      continueButton.onPressed!();
      expect(submittedPassword, '123456');
    });

    test('legacy sign-in accepts any non-empty password', () {
      expect(AuthValidators.isValidSignInPassword('x'), isTrue);
      expect(AuthValidators.isValidSignInPassword('123456'), isTrue);
      expect(AuthValidators.isValidSignInPassword(''), isFalse);
    });

    test('identity numbers contain six to ten digits', () {
      expect(AuthValidators.isValidIdentityNumber('123456'), isTrue);
      expect(AuthValidators.isValidIdentityNumber('1234567890'), isTrue);
      expect(AuthValidators.isValidIdentityNumber('12345'), isFalse);
      expect(AuthValidators.isValidIdentityNumber('12345678901'), isFalse);
      expect(AuthValidators.isValidIdentityNumber('12345a'), isFalse);
    });

    test('verified identity prefers normalized locked phone', () {
      final model = VerifiedIdentityModel.fromJson(const {
        'verification_id': 'verification-id',
        'first_name': 'Amina',
        'last_name': 'Member',
        'phone': '0712 345 678',
        'phone_normalized': '+254712345678',
        'phone_locked': true,
      });

      final identity = model.toEntity();

      expect(identity.phone, '+254712345678');
      expect(identity.phoneLocked, isTrue);
    });

    test('signup next_step distinguishes OTP and trusted sign-in', () {
      final otp = SignupPendingModel.fromJson(const {
        'next_step': 'otp',
        'channel': 'sms',
        'destination': '+2547******78',
      });
      final trusted = SignupPendingModel.fromJson(const {
        'next_step': 'signed_in',
        'access': 'access-token',
        'refresh': 'refresh-token',
      });

      expect(otp.expectsOtp, isTrue);
      expect(otp.hasSession, isFalse);
      expect(trusted.expectsSession, isTrue);
      expect(trusted.hasSession, isTrue);
    });

    test('sign-in result represents exactly one server outcome', () {
      expect(() => SignInResultEntity(), throwsAssertionError);
      expect(
        () => SignInResultEntity(
          mfaToken: 'mfa-token',
          pendingSignup: SignupPendingEntity(
            channel: SignupChannel.email,
            destination: 'member@example.com',
          ),
        ),
        throwsAssertionError,
      );
      expect(
        const SignInResultEntity(mfaToken: 'mfa-token').requiresMfa,
        isTrue,
      );
    });

    test('verified identity falls back to the unnormalized phone', () {
      final identity = VerifiedIdentityModel.fromJson(const {
        'verification_id': 'verification-id',
        'first_name': 'Amina',
        'last_name': 'Member',
        'phone': '0712345678',
      }).toEntity();

      expect(identity.phone, '0712345678');
      expect(identity.phoneLocked, isFalse);
    });
  });
}
