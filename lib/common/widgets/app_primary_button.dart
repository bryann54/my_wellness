// lib/common/widgets/app_primary_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? color;
  final Color? textColor;
  final bool? disabled;
  final double? borderRadius;

  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.color,
    this.textColor,
    this.disabled,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveColor = color ?? cs.primary;
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveRadius = borderRadius ?? 25.0;
    final isDisabled = disabled ?? (onPressed == null || isLoading);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: FilledButton(
        onPressed: isDisabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        style: FilledButton.styleFrom(
          backgroundColor: isDisabled
              ? cs.onSurface.withValues(alpha: 0.12)
              : effectiveColor,
          foregroundColor: isDisabled
              ? cs.onSurface.withValues(alpha: 0.38)
              : effectiveTextColor,
          disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
          padding: EdgeInsets.symmetric(
            vertical: height != null ? 0 : 16,
            horizontal: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDisabled
                            ? cs.onSurface.withValues(alpha: 0.38)
                            : effectiveTextColor,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
