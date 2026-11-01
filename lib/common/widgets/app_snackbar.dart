import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppSnackType { success, error, info, warning }

class AppSnackbar {
  AppSnackbar._();

  static const _duration = Duration(seconds: 3);
  static String? _lastMessage;
  static DateTime? _lastShownAt;

  static void show(
    BuildContext context, {
    required String message,
    AppSnackType type = AppSnackType.info,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastShownAt != null &&
        now.difference(_lastShownAt!) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastMessage = message;
    _lastShownAt = now;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AppSnackbarHost(
        message: message,
        type: type,
        duration: duration ?? _duration,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismissed: entry.remove,
      ),
    );

    overlay.insert(entry);
  }

  static void success(BuildContext c, String message, {Duration? duration}) =>
      show(c, message: message, type: AppSnackType.success, duration: duration);

  static void error(BuildContext c, String message, {Duration? duration}) =>
      show(c, message: message, type: AppSnackType.error, duration: duration);

  static void info(BuildContext c, String message, {Duration? duration}) =>
      show(c, message: message, type: AppSnackType.info, duration: duration);

  static void warning(BuildContext c, String message, {Duration? duration}) =>
      show(c, message: message, type: AppSnackType.warning, duration: duration);
}

class _AppSnackbarHost extends StatefulWidget {
  final String message;
  final AppSnackType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismissed;

  const _AppSnackbarHost({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_AppSnackbarHost> createState() => _AppSnackbarHostState();
}

class _AppSnackbarHostState extends State<_AppSnackbarHost>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _exitCtrl;
  late final AnimationController _iconCtrl;

  late final Animation<Offset> _slideIn;
  late final Animation<Offset> _slideOut;
  late final Animation<double> _fade;

  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.1, 0),
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic));

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();
    _iconCtrl.forward();

    Future.delayed(widget.duration, _exit);
  }

  Future<void> _exit() async {
    if (!mounted || _leaving) return;
    _leaving = true;

    await _exitCtrl.forward();

    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _exitCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final top = media.padding.top + 8;

    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideIn,
        child: SlideTransition(
          position: _slideOut,
          child: FadeTransition(
            opacity: ReverseAnimation(_exitCtrl),
            child: FadeTransition(
              opacity: _fade,
              child: _Bubble(
                message: widget.message,
                type: widget.type,
                actionLabel: widget.actionLabel,
                onAction: widget.onAction,
                onClose: _exit,
                colorScheme: cs,
                iconAnimation: _iconCtrl,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String message;
  final AppSnackType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onClose;
  final ColorScheme colorScheme;
  final Animation<double> iconAnimation;

  const _Bubble({
    required this.message,
    required this.type,
    required this.colorScheme,
    required this.onClose,
    required this.iconAnimation,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final (accent, iconWidget) = switch (type) {
      AppSnackType.success => (
        const Color(0xFF10B981),
        _AnimatedCheck(
          animation: iconAnimation,
          color: const Color(0xFF10B981),
        ),
      ),
      AppSnackType.error => (
        colorScheme.error,
        _AnimatedError(animation: iconAnimation, color: colorScheme.error),
      ),
      AppSnackType.warning => (
        const Color(0xFFF59E0B),
        _AnimatedWarning(
          animation: iconAnimation,
          color: const Color(0xFFF59E0B),
        ),
      ),
      AppSnackType.info => (
        colorScheme.primary,
        Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
      ),
    };

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  onAction?.call();
                  onClose();
                },
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClose,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCheck extends StatelessWidget {
  final Animation<double> animation;
  final Color color;

  const _AnimatedCheck({required this.animation, required this.color});

  @override
  Widget build(BuildContext context) {
    final ring = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
    final check = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutBack),
    );

    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(
        painter: _CheckPainter(ring: ring, check: check, color: color),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final Animation<double> ring;
  final Animation<double> check;
  final Color color;

  _CheckPainter({required this.ring, required this.check, required this.color})
    : super(repaint: Listenable.merge([ring, check]));

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    // Ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      6.2832 * ring.value.clamp(0.0, 1.0),
      false,
      stroke,
    );

    if (check.value > 0) {
      // Check stroke, drawn in two segments.
      final p1 = Offset(size.width * 0.30, size.height * 0.53);
      final p2 = Offset(size.width * 0.46, size.height * 0.68);
      final p3 = Offset(size.width * 0.72, size.height * 0.38);

      final t = check.value.clamp(0.0, 1.0);
      final firstEnd = Offset.lerp(p1, p2, (t * 2).clamp(0.0, 1.0))!;
      canvas.drawLine(p1, firstEnd, stroke);

      if (t > 0.5) {
        final secondT = ((t - 0.5) * 2).clamp(0.0, 1.0);
        final secondEnd = Offset.lerp(p2, p3, secondT)!;
        canvas.drawLine(p2, secondEnd, stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) =>
      old.color != color || old.ring != ring || old.check != check;
}

/// Error: a small horizontal "shake" applied to the error glyph.
class _AnimatedError extends StatelessWidget {
  final Animation<double> animation;
  final Color color;

  const _AnimatedError({required this.animation, required this.color});

  @override
  Widget build(BuildContext context) {
    final shake =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -2.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -2.0, end: 2.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 2.0, end: -1.5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -1.5, end: 1.5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
          ),
        );

    return AnimatedBuilder(
      animation: shake,
      builder: (_, child) =>
          Transform.translate(offset: Offset(shake.value, 0), child: child),
      child: Icon(Icons.error_outline, size: 16, color: color),
    );
  }
}

/// Warning: gentle pulse.
class _AnimatedWarning extends StatelessWidget {
  final Animation<double> animation;
  final Color color;

  const _AnimatedWarning({required this.animation, required this.color});

  @override
  Widget build(BuildContext context) {
    final pulse =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
          ),
        );

    return AnimatedBuilder(
      animation: pulse,
      builder: (_, child) => Transform.scale(scale: pulse.value, child: child),
      child: Icon(Icons.warning_amber_rounded, size: 16, color: color),
    );
  }
}
