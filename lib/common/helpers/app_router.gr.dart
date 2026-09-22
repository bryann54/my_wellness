// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i23;
import 'package:flutter/material.dart' as _i24;
import 'package:my_wellness/common/pages/webview_screen.dart' as _i21;
import 'package:my_wellness/features/account/domain/entities/health_profile.dart'
    as _i25;
import 'package:my_wellness/features/account/presentation/pages/account_screen.dart'
    as _i1;
import 'package:my_wellness/features/account/presentation/pages/edit_profile_screen.dart'
    as _i7;
import 'package:my_wellness/features/assessments/presentation/pages/assessments_screen.dart'
    as _i3;
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart'
    as _i26;
import 'package:my_wellness/features/auth/presentation/pages/auth_screen.dart'
    as _i4;
import 'package:my_wellness/features/auth/presentation/pages/conversational_register_screen.dart'
    as _i6;
import 'package:my_wellness/features/auth/presentation/pages/login_screen.dart'
    as _i10;
import 'package:my_wellness/features/auth/presentation/pages/register_screen.dart'
    as _i15;
import 'package:my_wellness/features/auth/presentation/pages/splash_screen.dart'
    as _i17;
import 'package:my_wellness/features/auth/presentation/pages/verification_screen.dart'
    as _i19;
import 'package:my_wellness/features/bookings/presentation/pages/appointments_screen.dart'
    as _i2;
import 'package:my_wellness/features/bookings/presentation/pages/bookings_screen.dart'
    as _i5;
import 'package:my_wellness/features/geography/presentation/pages/register_stepper_screen.dart'
    as _i16;
import 'package:my_wellness/features/health_profile/presentation/pages/my_health_screen.dart'
    as _i13;
import 'package:my_wellness/features/home/presentation/pages/home_screen.dart'
    as _i9;
import 'package:my_wellness/features/medications/presentation/pages/medications_screen.dart'
    as _i12;
import 'package:my_wellness/features/notifications/presentation/pages/notifications_screen.dart'
    as _i14;
import 'package:my_wellness/features/subscriptions/presentation/pages/subscriptions_screen.dart'
    as _i18;
import 'package:my_wellness/features/vitals/presentation/pages/vitals_screen.dart'
    as _i20;
import 'package:my_wellness/features/wellness/presentation/pages/wellness_screen.dart'
    as _i22;
import 'package:my_wellness/forgot_password_screen.dart' as _i8;
import 'package:my_wellness/main_screen.dart' as _i11;

/// generated route for
/// [_i1.AccountScreen]
class AccountRoute extends _i23.PageRouteInfo<void> {
  const AccountRoute({List<_i23.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountScreen();
    },
  );
}

/// generated route for
/// [_i2.AppointmentsScreen]
class AppointmentsRoute extends _i23.PageRouteInfo<void> {
  const AppointmentsRoute({List<_i23.PageRouteInfo>? children})
    : super(AppointmentsRoute.name, initialChildren: children);

  static const String name = 'AppointmentsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i2.AppointmentsScreen();
    },
  );
}

/// generated route for
/// [_i3.AssessmentsScreen]
class AssessmentsRoute extends _i23.PageRouteInfo<void> {
  const AssessmentsRoute({List<_i23.PageRouteInfo>? children})
    : super(AssessmentsRoute.name, initialChildren: children);

  static const String name = 'AssessmentsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i3.AssessmentsScreen();
    },
  );
}

/// generated route for
/// [_i4.AuthScreen]
class AuthRoute extends _i23.PageRouteInfo<void> {
  const AuthRoute({List<_i23.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i4.AuthScreen();
    },
  );
}

/// generated route for
/// [_i5.BookingsScreen]
class BookingsRoute extends _i23.PageRouteInfo<void> {
  const BookingsRoute({List<_i23.PageRouteInfo>? children})
    : super(BookingsRoute.name, initialChildren: children);

  static const String name = 'BookingsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i5.BookingsScreen();
    },
  );
}

/// generated route for
/// [_i6.ConversationalRegisterScreen]
class ConversationalRegisterRoute extends _i23.PageRouteInfo<void> {
  const ConversationalRegisterRoute({List<_i23.PageRouteInfo>? children})
    : super(ConversationalRegisterRoute.name, initialChildren: children);

  static const String name = 'ConversationalRegisterRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i6.ConversationalRegisterScreen();
    },
  );
}

/// generated route for
/// [_i7.EditProfileScreen]
class EditProfileRoute extends _i23.PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    _i24.Key? key,
    required _i25.HealthProfile profile,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         EditProfileRoute.name,
         args: EditProfileRouteArgs(key: key, profile: profile),
         initialChildren: children,
       );

  static const String name = 'EditProfileRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileRouteArgs>();
      return _i7.EditProfileScreen(key: args.key, profile: args.profile);
    },
  );
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({this.key, required this.profile});

  final _i24.Key? key;

  final _i25.HealthProfile profile;

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
/// [_i8.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i23.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i23.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i8.ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [_i9.HomeScreen]
class HomeRoute extends _i23.PageRouteInfo<void> {
  const HomeRoute({List<_i23.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i9.HomeScreen();
    },
  );
}

