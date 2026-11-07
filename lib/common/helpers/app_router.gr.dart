// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i38;
import 'package:flutter/material.dart' as _i39;
import 'package:my_wellness/common/pages/webview_screen.dart' as _i36;
import 'package:my_wellness/features/account/domain/entities/health_profile.dart'
    as _i42;
import 'package:my_wellness/features/account/presentation/pages/account_screen.dart'
    as _i1;
import 'package:my_wellness/features/account/presentation/pages/profile__details_screen.dart'
    as _i19;
import 'package:my_wellness/features/account/presentation/pages/settings_screen.dart'
    as _i22;
import 'package:my_wellness/features/appointments/presentation/pages/add_appointment_screen.dart'
    as _i2;
import 'package:my_wellness/features/appointments/presentation/pages/appointments_screen.dart'
    as _i4;
import 'package:my_wellness/features/assessments/presentation/pages/assessment_complete_screen.dart'
    as _i5;
import 'package:my_wellness/features/assessments/presentation/pages/assessment_intro_screen.dart'
    as _i6;
import 'package:my_wellness/features/assessments/presentation/pages/assessment_session_screen.dart'
    as _i7;
import 'package:my_wellness/features/assessments/presentation/pages/assessments_list_screen.dart'
    as _i8;
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart'
    as _i43;
import 'package:my_wellness/features/auth/presentation/pages/auth_screen.dart'
    as _i9;
import 'package:my_wellness/features/auth/presentation/pages/forgot_password_screen.dart'
    as _i11;
import 'package:my_wellness/features/auth/presentation/pages/login_screen.dart'
    as _i13;
import 'package:my_wellness/features/auth/presentation/pages/register_screen.dart'
    as _i21;
import 'package:my_wellness/features/auth/presentation/pages/verification_screen.dart'
    as _i24;
import 'package:my_wellness/features/bookings/domain/entities/facility.dart'
    as _i41;
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart'
    as _i40;
import 'package:my_wellness/features/bookings/presentation/pages/create_booking_screen.dart'
    as _i10;
import 'package:my_wellness/features/bookings/presentation/pages/referral_detail_screen.dart'
    as _i20;
import 'package:my_wellness/features/health_profile/presentation/pages/my_health_screen.dart'
    as _i16;
import 'package:my_wellness/features/home/presentation/pages/home_screen.dart'
    as _i12;
import 'package:my_wellness/features/launch/presentation/pages/splash_screen.dart'
    as _i23;
import 'package:my_wellness/features/medications/presentation/pages/add_medication_screen.dart'
    as _i3;
import 'package:my_wellness/features/medications/presentation/pages/medications_screen.dart'
    as _i15;
import 'package:my_wellness/features/notifications/presentation/pages/notifications_screen.dart'
    as _i17;
import 'package:my_wellness/features/pricing/presentation/pages/pricing_screen.dart'
    as _i18;
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart'
    as _i44;
import 'package:my_wellness/features/vitals/presentation/pages/capture/vitals_bmi_screen.dart'
    as _i25;
import 'package:my_wellness/features/vitals/presentation/pages/capture/vitals_capture_intro_screen.dart'
    as _i26;
import 'package:my_wellness/features/vitals/presentation/pages/capture/vitals_pathway_followup_screen.dart'
    as _i27;
import 'package:my_wellness/features/vitals/presentation/pages/capture/vitals_pathway_screen.dart'
    as _i28;
import 'package:my_wellness/features/vitals/presentation/pages/capture/vitals_pathway_tips_screen.dart'
    as _i29;
import 'package:my_wellness/features/vitals/presentation/pages/capture/vitals_reading_entry_screen.dart'
    as _i30;
import 'package:my_wellness/features/vitals/presentation/pages/capture/vitals_result_screen.dart'
    as _i31;
import 'package:my_wellness/features/vitals/presentation/pages/capture/vitals_second_reading_screen.dart'
    as _i34;
import 'package:my_wellness/features/vitals/presentation/pages/capture/vitals_wellbeing_screen.dart'
    as _i35;
import 'package:my_wellness/features/vitals/presentation/pages/vitals_route_screen.dart'
    as _i32;
