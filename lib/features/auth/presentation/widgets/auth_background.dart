import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  final double scrimOpacity;

  const AuthBackground({
    super.key,
    required this.child,
    this.scrimOpacity = 0.28,
  });

  static const assetPath = 'assets/images/splash.jpg';

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: scrimOpacity * 0.15),
                      Colors.black.withValues(alpha: scrimOpacity * 0.55),
                      Colors.black.withValues(alpha: scrimOpacity),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
