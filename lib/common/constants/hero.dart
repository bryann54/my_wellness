abstract final class HeroTags {
  static const String authLogo = 'hero_auth_logo';
  static const String authToggle = 'hero_auth_toggle';
  static const String authPrimaryCta = 'hero_auth_primary_cta';
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

  static String assessmentTitle(String slug) => 'hero_assessment_title_$slug';
  static String assessmentTagline(String slug) =>
      'hero_assessment_tagline_$slug';
  static String bookingCard(String id) => 'hero_booking_card_$id';

  static String bookingCardMeta(String id) => 'hero_booking_card_meta_$id';

  static String bookingDetailAppBar(String id) =>
      'hero_booking_detail_appbar_$id';
  static String referralBookingCard(String id) =>
      'hero_referral_booking_card_$id';
}
