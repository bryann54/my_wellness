import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';

class AssessmentSearchResultCount extends StatelessWidget {
  final int count;
  final String query;

  const AssessmentSearchResultCount({
    super.key,
    required this.count,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = count == 1
        ? AppLocalizations.t(context, 'assessment.searchResultCountOne', {
            'query': query,
          })
        : AppLocalizations.t(context, 'assessment.searchResultCountMany', {
            'count': '$count',
            'query': query,
          });

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: cs.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
