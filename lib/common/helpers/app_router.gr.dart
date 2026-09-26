// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i27;
import 'package:flutter/material.dart' as _i28;
import 'package:my_wellness/common/pages/webview_screen.dart' as _i25;
import 'package:my_wellness/features/account/domain/entities/health_profile.dart'
    as _i29;
import 'package:my_wellness/features/account/presentation/pages/account_screen.dart'
    as _i1;
import 'package:my_wellness/features/account/presentation/pages/edit_profile_screen.dart'
    as _i11;
import 'package:my_wellness/features/assessments/presentation/pages/assessment_complete_screen.dart'
    as _i3;
import 'package:my_wellness/features/assessments/presentation/pages/assessment_intro_screen.dart'
    as _i4;
import 'package:my_wellness/features/assessments/presentation/pages/assessment_result_screen.dart'
    as _i5;
import 'package:my_wellness/features/assessments/presentation/pages/assessment_session_screen.dart'
    as _i6;
import 'package:my_wellness/features/assessments/presentation/pages/assessments_list_screen.dart'
    as _i7;
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart'
    as _i30;
import 'package:my_wellness/features/auth/presentation/pages/auth_screen.dart'
    as _i8;
import 'package:my_wellness/features/auth/presentation/pages/conversational_register_screen.dart'
    as _i10;
import 'package:my_wellness/features/auth/presentation/pages/login_screen.dart'
    as _i14;
import 'package:my_wellness/features/auth/presentation/pages/register_screen.dart'
    as _i19;
import 'package:my_wellness/features/auth/presentation/pages/splash_screen.dart'
    as _i21;
import 'package:my_wellness/features/auth/presentation/pages/verification_screen.dart'
    as _i23;
import 'package:my_wellness/features/bookings/presentation/pages/bookings_screen.dart'
    as _i9;
import 'package:my_wellness/features/geography/presentation/pages/register_stepper_screen.dart'
    as _i20;
import 'package:my_wellness/features/health_profile/presentation/pages/my_health_screen.dart'
    as _i17;
import 'package:my_wellness/features/home/presentation/pages/home_screen.dart'
    as _i13;
import 'package:my_wellness/features/notifications/presentation/pages/notifications_screen.dart'
    as _i18;
import 'package:my_wellness/features/subscriptions/presentation/pages/subscriptions_screen.dart'
    as _i22;
import 'package:my_wellness/features/vitals/presentation/pages/appointments_screen.dart'
    as _i2;
import 'package:my_wellness/features/vitals/presentation/pages/medications_screen.dart'
    as _i16;
import 'package:my_wellness/features/vitals/presentation/pages/vitals_screen.dart'
    as _i24;
import 'package:my_wellness/features/wellness/presentation/pages/wellness_screen.dart'
    as _i26;
import 'package:my_wellness/forgot_password_screen.dart' as _i12;
import 'package:my_wellness/main_screen.dart' as _i15;

/// generated route for
/// [_i1.AccountScreen]
class AccountRoute extends _i27.PageRouteInfo<void> {
  const AccountRoute({List<_i27.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountScreen();
    },
  );
}

/// generated route for
/// [_i2.AppointmentsScreen]
class AppointmentsRoute extends _i27.PageRouteInfo<void> {
  const AppointmentsRoute({List<_i27.PageRouteInfo>? children})
    : super(AppointmentsRoute.name, initialChildren: children);

  static const String name = 'AppointmentsRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i2.AppointmentsScreen();
    },
  );
}

/// generated route for
/// [_i3.AssessmentCompleteScreen]
class AssessmentCompleteRoute
    extends _i27.PageRouteInfo<AssessmentCompleteRouteArgs> {
  AssessmentCompleteRoute({
    _i28.Key? key,
    required String slug,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         AssessmentCompleteRoute.name,
         args: AssessmentCompleteRouteArgs(key: key, slug: slug),
         initialChildren: children,
       );

  static const String name = 'AssessmentCompleteRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AssessmentCompleteRouteArgs>();
      return _i3.AssessmentCompleteScreen(key: args.key, slug: args.slug);
    },
  );
}

class AssessmentCompleteRouteArgs {
  const AssessmentCompleteRouteArgs({this.key, required this.slug});

  final _i28.Key? key;

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
/// [_i4.AssessmentIntroScreen]
class AssessmentIntroRoute
    extends _i27.PageRouteInfo<AssessmentIntroRouteArgs> {
  AssessmentIntroRoute({
    _i28.Key? key,
    required String slug,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         AssessmentIntroRoute.name,
         args: AssessmentIntroRouteArgs(key: key, slug: slug),
         initialChildren: children,
       );

  static const String name = 'AssessmentIntroRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AssessmentIntroRouteArgs>();
      return _i4.AssessmentIntroScreen(key: args.key, slug: args.slug);
    },
  );
}

