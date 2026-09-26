import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';

class CompleteRatingCard extends StatefulWidget {
  const CompleteRatingCard({super.key});

  @override
  State<CompleteRatingCard> createState() => _CompleteRatingCardState();
}

class _CompleteRatingCardState extends State<CompleteRatingCard> {
  int _rating = 0;
  bool _testimonial = false;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    HapticFeedback.lightImpact();
    // TODO: dispatch a SubmitRatingEvent when the endpoint is available.
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.getString(context, 'assessment.ratingThanks'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.getString(context, 'assessment.ratingTitle'),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.getString(context, 'assessment.ratingSubtitle'),
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.45,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (int i = 1; i <= 5; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _rating = i);
                    },
                    child: Icon(
                      i <= _rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 32,
                      color: i <= _rating
                          ? const Color(0xFFF59E0B)
                          : cs.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SoftInput(
            controller: _commentCtrl,
            hint: AppLocalizations.getString(
              context,
              'assessment.ratingCommentHint',
            ),
            maxLines: 3,
            minLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _testimonial,
                onChanged: (v) => setState(() => _testimonial = v ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    AppLocalizations.getString(
                      context,
                      'assessment.ratingTestimonialConsent',
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.45,
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: () => FocusScope.of(context).unfocus(),
                child: Text(
                  AppLocalizations.getString(
                    context,
                    'assessment.ratingMaybeLater',
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _rating == 0 ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  AppLocalizations.getString(
                    context,
                    'assessment.ratingSubmit',
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