/// generated route for
/// [_i10.LoginScreen]
class LoginRoute extends _i23.PageRouteInfo<void> {
  const LoginRoute({List<_i23.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i10.LoginScreen();
    },
  );
}

/// generated route for
/// [_i11.MainScreen]
class MainRoute extends _i23.PageRouteInfo<void> {
  const MainRoute({List<_i23.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i11.MainScreen();
    },
  );
}

/// generated route for
/// [_i12.MedicationsScreen]
class MedicationsRoute extends _i23.PageRouteInfo<void> {
  const MedicationsRoute({List<_i23.PageRouteInfo>? children})
    : super(MedicationsRoute.name, initialChildren: children);

  static const String name = 'MedicationsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i12.MedicationsScreen();
    },
  );
}

/// generated route for
/// [_i13.MyHealthScreen]
class MyHealthRoute extends _i23.PageRouteInfo<void> {
  const MyHealthRoute({List<_i23.PageRouteInfo>? children})
    : super(MyHealthRoute.name, initialChildren: children);

  static const String name = 'MyHealthRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i13.MyHealthScreen();
    },
  );
}

/// generated route for
/// [_i14.NotificationsScreen]
class NotificationsRoute extends _i23.PageRouteInfo<void> {
  const NotificationsRoute({List<_i23.PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i14.NotificationsScreen();
    },
  );
}

/// generated route for
/// [_i15.RegisterScreen]
class RegisterRoute extends _i23.PageRouteInfo<void> {
  const RegisterRoute({List<_i23.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i15.RegisterScreen();
    },
  );
}

/// generated route for
/// [_i16.RegisterStepperScreen]
class RegisterStepperRoute extends _i23.PageRouteInfo<void> {
  const RegisterStepperRoute({List<_i23.PageRouteInfo>? children})
    : super(RegisterStepperRoute.name, initialChildren: children);

  static const String name = 'RegisterStepperRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i16.RegisterStepperScreen();
    },
  );
}

/// generated route for
/// [_i17.SplashScreen]
class SplashRoute extends _i23.PageRouteInfo<void> {
  const SplashRoute({List<_i23.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i17.SplashScreen();
    },
  );
}

/// generated route for
/// [_i18.SubscriptionsScreen]
class SubscriptionsRoute extends _i23.PageRouteInfo<void> {
  const SubscriptionsRoute({List<_i23.PageRouteInfo>? children})
    : super(SubscriptionsRoute.name, initialChildren: children);

  static const String name = 'SubscriptionsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i18.SubscriptionsScreen();
    },
  );
}

/// generated route for
/// [_i19.VerificationScreen]
class VerificationRoute extends _i23.PageRouteInfo<VerificationRouteArgs> {
  VerificationRoute({
    _i24.Key? key,
    _i26.SignupPendingEntity? pending,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         VerificationRoute.name,
         args: VerificationRouteArgs(key: key, pending: pending),
         initialChildren: children,
       );

  static const String name = 'VerificationRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerificationRouteArgs>(
        orElse: () => const VerificationRouteArgs(),
      );
      return _i19.VerificationScreen(key: args.key, pending: args.pending);
    },
  );
}

class VerificationRouteArgs {
  const VerificationRouteArgs({this.key, this.pending});

  final _i24.Key? key;

  final _i26.SignupPendingEntity? pending;

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
/// [_i20.VitalsScreen]
class VitalsRoute extends _i23.PageRouteInfo<void> {
  const VitalsRoute({List<_i23.PageRouteInfo>? children})
    : super(VitalsRoute.name, initialChildren: children);

  static const String name = 'VitalsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i20.VitalsScreen();
    },
  );
}

/// generated route for
/// [_i21.WebViewScreen]
class WebViewRoute extends _i23.PageRouteInfo<WebViewRouteArgs> {
  WebViewRoute({
    _i24.Key? key,
    required String url,
    required String title,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         WebViewRoute.name,
         args: WebViewRouteArgs(key: key, url: url, title: title),
         initialChildren: children,
       );

  static const String name = 'WebViewRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WebViewRouteArgs>();
      return _i21.WebViewScreen(
        key: args.key,
        url: args.url,
        title: args.title,
      );
    },
  );
}

class WebViewRouteArgs {
  const WebViewRouteArgs({this.key, required this.url, required this.title});

  final _i24.Key? key;

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
/// [_i22.WellnessScreen]
class WellnessRoute extends _i23.PageRouteInfo<void> {
  const WellnessRoute({List<_i23.PageRouteInfo>? children})
    : super(WellnessRoute.name, initialChildren: children);

  static const String name = 'WellnessRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i22.WellnessScreen();
    },
  );
}