class AssessmentIntroRouteArgs {
  const AssessmentIntroRouteArgs({this.key, required this.slug});

  final _i28.Key? key;

  final String slug;

  @override
  String toString() {
    return 'AssessmentIntroRouteArgs{key: $key, slug: $slug}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AssessmentIntroRouteArgs) return false;
    return key == other.key && slug == other.slug;
  }

  @override
  int get hashCode => key.hashCode ^ slug.hashCode;
}

/// generated route for
/// [_i5.AssessmentResultScreen]
class AssessmentResultRoute
    extends _i27.PageRouteInfo<AssessmentResultRouteArgs> {
  AssessmentResultRoute({
    _i28.Key? key,
    required String slug,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         AssessmentResultRoute.name,
         args: AssessmentResultRouteArgs(key: key, slug: slug),
         initialChildren: children,
       );

  static const String name = 'AssessmentResultRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AssessmentResultRouteArgs>();
      return _i5.AssessmentResultScreen(key: args.key, slug: args.slug);
    },
  );
}

class AssessmentResultRouteArgs {
  const AssessmentResultRouteArgs({this.key, required this.slug});

  final _i28.Key? key;

  final String slug;

  @override
  String toString() {
    return 'AssessmentResultRouteArgs{key: $key, slug: $slug}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AssessmentResultRouteArgs) return false;
    return key == other.key && slug == other.slug;
  }

  @override
  int get hashCode => key.hashCode ^ slug.hashCode;
}

/// generated route for
/// [_i6.AssessmentSessionScreen]
class AssessmentSessionRoute
    extends _i27.PageRouteInfo<AssessmentSessionRouteArgs> {
  AssessmentSessionRoute({
    _i28.Key? key,
    required String slug,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         AssessmentSessionRoute.name,
         args: AssessmentSessionRouteArgs(key: key, slug: slug),
         initialChildren: children,
       );

  static const String name = 'AssessmentSessionRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AssessmentSessionRouteArgs>();
      return _i6.AssessmentSessionScreen(key: args.key, slug: args.slug);
    },
  );
}

class AssessmentSessionRouteArgs {
  const AssessmentSessionRouteArgs({this.key, required this.slug});

  final _i28.Key? key;

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
/// [_i7.AssessmentsListScreen]
class AssessmentsListRoute extends _i27.PageRouteInfo<void> {
  const AssessmentsListRoute({List<_i27.PageRouteInfo>? children})
    : super(AssessmentsListRoute.name, initialChildren: children);

  static const String name = 'AssessmentsListRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i7.AssessmentsListScreen();
    },
  );
}

/// generated route for
/// [_i8.AuthScreen]
class AuthRoute extends _i27.PageRouteInfo<void> {
  const AuthRoute({List<_i27.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i8.AuthScreen();
    },
  );
}

/// generated route for
/// [_i9.BookingsScreen]
class BookingsRoute extends _i27.PageRouteInfo<void> {
  const BookingsRoute({List<_i27.PageRouteInfo>? children})
    : super(BookingsRoute.name, initialChildren: children);

  static const String name = 'BookingsRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i9.BookingsScreen();
    },
  );
}

/// generated route for
/// [_i10.ConversationalRegisterScreen]
class ConversationalRegisterRoute extends _i27.PageRouteInfo<void> {
  const ConversationalRegisterRoute({List<_i27.PageRouteInfo>? children})
    : super(ConversationalRegisterRoute.name, initialChildren: children);

  static const String name = 'ConversationalRegisterRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i10.ConversationalRegisterScreen();
    },
  );
}

/// generated route for
/// [_i11.EditProfileScreen]
class EditProfileRoute extends _i27.PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    _i28.Key? key,
    required _i29.HealthProfile profile,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         EditProfileRoute.name,
         args: EditProfileRouteArgs(key: key, profile: profile),
         initialChildren: children,
       );

  static const String name = 'EditProfileRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileRouteArgs>();
      return _i11.EditProfileScreen(key: args.key, profile: args.profile);
    },
  );
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({this.key, required this.profile});

  final _i28.Key? key;

  final _i29.HealthProfile profile;

  @override
  String toString() {
    return 'EditProfileRouteArgs{key: $key, profile: $profile}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditProfileRouteArgs) return false;
    return key == other.key && profile == other.profile;
  }

  @override
  int get hashCode => key.hashCode ^ profile.hashCode;
}

/// generated route for
/// [_i12.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i27.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i27.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i12.ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [_i13.HomeScreen]
class HomeRoute extends _i27.PageRouteInfo<void> {
  const HomeRoute({List<_i27.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i13.HomeScreen();
    },
  );
}

/// generated route for
/// [_i14.LoginScreen]
class LoginRoute extends _i27.PageRouteInfo<void> {
  const LoginRoute({List<_i27.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i14.LoginScreen();
    },
  );
}

