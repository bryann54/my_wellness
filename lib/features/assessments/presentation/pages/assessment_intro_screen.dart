import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_card.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_intro_skeleton.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_toast_listener.dart';

const _consentRequiredSlugs = <String>{'ebola-screening'};

@RoutePage()
class AssessmentIntroScreen extends StatelessWidget {
  final String slug;
  final String? sessionId;
  final int? currentIndex;
  final int? totalQuestions;
  final int? completionPercent;

  const AssessmentIntroScreen({
    super.key,
    required this.slug,
    this.sessionId,
    this.currentIndex,
    this.totalQuestions,
    this.completionPercent,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AssessmentsBloc>(),
      child: AssessmentToastListener(
        child: _AssessmentIntroBody(
          slug: slug,
          sessionId: sessionId,
          currentIndex: currentIndex,
          totalQuestions: totalQuestions,
          completionPercent: completionPercent,
        ),
      ),
    );
  }
}

class _AssessmentIntroBody extends StatefulWidget {
  final String slug;
  final String? sessionId;
  final int? currentIndex;
  final int? totalQuestions;
  final int? completionPercent;

  const _AssessmentIntroBody({
    required this.slug,
    this.sessionId,
    this.currentIndex,
    this.totalQuestions,
    this.completionPercent,
  });

  @override
  State<_AssessmentIntroBody> createState() => _AssessmentIntroBodyState();
}

class _AssessmentIntroBodyState extends State<_AssessmentIntroBody> {
  bool _consented = false;

  bool get _requiresConsent => _consentRequiredSlugs.contains(widget.slug);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<AssessmentsBloc>();
      final sessionId = widget.sessionId;
      if (sessionId != null) {
        bloc.add(
          ResumeAssessmentsEvent(
            slug: widget.slug,
            sessionId: sessionId,
            currentIndex: widget.currentIndex ?? 0,
            totalQuestions: widget.totalQuestions ?? 1,
            completionPercent: widget.completionPercent ?? 0,
          ),
        );
      } else {
        bloc.add(StartAssessmentsEvent(widget.slug));
      }
    });
  }

  void _toggleConsent(bool? value) {
    if (value == null) return;
    HapticFeedback.selectionClick();
    setState(() => _consented = value);
  }

  bool get _canBegin => !_requiresConsent || _consented;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final def = context.select<AssessmentsBloc, dynamic>(
      (b) => b.state.definition,
    );
    final already = context.select<AssessmentsBloc, bool>(
      (b) => b.state.alreadyCompleted,
    );

    if (already) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.router.replace(AssessmentCompleteRoute(slug: widget.slug));
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(title: def?.shortTitle ?? '', isHome: false),
        ],
        body: def == null
            ? const Center(child: AssessmentIntroSkeleton())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: assessmentTitleTag(widget.slug),
                      flightShuttleBuilder: textShuttleBuilder,
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          def.title as String,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Hero(
                      tag: assessmentTaglineTag(widget.slug),
                      flightShuttleBuilder: textShuttleBuilder,
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          def.tagline as String,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            height: 1.5,
                            color: cs.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      AppLocalizations.getString(
                        context,
                        'assessment.understandingTitle',
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (def.understandingCopy != null)
                      Text(
                        def.understandingCopy as String,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          height: 1.55,
                          color: cs.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    const SizedBox(height: 28),
                    if (def.disclaimer != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.error.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          def.disclaimer as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.5,
                            color: cs.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    if (_requiresConsent) ...[
                      const SizedBox(height: 24),
                      _ConsentTile(
                        value: _consented,
                        onChanged: _toggleConsent,
                      ),
                    ],
                    const SizedBox(height: 36),
                    AppPrimaryButton(
                      onPressed: _canBegin
                          ? () => context.router.push(
                              AssessmentSessionRoute(slug: widget.slug),
                            )
                          : null,
                      label: AppLocalizations.getString(
                        context,
                        'assessment.begin',
                      ),
                      color: AppColors.primaryColor,
                      borderRadius: 12,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: cs.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.getString(context, 'assessment.consent'),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.45,
                  color: cs.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
