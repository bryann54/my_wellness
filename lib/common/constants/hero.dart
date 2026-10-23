// ignore_for_file: constant_identifier_names

/// Centralized Hero tag registry. Every tag used in the app lives here.
/// Rule: a tag may only be "in flight" between two adjacent screens.
abstract final class HeroTags {
  /// Logo carried across the auth funnel:
  /// Splash → Auth (onboarding) → Login → Register.
  static const String authLogo = 'hero_auth_logo';

  /// Bottom-bar "Sign in / Sign up" toggle between Login ↔ Register.
  static const String authToggle = 'hero_auth_toggle';

  /// Primary CTA carried Login → Main.
  static const String authPrimaryCta = 'hero_auth_primary_cta';

  /// "Continue" CTA carried Verification → Login (after code confirm).
  static const String verificationCta = 'hero_verification_cta';

  static const String homeNotifications = 'hero_home_notifications';
  static const String homeMedication = 'hero_home_medication';
  static const String homeMyHealth = 'hero_home_my_health';
  static const String homeAppointments = 'hero_home_appointments';
  static const String homeVitals = 'hero_home_vitals';
  static const String homeBloodPressure = 'hero_home_blood_pressure';
  static const String homeBloodSugar = 'hero_home_blood_sugar';
  static const String homeBloodPressureReading =
      'hero_home_blood_pressure_reading';
  static const String homeBloodSugarReading = 'hero_home_blood_sugar_reading';
  static const String homeBloodPressureTimestamp =
      'hero_home_blood_pressure_timestamp';
  static const String homeBloodSugarTimestamp =
      'hero_home_blood_sugar_timestamp';
  static const String homeScreeningActivity = 'hero_home_screening_activity';
}
