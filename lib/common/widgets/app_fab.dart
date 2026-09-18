// lib/common/widgets/app_fab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/widgets/custom_alert_dialog.dart';

class AppFab extends StatelessWidget {
  const AppFab.extended({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
  })  : _isDelete = false,
        _confirmTitle = null,
        _confirmMessage = null,
        _onConfirmed = null;

  const AppFab.delete({
    super.key,
    required String confirmTitle,
    required String confirmMessage,
    required VoidCallback onConfirmed,
  })  : _isDelete = true,
        label = null,
        icon = null,
        backgroundColor = null,
        onPressed = null,
        _confirmTitle = confirmTitle,
        _confirmMessage = confirmMessage,
        _onConfirmed = onConfirmed;

  final bool _isDelete;

  // Extended
  final String? label;
  final Widget? icon;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  // Delete
  final String? _confirmTitle;
  final String? _confirmMessage;
  final VoidCallback? _onConfirmed;

  @override
  Widget build(BuildContext context) {
    final fab = _isDelete ? _buildDelete(context) : _buildExtended(context);

    return fab
        .animate(delay: 300.ms)
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.6, 0.6), curve: Curves.easeOutBack);
  }

  Widget _buildExtended(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'fab_extended_${label ?? 'default'}',
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed?.call();
      },
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      icon: icon,
      label: Text(
        label ?? '',
        style: GoogleFonts.syne(fontWeight: FontWeight.w700),
      ),
      elevation: 2,
    );
  }

  Widget _buildDelete(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FloatingActionButton(
      heroTag: 'fab_delete',
      backgroundColor: AppColors.errorDark.withValues(alpha: .9),
      foregroundColor: cs.onError,
      elevation: 2,
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
      child: const FaIcon(FontAwesomeIcons.trash, size: 18),
    );
  }
}
