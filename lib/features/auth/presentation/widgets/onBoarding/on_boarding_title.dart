import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingTitle extends StatelessWidget {
  final String title;
  final String? highlight;

  const OnboardingTitle({super.key, required this.title, this.highlight});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.4,
      color: cs.onSurface,
    );

    if (highlight == null || !title.contains(highlight!)) {
      return Text(
        title,
        style: style,
        textAlign: TextAlign.center,
        maxLines: 3,
      );
    }

    final parts = title.split(highlight!);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: highlight,
            style: TextStyle(color: cs.primary),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}
