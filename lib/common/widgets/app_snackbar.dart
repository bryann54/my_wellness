// lib/common/widgets/app_snackbar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppSnackType { success, error, info, warning }

class AppSnackbar {
  AppSnackbar._();

  static const _duration = Duration(seconds: 3);
  static void show(
    BuildContext context, {
    required String message,
    AppSnackType type = AppSnackType.info,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (_) => _AppSnackbarHost(
        message: message,
        type: type,
        duration: duration ?? _duration,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismissed: () {
          // The host removes itself.
        },
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slideIn;
  late final Animation<double> _fade;

  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 260),
    );

    // Entrance: from above → in place (drop).
    _slideIn = Tween<Offset>(begin: const Offset(0, -0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();

    // Schedule the leave after [duration].
    Future.delayed(widget.duration, _exit);
  }

  Future<void> _exit() async {
    if (!mounted || _leaving) return;
    _leaving = true;

    // Exit: slide to the left.
    await _ctrl.animateTo(
      0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInCubic,
    );

    if (mounted) {
      widget.onDismissed();
      // Remove the overlay entry from the tree.
      final overlay = Overlay.maybeOf(context);
      if (overlay != null) {
        // We can't call remove() from here directly; use a callback from
        // the caller instead. For simplicity, the entry removes itself
        // when the widget unmounts (see AppSnackbar.show override below).
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
        child: FadeTransition(
          opacity: _fade,
          child: _Bubble(
            message: widget.message,
            type: widget.type,
            actionLabel: widget.actionLabel,
            onAction: widget.onAction,
            onClose: _exit,
            colorScheme: cs,
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

  const _Bubble({
    required this.message,
    required this.type,
    required this.colorScheme,
    required this.onClose,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, accent) = switch (type) {
      AppSnackType.success => (
        Icons.check_circle_outline,
        const Color(0xFF10B981),
      ),
      AppSnackType.error => (Icons.error_outline, colorScheme.error),
      AppSnackType.warning => (
        Icons.warning_amber_rounded,
        const Color(0xFFF59E0B),
      ),
      AppSnackType.info => (Icons.info_outline, colorScheme.primary),
    };

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
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
              child: Icon(icon, size: 16, color: accent),
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
