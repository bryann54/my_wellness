// lib/common/widgets/app_fab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/widgets/custom_alert_dialog.dart';

class AppFab extends StatelessWidget {
  const AppFab.extended({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
  }) : _variant = _FabVariant.extended,
       tooltip = null,
       _confirmTitle = null,
       _confirmMessage = null,
       _onConfirmed = null;

  const AppFab.compact({
    super.key,
    required Widget this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.tooltip,
  }) : _variant = _FabVariant.compact,
       label = null,
       _confirmTitle = null,
       _confirmMessage = null,
       _onConfirmed = null;

  const AppFab.delete({
    super.key,
    required String confirmTitle,
    required String confirmMessage,
    required VoidCallback onConfirmed,
  }) : _variant = _FabVariant.delete,
       label = null,
       icon = null,
       backgroundColor = null,
       onPressed = null,
       tooltip = null,
       _confirmTitle = confirmTitle,
       _confirmMessage = confirmMessage,
       _onConfirmed = onConfirmed;

  final _FabVariant _variant;

  final String? label;
  final Widget? icon;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final String? tooltip;

  final String? _confirmTitle;
  final String? _confirmMessage;
  final VoidCallback? _onConfirmed;

  @override
  Widget build(BuildContext context) {
    final child = switch (_variant) {
      _FabVariant.extended => _buildExtended(context),
      _FabVariant.compact => _buildCompact(context),
      _FabVariant.delete => _buildDelete(context),
    };

    return child
        .animate()
        .fadeIn(duration: 200.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          duration: 260.ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildExtended(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      heroTag: _heroTag,
      onPressed: _handleTap,
      backgroundColor: backgroundColor ?? cs.primary,
      foregroundColor: cs.onPrimary,
      icon: icon,
      label: Text(
        label ?? '',
        style: GoogleFonts.inter(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      elevation: 3,
      highlightElevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FloatingActionButton(
      heroTag: _heroTag,
      onPressed: _handleTap,
      backgroundColor: backgroundColor ?? cs.primary,
      foregroundColor: cs.onPrimary,
      tooltip: tooltip,
      elevation: 3,
      highlightElevation: 6,
      shape: const CircleBorder(),
      child: icon,
    );
  }

  Widget _buildDelete(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FloatingActionButton(
      heroTag: _heroTag,
      backgroundColor: cs.error,
      foregroundColor: cs.onError,
      elevation: 3,
      highlightElevation: 6,
      shape: const CircleBorder(),
      onPressed: () async {
        HapticFeedback.mediumImpact();
        final confirmed = await AppDialogs.ask(
          context,
          title: _confirmTitle!,
          message: _confirmMessage!,
          isDestructive: true,
        );
        if (confirmed == true && context.mounted) {
          HapticFeedback.heavyImpact();
          _onConfirmed?.call();
        }
      },
      child: const FaIcon(FontAwesomeIcons.trash, size: 16),
    );
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    onPressed?.call();
  }

  String get _heroTag => 'fab_${_variant.name}_$hashCode';
}

enum _FabVariant { extended, compact, delete }

class AppFabSlot extends StatelessWidget {
  final bool visible;
  final Widget child;

  const AppFabSlot({super.key, required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: visible
          ? KeyedSubtree(key: const ValueKey('fab-visible'), child: child)
          : const SizedBox.shrink(key: ValueKey('fab-hidden')),
    );
  }
}