import 'package:my_wellness/features/vitals/presentation/pages/vitals_screen.dart'
    as _i33;
import 'package:my_wellness/features/wellness/presentation/pages/wellness_screen.dart'
    as _i37;
import 'package:my_wellness/main_screen.dart' as _i14;

/// generated route for
/// [_i1.AccountScreen]
class AccountRoute extends _i38.PageRouteInfo<void> {
  const AccountRoute({List<_i38.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountScreen();
    },
  );
}

/// generated route for
/// [_i2.AddAppointmentScreen]
class AddAppointmentRoute extends _i38.PageRouteInfo<void> {
  const AddAppointmentRoute({List<_i38.PageRouteInfo>? children})
    : super(AddAppointmentRoute.name, initialChildren: children);

  static const String name = 'AddAppointmentRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i2.AddAppointmentScreen();
    },
  );
}

/// generated route for
/// [_i3.AddMedicationScreen]
class AddMedicationRoute extends _i38.PageRouteInfo<AddMedicationRouteArgs> {
  AddMedicationRoute({
    _i39.Key? key,
    String? condition,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         AddMedicationRoute.name,
         args: AddMedicationRouteArgs(key: key, condition: condition),
         initialChildren: children,
       );

  static const String name = 'AddMedicationRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddMedicationRouteArgs>(
        orElse: () => const AddMedicationRouteArgs(),
      );
      return _i3.AddMedicationScreen(key: args.key, condition: args.condition);
    },
  );
}

class AddMedicationRouteArgs {
  const AddMedicationRouteArgs({this.key, this.condition});

  final _i39.Key? key;

  final String? condition;

  @override
  String toString() {
    return 'AddMedicationRouteArgs{key: $key, condition: $condition}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddMedicationRouteArgs) return false;
    return key == other.key && condition == other.condition;
  }

  @override
  int get hashCode => key.hashCode ^ condition.hashCode;
}

/// generated route for
/// [_i4.AppointmentsScreen]
class AppointmentsRoute extends _i38.PageRouteInfo<void> {
  const AppointmentsRoute({List<_i38.PageRouteInfo>? children})
    : super(AppointmentsRoute.name, initialChildren: children);

  static const String name = 'AppointmentsRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i4.AppointmentsScreen();
    },
  );
}

/// generated route for
/// [_i5.AssessmentCompleteScreen]
class AssessmentCompleteRoute
    extends _i38.PageRouteInfo<AssessmentCompleteRouteArgs> {
  AssessmentCompleteRoute({
    _i39.Key? key,
    required String slug,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         AssessmentCompleteRoute.name,
         args: AssessmentCompleteRouteArgs(key: key, slug: slug),
         initialChildren: children,
       );

  static const String name = 'AssessmentCompleteRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AssessmentCompleteRouteArgs>();
      return _i5.AssessmentCompleteScreen(key: args.key, slug: args.slug);
    },
  );
}

class AssessmentCompleteRouteArgs {
  const AssessmentCompleteRouteArgs({this.key, required this.slug});

  final _i39.Key? key;

  final String slug;

  @override
  String toString() {
    return 'AssessmentCompleteRouteArgs{key: $key, slug: $slug}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AssessmentCompleteRouteArgs) return false;
    return key == other.key && slug == other.slug;
  }

  @override
  int get hashCode => key.hashCode ^ slug.hashCode;
}

/// generated route for
/// [_i6.AssessmentIntroScreen]
class AssessmentIntroRoute
    extends _i38.PageRouteInfo<AssessmentIntroRouteArgs> {
  AssessmentIntroRoute({
    _i39.Key? key,
    required String slug,
    String? sessionId,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         AssessmentIntroRoute.name,
         args: AssessmentIntroRouteArgs(
           key: key,
           slug: slug,
           sessionId: sessionId,
         ),
         initialChildren: children,
       );

  static const String name = 'AssessmentIntroRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AssessmentIntroRouteArgs>();
      return _i6.AssessmentIntroScreen(
        key: args.key,
        slug: args.slug,
        sessionId: args.sessionId,
      );
    },
  );
}

