import 'package:flutter/material.dart';

class BookingHero extends StatelessWidget {
  final String tag;
  final Widget child;

  const BookingHero({super.key, required this.tag, required this.child});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: _shuttle,
      child: Material(color: Colors.transparent, child: child),
    );
  }

  static Widget _shuttle(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final hero =
        (direction == HeroFlightDirection.push
                ? toHeroContext.widget
                : fromHeroContext.widget)
            as Hero;
    return hero.child;
  }
}
