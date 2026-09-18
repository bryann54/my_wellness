// lib/common/widgets/custom_alert_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';

enum DialogType { info, success, warning, error, confirm }

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final DialogType type;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCancelButton;
  final bool showConfirmButton;
  final Color? confirmButtonColor;

  const CustomAlertDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.actions,
    this.type = DialogType.info,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.showCancelButton = true,
    this.showConfirmButton = true,
    this.confirmButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = confirmButtonColor ?? _getTypeColor(context);

    return AlertDialog.adaptive(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // Icons are ignored by Cupertino adaptive style automatically,
      // but stay present for Material.
      icon: _buildIcon(context, color),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: message != null
          ? Text(message!, textAlign: TextAlign.center)
          : content,
      actions: actions ??
          [
            if (showCancelButton)
              TextButton(
                onPressed: onCancel ?? () => Navigator.pop(context, false),
                child: Text(
                  cancelText ??
                      AppLocalizations.getString(context, 'common.cancel'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            if (showConfirmButton)
              TextButton(
                onPressed: onConfirm ?? () => Navigator.pop(context, true),
                child: Text(
                  confirmText ??
                      AppLocalizations.getString(context, 'common.confirm'),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
          ],
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required CustomAlertDialog dialog,
  }) {
    _triggerHaptics(dialog.type);
    // showAdaptiveDialog is the modern way to invoke adaptive alerts
    return showAdaptiveDialog<T>(
      context: context,
      barrierDismissible: dialog.type != DialogType.error,
      builder: (context) => dialog,
    );
  }

  static void _triggerHaptics(DialogType type) {
    if (type == DialogType.error) {
      HapticFeedback.heavyImpact();
    } else if (type == DialogType.success) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  Color _getTypeColor(BuildContext context) {
    return switch (type) {
      DialogType.success => Colors.green,
      DialogType.error => Theme.of(context).colorScheme.error,
      DialogType.warning => Colors.orange,
      _ => AppColors.accentColor,
    };
  }

  Widget? _buildIcon(BuildContext context, Color color) {
    // Icons only show in Material mode for a cleaner look
    IconData iconData = switch (type) {
      DialogType.success => Icons.check_circle_outline_rounded,
      DialogType.error => Icons.error_outline_rounded,
      DialogType.warning => Icons.warning_amber_rounded,
      _ => Icons.info_outline_rounded,
    };
    return Icon(iconData, size: 40, color: color);
  }
}

class AppDialogs {
  static Future<bool?> ask(
    BuildContext context, {
    required String title,
    required String message,
    bool isDestructive = false,
  }) {
    return CustomAlertDialog.show<bool>(
      context: context,
      dialog: CustomAlertDialog(
        title: title,
        message: message,
        type: isDestructive ? DialogType.error : DialogType.confirm,
      ),
    );
  }

  static Future<void> success(
    BuildContext context, {
    required String title,
    String? message,
  }) {
    return CustomAlertDialog.show(
      context: context,
      dialog: CustomAlertDialog(
        title: title,
        message: message,
        type: DialogType.success,
        showCancelButton: false,
      ),
    );
  }
}