class AssessmentIntroRouteArgs {
  const AssessmentIntroRouteArgs({
    this.key,
    required this.slug,
    this.sessionId,
  });

  final _i39.Key? key;

  final String slug;

  final String? sessionId;

  @override
  String toString() {
    return 'AssessmentIntroRouteArgs{key: $key, slug: $slug, sessionId: $sessionId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AssessmentIntroRouteArgs) return false;
    return key == other.key &&
        slug == other.slug &&
        sessionId == other.sessionId;
  }

  @override
  int get hashCode => key.hashCode ^ slug.hashCode ^ sessionId.hashCode;
}

/// generated route for
/// [_i7.AssessmentSessionScreen]
class AssessmentSessionRoute
    extends _i38.PageRouteInfo<AssessmentSessionRouteArgs> {
  AssessmentSessionRoute({
    _i39.Key? key,
    required String slug,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         AssessmentSessionRoute.name,
         args: AssessmentSessionRouteArgs(key: key, slug: slug),
         initialChildren: children,
       );

  static const String name = 'AssessmentSessionRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AssessmentSessionRouteArgs>();
      return _i7.AssessmentSessionScreen(key: args.key, slug: args.slug);
    },
  );
}

class AssessmentSessionRouteArgs {
  const AssessmentSessionRouteArgs({this.key, required this.slug});

  final _i39.Key? key;

  final String slug;

  @override
  String toString() {
    return 'AssessmentSessionRouteArgs{key: $key, slug: $slug}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AssessmentSessionRouteArgs) return false;
    return key == other.key && slug == other.slug;
  }

  @override
  int get hashCode => key.hashCode ^ slug.hashCode;
}

/// generated route for
/// [_i8.AssessmentsListScreen]
class AssessmentsListRoute extends _i38.PageRouteInfo<void> {
  const AssessmentsListRoute({List<_i38.PageRouteInfo>? children})
    : super(AssessmentsListRoute.name, initialChildren: children);

  static const String name = 'AssessmentsListRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i8.AssessmentsListScreen();
    },
  );
}

/// generated route for
/// [_i9.AuthScreen]
class AuthRoute extends _i38.PageRouteInfo<void> {
  const AuthRoute({List<_i38.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i9.AuthScreen();
    },
  );
}

/// generated route for
/// [_i10.CreateBookingScreen]
class CreateBookingRoute extends _i38.PageRouteInfo<CreateBookingRouteArgs> {
  CreateBookingRoute({
    _i39.Key? key,
    required _i40.ServiceType serviceType,
    String? referralId,
    _i41.Facility? lockedFacility,
    String? serviceLabel,
    bool followUp = false,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         CreateBookingRoute.name,
         args: CreateBookingRouteArgs(
           key: key,
           serviceType: serviceType,
           referralId: referralId,
           lockedFacility: lockedFacility,
           serviceLabel: serviceLabel,
           followUp: followUp,
         ),
         initialChildren: children,
       );

  static const String name = 'CreateBookingRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateBookingRouteArgs>();
      return _i10.CreateBookingScreen(
        key: args.key,
        serviceType: args.serviceType,
        referralId: args.referralId,
        lockedFacility: args.lockedFacility,
        serviceLabel: args.serviceLabel,
        followUp: args.followUp,
      );
    },
  );
}

class CreateBookingRouteArgs {
  const CreateBookingRouteArgs({
    this.key,
    required this.serviceType,
    this.referralId,
    this.lockedFacility,
    this.serviceLabel,
    this.followUp = false,
  });

  final _i39.Key? key;

  final _i40.ServiceType serviceType;

  final String? referralId;

  final _i41.Facility? lockedFacility;

  final String? serviceLabel;

  final bool followUp;

