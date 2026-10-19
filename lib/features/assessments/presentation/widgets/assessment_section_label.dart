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
    final textColor = color ?? cs.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: textColor,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
