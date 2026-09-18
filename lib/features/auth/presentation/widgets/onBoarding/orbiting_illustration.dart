import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/orbit_coin.dart';

class OrbitingIllustration extends StatefulWidget {
  final String imageAsset;
  final List<String> orbitAssets;
  final int pageIndex;

  const OrbitingIllustration({
    required this.imageAsset,
    required this.orbitAssets,
    required this.pageIndex,
    super.key,
  });

  @override
  State<OrbitingIllustration> createState() => OrbitingIllustrationState();
}

class OrbitingIllustrationState extends State<OrbitingIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _startAngle;
  late double _endAngle;

  @override
  void initState() {
    super.initState();
    _startAngle = widget.pageIndex * (2 * math.pi / 3);
    _endAngle = _startAngle;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(OrbitingIllustration old) {
    super.didUpdateWidget(old);
    if (old.pageIndex != widget.pageIndex) {
      _startAngle = _endAngle;
      _endAngle = widget.pageIndex * (2 * math.pi / 3);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double size = 320;
    const double orbitRadius = 145;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final rotation =
            _startAngle + (_endAngle - _startAngle) * _animation.value;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Orbit ring
              Container(
                width: orbitRadius * 2,
                height: orbitRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
              ),

              // Central image — cross-fades silently
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Container(
                  key: ValueKey(widget.imageAsset),
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(widget.imageAsset, fit: BoxFit.cover),
                  ),
                ),
              ),

              // Orbit icons — only these spin
              ...List.generate(widget.orbitAssets.length, (i) {
                final angle = (i * (2 * math.pi / 3)) + rotation;
                return Transform.translate(
                  offset: Offset(
                    orbitRadius * math.cos(angle),
                    orbitRadius * math.sin(angle),
                  ),
                  child: OrbitIcon(asset: widget.orbitAssets[i]),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
