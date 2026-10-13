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
}