  @override
  String toString() {
    return 'CreateBookingRouteArgs{key: $key, serviceType: $serviceType, referralId: $referralId, lockedFacility: $lockedFacility, serviceLabel: $serviceLabel, followUp: $followUp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateBookingRouteArgs) return false;
    return key == other.key &&
        serviceType == other.serviceType &&
        referralId == other.referralId &&
        lockedFacility == other.lockedFacility &&
        serviceLabel == other.serviceLabel &&
        followUp == other.followUp;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      serviceType.hashCode ^
      referralId.hashCode ^
      lockedFacility.hashCode ^
      serviceLabel.hashCode ^
      followUp.hashCode;
}

/// generated route for
/// [_i11.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i38.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i38.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i11.ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [_i12.HomeScreen]
class HomeRoute extends _i38.PageRouteInfo<void> {
  const HomeRoute({List<_i38.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i12.HomeScreen();
    },
  );
}

/// generated route for
/// [_i13.LoginScreen]
class LoginRoute extends _i38.PageRouteInfo<void> {
  const LoginRoute({List<_i38.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i13.LoginScreen();
    },
  );
}

/// generated route for
/// [_i14.MainScreen]
class MainRoute extends _i38.PageRouteInfo<void> {
  const MainRoute({List<_i38.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i14.MainScreen();
    },
  );
}

/// generated route for
/// [_i15.MedicationsScreen]
class MedicationsRoute extends _i38.PageRouteInfo<void> {
  const MedicationsRoute({List<_i38.PageRouteInfo>? children})
    : super(MedicationsRoute.name, initialChildren: children);

  static const String name = 'MedicationsRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i15.MedicationsScreen();
    },
  );
}

/// generated route for
/// [_i16.MyHealthScreen]
class MyHealthRoute extends _i38.PageRouteInfo<void> {
  const MyHealthRoute({List<_i38.PageRouteInfo>? children})
    : super(MyHealthRoute.name, initialChildren: children);

  static const String name = 'MyHealthRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i16.MyHealthScreen();
    },
  );
}

/// generated route for
/// [_i17.NotificationsScreen]
class NotificationsRoute extends _i38.PageRouteInfo<void> {
  const NotificationsRoute({List<_i38.PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i17.NotificationsScreen();
    },
  );
}

/// generated route for
/// [_i18.PricingScreen]
class PricingRoute extends _i38.PageRouteInfo<PricingRouteArgs> {
  PricingRoute({
    _i39.Key? key,
    String? initialServiceId,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         PricingRoute.name,
         args: PricingRouteArgs(key: key, initialServiceId: initialServiceId),
         initialChildren: children,
       );

  static const String name = 'PricingRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PricingRouteArgs>(
        orElse: () => const PricingRouteArgs(),
      );
      return _i18.PricingScreen(
        key: args.key,
        initialServiceId: args.initialServiceId,
      );
    },
  );
}

class PricingRouteArgs {
  const PricingRouteArgs({this.key, this.initialServiceId});

  final _i39.Key? key;

  final String? initialServiceId;

  @override
  String toString() {
    return 'PricingRouteArgs{key: $key, initialServiceId: $initialServiceId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PricingRouteArgs) return false;
    return key == other.key && initialServiceId == other.initialServiceId;
  }

  @override
  int get hashCode => key.hashCode ^ initialServiceId.hashCode;
}

/// generated route for
/// [_i19.ProfileDetailsScreen]
class ProfileDetailsRoute extends _i38.PageRouteInfo<ProfileDetailsRouteArgs> {
  ProfileDetailsRoute({
    _i39.Key? key,
    required _i42.HealthProfile profile,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         ProfileDetailsRoute.name,
         args: ProfileDetailsRouteArgs(key: key, profile: profile),
         initialChildren: children,
       );

  static const String name = 'ProfileDetailsRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProfileDetailsRouteArgs>();
      return _i19.ProfileDetailsScreen(key: args.key, profile: args.profile);
    },
  );
}

class ProfileDetailsRouteArgs {
  const ProfileDetailsRouteArgs({this.key, required this.profile});

  final _i39.Key? key;

  final _i42.HealthProfile profile;

  @override
  String toString() {
    return 'ProfileDetailsRouteArgs{key: $key, profile: $profile}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProfileDetailsRouteArgs) return false;
    return key == other.key && profile == other.profile;
  }

  @override
  int get hashCode => key.hashCode ^ profile.hashCode;
}

