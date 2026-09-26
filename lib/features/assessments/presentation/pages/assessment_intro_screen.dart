import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_card.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_toast_listener.dart';

@RoutePage()
class AssessmentIntroScreen extends StatelessWidget {
  final String slug;
  const AssessmentIntroScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AssessmentsBloc>(),
      child: AssessmentToastListener(child: _AssessmentIntroBody(slug: slug)),
    );
  }
}

class _AssessmentIntroBody extends StatefulWidget {
  final String slug;
  const _AssessmentIntroBody({required this.slug});

  @override
  State<_AssessmentIntroBody> createState() => _AssessmentIntroBodyState();
}

class _AssessmentIntroBodyState extends State<_AssessmentIntroBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AssessmentsBloc>().add(StartAssessmentsEvent(widget.slug));
    });
  }

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
        headerSliverBuilder: (_, __) => [
          CustomAppBar(title: def?.shortTitle ?? '', isHome: false),
        ],
        body: def == null
            ? const Center(child: CircularProgressIndicator())
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
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.router.push(
                          AssessmentSessionRoute(slug: widget.slug),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: cs.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.getString(
                            context,
                            'assessment.begin',
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
