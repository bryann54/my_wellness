import 'package:flutter/material.dart';

class AppBarClipper extends CustomClipper<Path> {
  static const radius = 28.0;

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - radius);
    path.quadraticBezierTo(0, size.height, radius, size.height);
    path.lineTo(size.width - radius, size.height);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - radius,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(AppBarClipper old) => false;
}
