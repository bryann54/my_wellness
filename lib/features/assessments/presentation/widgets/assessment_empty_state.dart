import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';

class AssessmentEmptyState extends StatelessWidget {
  final String query;
  final bool isSearching;
  final VoidCallback onClear;

  const AssessmentEmptyState({
    super.key,
    required this.query,
    required this.isSearching,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final title = isSearching
        ? AppLocalizations.t(context, 'assessment.emptySearchTitle', {
            'query': query,
          })
        : AppLocalizations.getString(context, 'assessment.emptyNoResultsTitle');

    final body = isSearching
        ? AppLocalizations.getString(context, 'assessment.emptySearchBody')
        : AppLocalizations.getString(context, 'assessment.emptyNoResultsBody');

    // `AlwaysScrollableScrollPhysics` keeps pull-to-refresh working on an
    // otherwise-empty list.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      children: [
        Icon(
          isSearching ? Icons.search_off_rounded : Icons.assignment_outlined,
          size: 48,
          color: cs.onSurface.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.45,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        if (isSearching) ...[
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: onClear,
              child: Text(
                AppLocalizations.getString(
                  context,
                  'assessment.emptySearchClear',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
