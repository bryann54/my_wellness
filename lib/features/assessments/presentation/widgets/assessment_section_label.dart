import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssessmentSectionLabel extends StatelessWidget {
  final String label;
  final Color? color;
  final Widget? leading;

  final Widget? trailing;

  const AssessmentSectionLabel(
    this.label, {
    super.key,
    this.color,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = leading != null
        ? cs.onSurface.withValues(alpha: 0.65)
        : (color ?? cs.onSurface.withValues(alpha: 0.55));

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: textColor,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
