import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';

class OnboardingTitle extends StatelessWidget {
  final String title;
  final String? highlight;

  const OnboardingTitle({super.key, required this.title, this.highlight});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      letterSpacing: -0.5,
    );

    if (highlight == null || !title.contains(highlight!)) {
      return Text(title, style: style, textAlign: TextAlign.center);
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
            style: const TextStyle(color: AppColors.primaryColor),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}
