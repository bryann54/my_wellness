// ═════════════════════════════════════════════════════════════════════════════
// Orbit icon
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class OrbitIcon extends StatelessWidget {
  final String asset;
  const OrbitIcon({required this.asset, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(asset, width: 28, height: 28),
    );
  }
}