/// generated route for
/// [_i20.ReferralDetailScreen]
class ReferralDetailRoute extends _i38.PageRouteInfo<ReferralDetailRouteArgs> {
  ReferralDetailRoute({
    _i39.Key? key,
    required String referralId,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         ReferralDetailRoute.name,
         args: ReferralDetailRouteArgs(key: key, referralId: referralId),
         initialChildren: children,
       );

  static const String name = 'ReferralDetailRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReferralDetailRouteArgs>();
      return _i20.ReferralDetailScreen(
        key: args.key,
        referralId: args.referralId,
      );
    },
  );
}

class ReferralDetailRouteArgs {
  const ReferralDetailRouteArgs({this.key, required this.referralId});

  final _i39.Key? key;

  final String referralId;

  @override
  String toString() {
    return 'ReferralDetailRouteArgs{key: $key, referralId: $referralId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReferralDetailRouteArgs) return false;
    return key == other.key && referralId == other.referralId;
  }

  @override
  int get hashCode => key.hashCode ^ referralId.hashCode;
}

/// generated route for
/// [_i21.RegisterScreen]
class RegisterRoute extends _i38.PageRouteInfo<void> {
  const RegisterRoute({List<_i38.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i21.RegisterScreen();
    },
  );
}

/// generated route for
/// [_i22.SettingsScreen]
class SettingsRoute extends _i38.PageRouteInfo<void> {
  const SettingsRoute({List<_i38.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i22.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i23.SplashScreen]
class SplashRoute extends _i38.PageRouteInfo<void> {
  const SplashRoute({List<_i38.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i23.SplashScreen();
    },
  );
}

/// generated route for
/// [_i24.VerificationScreen]
class VerificationRoute extends _i38.PageRouteInfo<VerificationRouteArgs> {
  VerificationRoute({
    _i39.Key? key,
    _i43.SignupPendingEntity? pending,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         VerificationRoute.name,
         args: VerificationRouteArgs(key: key, pending: pending),
         initialChildren: children,
       );

  static const String name = 'VerificationRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerificationRouteArgs>(
        orElse: () => const VerificationRouteArgs(),
      );
      return _i24.VerificationScreen(key: args.key, pending: args.pending);
    },
  );
}

class VerificationRouteArgs {
  const VerificationRouteArgs({this.key, this.pending});

  final _i39.Key? key;

  final _i43.SignupPendingEntity? pending;

  @override
  String toString() {
    return 'VerificationRouteArgs{key: $key, pending: $pending}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VerificationRouteArgs) return false;
    return key == other.key && pending == other.pending;
  }

  @override
  int get hashCode => key.hashCode ^ pending.hashCode;
}

/// generated route for
/// [_i25.VitalsBmiScreen]
class VitalsBmiRoute extends _i38.PageRouteInfo<VitalsBmiRouteArgs> {
  VitalsBmiRoute({
    _i39.Key? key,
    required _i44.VitalsCaptureKind kind,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         VitalsBmiRoute.name,
         args: VitalsBmiRouteArgs(key: key, kind: kind),
         initialChildren: children,
       );

  static const String name = 'VitalsBmiRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VitalsBmiRouteArgs>();
      return _i25.VitalsBmiScreen(key: args.key, kind: args.kind);
    },
  );
}

class VitalsBmiRouteArgs {
  const VitalsBmiRouteArgs({this.key, required this.kind});

  final _i39.Key? key;

  final _i44.VitalsCaptureKind kind;

  @override
  String toString() {
    return 'VitalsBmiRouteArgs{key: $key, kind: $kind}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VitalsBmiRouteArgs) return false;
    return key == other.key && kind == other.kind;
  }

  @override
  int get hashCode => key.hashCode ^ kind.hashCode;
}

/// generated route for
/// [_i26.VitalsCaptureIntroScreen]
class VitalsCaptureIntroRoute
    extends _i38.PageRouteInfo<VitalsCaptureIntroRouteArgs> {
  VitalsCaptureIntroRoute({
    _i39.Key? key,
    required _i44.VitalsCaptureKind kind,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         VitalsCaptureIntroRoute.name,
         args: VitalsCaptureIntroRouteArgs(key: key, kind: kind),
         initialChildren: children,
       );

  static const String name = 'VitalsCaptureIntroRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VitalsCaptureIntroRouteArgs>();
      return _i26.VitalsCaptureIntroScreen(key: args.key, kind: args.kind);
    },
  );
}

