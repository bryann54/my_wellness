import 'package:flutter/widgets.dart';

/// Corporate 4-point grid. Use these everywhere.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets pageWithTop = EdgeInsets.fromLTRB(lg, xl, lg, 0);
  static const EdgeInsets formFieldGap = EdgeInsets.only(bottom: md);
  static const EdgeInsets safeBottom = EdgeInsets.only(bottom: lg);
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration heroFlight = Duration(milliseconds: 400);
}
