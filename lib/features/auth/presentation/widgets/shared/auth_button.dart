import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.heroTag,
    this.icon,
    this.variant = AuthButtonVariant.primary,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;
  final String? heroTag;
  final IconData? icon;
  final AuthButtonVariant variant;

  bool get _interactive => enabled && !isLoading;

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);
    if (heroTag == null) return button;

    return Hero(
      tag: heroTag!,
      flightShuttleBuilder: (_, __, direction, fromContext, toContext) {
        return direction == HeroFlightDirection.push
            ? toContext.widget
            : fromContext.widget;
      },
      child: button,
    );
  }

  Widget _buildButton(BuildContext context) {
    final child = _buildChild(context);

    switch (variant) {
      case AuthButtonVariant.primary:
        return SizedBox(
          height: 52,
          width: double.infinity,
          child: FilledButton(
            onPressed: _interactive ? onPressed : null,
            child: child,
          ),
        );
      case AuthButtonVariant.outlined:
        return SizedBox(
          height: 52,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _interactive ? onPressed : null,
            child: child,
          ),
        );
    }
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation(
            Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );
    }

    if (icon == null) {
      return Text(text, overflow: TextOverflow.ellipsis);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

enum AuthButtonVariant { primary, outlined }