class VitalsCaptureIntroRouteArgs {
  const VitalsCaptureIntroRouteArgs({this.key, required this.kind});

  final _i39.Key? key;

  final _i44.VitalsCaptureKind kind;

  @override
  String toString() {
    return 'VitalsCaptureIntroRouteArgs{key: $key, kind: $kind}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VitalsCaptureIntroRouteArgs) return false;
    return key == other.key && kind == other.kind;
  }

  @override
  int get hashCode => key.hashCode ^ kind.hashCode;
}

/// generated route for
/// [_i27.VitalsPathwayFollowupScreen]
class VitalsPathwayFollowupRoute
    extends _i38.PageRouteInfo<VitalsPathwayFollowupRouteArgs> {
  VitalsPathwayFollowupRoute({
    _i39.Key? key,
    required _i44.VitalsCaptureKind kind,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         VitalsPathwayFollowupRoute.name,
         args: VitalsPathwayFollowupRouteArgs(key: key, kind: kind),
         initialChildren: children,
       );

  static const String name = 'VitalsPathwayFollowupRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VitalsPathwayFollowupRouteArgs>();
      return _i27.VitalsPathwayFollowupScreen(key: args.key, kind: args.kind);
    },
  );
}

class VitalsPathwayFollowupRouteArgs {
  const VitalsPathwayFollowupRouteArgs({this.key, required this.kind});

  final _i39.Key? key;

  final _i44.VitalsCaptureKind kind;

  @override
  String toString() {
    return 'VitalsPathwayFollowupRouteArgs{key: $key, kind: $kind}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VitalsPathwayFollowupRouteArgs) return false;
    return key == other.key && kind == other.kind;
  }

  @override
  int get hashCode => key.hashCode ^ kind.hashCode;
}

/// generated route for
/// [_i28.VitalsPathwayScreen]
class VitalsPathwayRoute extends _i38.PageRouteInfo<VitalsPathwayRouteArgs> {
  VitalsPathwayRoute({
    _i39.Key? key,
    required _i44.VitalsCaptureKind kind,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         VitalsPathwayRoute.name,
         args: VitalsPathwayRouteArgs(key: key, kind: kind),
         initialChildren: children,
       );

  static const String name = 'VitalsPathwayRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VitalsPathwayRouteArgs>();
      return _i28.VitalsPathwayScreen(key: args.key, kind: args.kind);
    },
  );
}

class VitalsPathwayRouteArgs {
  const VitalsPathwayRouteArgs({this.key, required this.kind});

  final _i39.Key? key;

  final _i44.VitalsCaptureKind kind;

  @override
  String toString() {
    return 'VitalsPathwayRouteArgs{key: $key, kind: $kind}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VitalsPathwayRouteArgs) return false;
    return key == other.key && kind == other.kind;
  }

  @override
  int get hashCode => key.hashCode ^ kind.hashCode;
}

/// generated route for
/// [_i29.VitalsPathwayTipsScreen]
class VitalsPathwayTipsRoute
    extends _i38.PageRouteInfo<VitalsPathwayTipsRouteArgs> {
  VitalsPathwayTipsRoute({
    _i39.Key? key,
    required _i44.VitalsCaptureKind kind,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         VitalsPathwayTipsRoute.name,
         args: VitalsPathwayTipsRouteArgs(key: key, kind: kind),
         initialChildren: children,
       );

  static const String name = 'VitalsPathwayTipsRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VitalsPathwayTipsRouteArgs>();
      return _i29.VitalsPathwayTipsScreen(key: args.key, kind: args.kind);
    },
  );
}

class VitalsPathwayTipsRouteArgs {
  const VitalsPathwayTipsRouteArgs({this.key, required this.kind});

  final _i39.Key? key;

  final _i44.VitalsCaptureKind kind;

  @override
  String toString() {
    return 'VitalsPathwayTipsRouteArgs{key: $key, kind: $kind}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VitalsPathwayTipsRouteArgs) return false;
    return key == other.key && kind == other.kind;
  }

  @override
  int get hashCode => key.hashCode ^ kind.hashCode;
}

