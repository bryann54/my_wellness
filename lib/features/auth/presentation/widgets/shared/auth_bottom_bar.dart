import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthBottomBar extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onActionPressed;
  final String heroTag;

  const AuthBottomBar({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onActionPressed,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              promptText,
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
              ),
            ),
            Hero(
              tag: heroTag,
              child: TextButton(
                onPressed: onActionPressed,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionText,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