/// generated route for
/// [_i15.MainScreen]
class MainRoute extends _i27.PageRouteInfo<void> {
  const MainRoute({List<_i27.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i15.MainScreen();
    },
  );
}

/// generated route for
/// [_i16.MedicationsScreen]
class MedicationsRoute extends _i27.PageRouteInfo<void> {
  const MedicationsRoute({List<_i27.PageRouteInfo>? children})
    : super(MedicationsRoute.name, initialChildren: children);

  static const String name = 'MedicationsRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i16.MedicationsScreen();
    },
  );
}

/// generated route for
/// [_i17.MyHealthScreen]
class MyHealthRoute extends _i27.PageRouteInfo<void> {
  const MyHealthRoute({List<_i27.PageRouteInfo>? children})
    : super(MyHealthRoute.name, initialChildren: children);

  static const String name = 'MyHealthRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i17.MyHealthScreen();
    },
  );
}

/// generated route for
/// [_i18.NotificationsScreen]
class NotificationsRoute extends _i27.PageRouteInfo<void> {
  const NotificationsRoute({List<_i27.PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i18.NotificationsScreen();
    },
  );
}

/// generated route for
/// [_i19.RegisterScreen]
class RegisterRoute extends _i27.PageRouteInfo<void> {
  const RegisterRoute({List<_i27.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i19.RegisterScreen();
    },
  );
}

/// generated route for
/// [_i20.RegisterStepperScreen]
class RegisterStepperRoute extends _i27.PageRouteInfo<void> {
  const RegisterStepperRoute({List<_i27.PageRouteInfo>? children})
    : super(RegisterStepperRoute.name, initialChildren: children);

  static const String name = 'RegisterStepperRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i20.RegisterStepperScreen();
    },
  );
}

/// generated route for
/// [_i21.SplashScreen]
class SplashRoute extends _i27.PageRouteInfo<void> {
  const SplashRoute({List<_i27.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i21.SplashScreen();
    },
  );
}

/// generated route for
/// [_i22.SubscriptionsScreen]
class SubscriptionsRoute extends _i27.PageRouteInfo<void> {
  const SubscriptionsRoute({List<_i27.PageRouteInfo>? children})
    : super(SubscriptionsRoute.name, initialChildren: children);

  static const String name = 'SubscriptionsRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i22.SubscriptionsScreen();
    },
  );
}

/// generated route for
/// [_i23.VerificationScreen]
class VerificationRoute extends _i27.PageRouteInfo<VerificationRouteArgs> {
  VerificationRoute({
    _i28.Key? key,
    _i30.SignupPendingEntity? pending,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         VerificationRoute.name,
         args: VerificationRouteArgs(key: key, pending: pending),
         initialChildren: children,
       );

  static const String name = 'VerificationRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerificationRouteArgs>(
        orElse: () => const VerificationRouteArgs(),
      );
      return _i23.VerificationScreen(key: args.key, pending: args.pending);
    },
  );
}

class VerificationRouteArgs {
  const VerificationRouteArgs({this.key, this.pending});

  final _i28.Key? key;

  final _i30.SignupPendingEntity? pending;

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
/// [_i24.VitalsScreen]
class VitalsRoute extends _i27.PageRouteInfo<VitalsRouteArgs> {
  VitalsRoute({
    _i28.Key? key,
    int initialTab = 0,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         VitalsRoute.name,
         args: VitalsRouteArgs(key: key, initialTab: initialTab),
         initialChildren: children,
       );

  static const String name = 'VitalsRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VitalsRouteArgs>(
        orElse: () => const VitalsRouteArgs(),
      );
      return _i24.VitalsScreen(key: args.key, initialTab: args.initialTab);
    },
  );
}

class VitalsRouteArgs {
  const VitalsRouteArgs({this.key, this.initialTab = 0});

  final _i28.Key? key;

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
/// [_i25.WebViewScreen]
class WebViewRoute extends _i27.PageRouteInfo<WebViewRouteArgs> {
  WebViewRoute({
    _i28.Key? key,
    required String url,
    required String title,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         WebViewRoute.name,
         args: WebViewRouteArgs(key: key, url: url, title: title),
         initialChildren: children,
       );

  static const String name = 'WebViewRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WebViewRouteArgs>();
      return _i25.WebViewScreen(
        key: args.key,
        url: args.url,
        title: args.title,
      );
    },
  );
}

class WebViewRouteArgs {
  const WebViewRouteArgs({this.key, required this.url, required this.title});

  final _i28.Key? key;

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
/// [_i26.WellnessScreen]
class WellnessRoute extends _i27.PageRouteInfo<void> {
  const WellnessRoute({List<_i27.PageRouteInfo>? children})
    : super(WellnessRoute.name, initialChildren: children);

  static const String name = 'WellnessRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i26.WellnessScreen();
    },
  );
}