/// generated route for
/// [_i30.VitalsReadingEntryScreen]
class VitalsReadingEntryRoute
    extends _i38.PageRouteInfo<VitalsReadingEntryRouteArgs> {
  VitalsReadingEntryRoute({
    _i39.Key? key,
    required _i44.VitalsCaptureKind kind,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         VitalsReadingEntryRoute.name,
         args: VitalsReadingEntryRouteArgs(key: key, kind: kind),
         initialChildren: children,
       );

  static const String name = 'VitalsReadingEntryRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VitalsReadingEntryRouteArgs>();
      return _i30.VitalsReadingEntryScreen(key: args.key, kind: args.kind);
    },
  );
}

class VitalsReadingEntryRouteArgs {
  const VitalsReadingEntryRouteArgs({this.key, required this.kind});

  final _i39.Key? key;

  final _i44.VitalsCaptureKind kind;

  @override
  String toString() {
    return 'VitalsReadingEntryRouteArgs{key: $key, kind: $kind}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VitalsReadingEntryRouteArgs) return false;
    return key == other.key && kind == other.kind;
  }

  @override
  int get hashCode => key.hashCode ^ kind.hashCode;
}

/// generated route for
/// [_i31.VitalsResultScreen]
class VitalsResultRoute extends _i38.PageRouteInfo<VitalsResultRouteArgs> {
  VitalsResultRoute({
    _i39.Key? key,
    required _i44.VitalsCaptureKind kind,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         VitalsResultRoute.name,
         args: VitalsResultRouteArgs(key: key, kind: kind),
         initialChildren: children,
       );

  static const String name = 'VitalsResultRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VitalsResultRouteArgs>();
      return _i31.VitalsResultScreen(key: args.key, kind: args.kind);
    },
  );
}

class VitalsResultRouteArgs {
  const VitalsResultRouteArgs({this.key, required this.kind});

  final _i39.Key? key;

  final _i44.VitalsCaptureKind kind;

  @override
  String toString() {
    return 'VitalsResultRouteArgs{key: $key, kind: $kind}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VitalsResultRouteArgs) return false;
    return key == other.key && kind == other.kind;
  }

  @override
  int get hashCode => key.hashCode ^ kind.hashCode;
}

/// generated route for
/// [_i32.VitalsRouteScreen]
class VitalsRouteRoute extends _i38.PageRouteInfo<VitalsRouteRouteArgs> {
  VitalsRouteRoute({
    _i39.Key? key,
    int initialTab = 0,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         VitalsRouteRoute.name,
         args: VitalsRouteRouteArgs(key: key, initialTab: initialTab),
         initialChildren: children,
       );

  static const String name = 'VitalsRouteRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VitalsRouteRouteArgs>(
        orElse: () => const VitalsRouteRouteArgs(),
      );
      return _i32.VitalsRouteScreen(key: args.key, initialTab: args.initialTab);
    },
  );
}

class VitalsRouteRouteArgs {
  const VitalsRouteRouteArgs({this.key, this.initialTab = 0});

  final _i39.Key? key;

  final int initialTab;

  @override
  String toString() {
    return 'VitalsRouteRouteArgs{key: $key, initialTab: $initialTab}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VitalsRouteRouteArgs) return false;
    return key == other.key && initialTab == other.initialTab;
  }

  @override
  int get hashCode => key.hashCode ^ initialTab.hashCode;
}

/// generated route for
/// [_i33.VitalsScreen]
class VitalsRoute extends _i38.PageRouteInfo<VitalsRouteArgs> {
  VitalsRoute({
    _i39.Key? key,
    int initialTab = 0,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         VitalsRoute.name,
         args: VitalsRouteArgs(key: key, initialTab: initialTab),
         initialChildren: children,
       );

  static const String name = 'VitalsRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VitalsRouteArgs>(
        orElse: () => const VitalsRouteArgs(),
      );
      return _i33.VitalsScreen(key: args.key, initialTab: args.initialTab);
    },
  );
}

class VitalsRouteArgs {
  const VitalsRouteArgs({this.key, this.initialTab = 0});

  final _i39.Key? key;

  final int initialTab;

