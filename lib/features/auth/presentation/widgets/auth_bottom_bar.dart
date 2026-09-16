import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';

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
    final theme = Theme.of(context);
    final promptColor =
        (theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface)
            .withValues(alpha: 0.7);

    return Container(
      color: colorPrimary.withValues(alpha: .2),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                promptText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: promptColor),
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
                  style: GoogleFonts.poppins(
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
