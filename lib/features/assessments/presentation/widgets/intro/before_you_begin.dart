import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_definition.dart';

class BeforeYouBeginPages extends StatefulWidget {
  final String slug;
  final List<BeforeYouBeginPage> pages;
  final String shortTitle;
  final VoidCallback onCompleted;

  const BeforeYouBeginPages({
    super.key,
    required this.slug,
    required this.pages,
    required this.shortTitle,
    required this.onCompleted,
  });

  @override
  State<BeforeYouBeginPages> createState() => _BeforeYouBeginPagesState();
}

class _BeforeYouBeginPagesState extends State<BeforeYouBeginPages> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final page = widget.pages[_index];
    final last = _index == widget.pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.getString(context, 'assessment.beforeYouBegin').toUpperCase()} · ${widget.shortTitle.toUpperCase()}',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.t(context, 'common.itemOfTotal', {
                  'current': '${_index + 1}',
                  'total': '${widget.pages.length}',
                }),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        page.heading,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page.body,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.6,
                          color: cs.onSurface.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (_index > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _index--),
                        child: Text(
                          AppLocalizations.getString(context, 'common.back'),
                        ),
                      ),
                    ),
                  if (_index > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: _index > 0 ? 1 : 1,
                    child: AppPrimaryButton(
                      onPressed: () {
                        if (last) {
                          widget.onCompleted();
                        } else {
                          setState(() => _index++);
                        }
                      },
                      label: AppLocalizations.getString(
                        context,
                        last
                            ? 'assessment.continueToAssessment'
                            : 'common.continue',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