  @override
  String toString() {
    return 'VitalsRouteArgs{key: $key, initialTab: $initialTab}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VitalsRouteArgs) return false;
    return key == other.key && initialTab == other.initialTab;
  }

  @override
  int get hashCode => key.hashCode ^ initialTab.hashCode;
}

/// generated route for
/// [_i34.VitalsSecondReadingScreen]
class VitalsSecondReadingRoute
    extends _i38.PageRouteInfo<VitalsSecondReadingRouteArgs> {
  VitalsSecondReadingRoute({
    _i39.Key? key,
    required _i44.VitalsCaptureKind kind,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         VitalsSecondReadingRoute.name,
         args: VitalsSecondReadingRouteArgs(key: key, kind: kind),
         initialChildren: children,
       );

  static const String name = 'VitalsSecondReadingRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VitalsSecondReadingRouteArgs>();
      return _i34.VitalsSecondReadingScreen(key: args.key, kind: args.kind);
    },
  );
}

class VitalsSecondReadingRouteArgs {
  const VitalsSecondReadingRouteArgs({this.key, required this.kind});

  final _i39.Key? key;

  final _i44.VitalsCaptureKind kind;

  @override
  String toString() {
    return 'VitalsSecondReadingRouteArgs{key: $key, kind: $kind}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VitalsSecondReadingRouteArgs) return false;
    return key == other.key && kind == other.kind;
  }

  @override
  int get hashCode => key.hashCode ^ kind.hashCode;
}

/// generated route for
/// [_i35.VitalsWellbeingScreen]
class VitalsWellbeingRoute
    extends _i38.PageRouteInfo<VitalsWellbeingRouteArgs> {
  VitalsWellbeingRoute({
    _i39.Key? key,
    required _i44.VitalsCaptureKind kind,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         VitalsWellbeingRoute.name,
         args: VitalsWellbeingRouteArgs(key: key, kind: kind),
         initialChildren: children,
       );

  static const String name = 'VitalsWellbeingRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VitalsWellbeingRouteArgs>();
      return _i35.VitalsWellbeingScreen(key: args.key, kind: args.kind);
    },
  );
}

class VitalsWellbeingRouteArgs {
  const VitalsWellbeingRouteArgs({this.key, required this.kind});

  final _i39.Key? key;

  final _i44.VitalsCaptureKind kind;

  @override
  String toString() {
    return 'VitalsWellbeingRouteArgs{key: $key, kind: $kind}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VitalsWellbeingRouteArgs) return false;
    return key == other.key && kind == other.kind;
  }

  @override
  int get hashCode => key.hashCode ^ kind.hashCode;
}

/// generated route for
/// [_i36.WebViewScreen]
class WebViewRoute extends _i38.PageRouteInfo<WebViewRouteArgs> {
  WebViewRoute({
    _i39.Key? key,
    required String url,
    required String title,
    List<_i38.PageRouteInfo>? children,
  }) : super(
         WebViewRoute.name,
         args: WebViewRouteArgs(key: key, url: url, title: title),
         initialChildren: children,
       );

  static const String name = 'WebViewRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WebViewRouteArgs>();
      return _i36.WebViewScreen(
        key: args.key,
        url: args.url,
        title: args.title,
      );
    },
  );
}

class WebViewRouteArgs {
  const WebViewRouteArgs({this.key, required this.url, required this.title});

  final _i39.Key? key;

  final String url;

  final String title;

  @override
  String toString() {
    return 'WebViewRouteArgs{key: $key, url: $url, title: $title}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WebViewRouteArgs) return false;
    return key == other.key && url == other.url && title == other.title;
  }

  @override
  int get hashCode => key.hashCode ^ url.hashCode ^ title.hashCode;
}

/// generated route for
/// [_i37.WellnessScreen]
class WellnessRoute extends _i38.PageRouteInfo<void> {
  const WellnessRoute({List<_i38.PageRouteInfo>? children})
    : super(WellnessRoute.name, initialChildren: children);

  static const String name = 'WellnessRoute';

  static _i38.PageInfo page = _i38.PageInfo(
    name,
    builder: (data) {
      return const _i37.WellnessScreen();
    },
  );
}
