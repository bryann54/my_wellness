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
      duration: const Duration(milliseconds: 900),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        final orbitRadius = size * 0.44;
        final imageSize = size * 0.82;
        final iconSize = size * 0.13;

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
                clipBehavior: Clip.none,
                children: [
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

                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Image.asset(
                          widget.imageAsset,
                          key: ValueKey(widget.imageAsset),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  ...List.generate(widget.orbitAssets.length, (i) {
                    final angle = (i * (2 * math.pi / 3)) + rotation;
                    return Transform.translate(
                      offset: Offset(
                        orbitRadius * math.cos(angle),
                        orbitRadius * math.sin(angle),
                      ),
                      child: SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: OrbitIcon(asset: widget.orbitAssets[i]),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
