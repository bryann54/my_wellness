import 'package:flutter/material.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Axis direction;
  final Duration duration;
  final Gradient? gradient; // now nullable

  const Shimmer({
    super.key,
    required this.child,
    this.isLoading = true,
    this.direction = Axis.horizontal,
    this.duration = const Duration(milliseconds: 1500),
    this.gradient,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Gradient _defaultGradient(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseColor = cs.onSurface.withValues(alpha: 0.12); // darker base
    final lightColor = cs.onSurface.withValues(alpha: 0.06); // lighter part
    return LinearGradient(
      colors: [baseColor, lightColor, baseColor],
      stops: const [0.1, 0.5, 0.9],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;
    final gradient = widget.gradient ?? _defaultGradient(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          return gradient.createShader(
            Rect.fromLTRB(
              bounds.left + bounds.width * _animation.value,
              bounds.top,
              bounds.right + bounds.width * _animation.value,
              bounds.bottom,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

extension ShimmerExtension on Widget {
  Widget withShimmer({
    bool isLoading = true,
    Axis direction = Axis.horizontal,
    Duration duration = const Duration(milliseconds: 1500),
    Gradient? gradient,
  }) {
    return Shimmer(
      isLoading: isLoading,
      direction: direction,
      duration: duration,
      gradient: gradient,
      child: this,
    );
  }
}
