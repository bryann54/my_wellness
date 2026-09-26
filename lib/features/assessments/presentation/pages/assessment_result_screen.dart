import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_toast_listener.dart';

@RoutePage()
class AssessmentResultScreen extends StatelessWidget {
  final String slug;
  const AssessmentResultScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AssessmentsBloc>(),
      child: AssessmentToastListener(child: _AssessmentResultBody(slug: slug)),
    );
  }
}

class _AssessmentResultBody extends StatefulWidget {
  final String slug;
  const _AssessmentResultBody({required this.slug});

  @override
  State<_AssessmentResultBody> createState() => _AssessmentResultBodyState();
}

class _AssessmentResultBodyState extends State<_AssessmentResultBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<AssessmentsBloc>();
      if (bloc.state.score == null) {
        bloc.add(const FetchScoreEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final score = context.select<AssessmentsBloc, AssessmentScore?>(
      (b) => b.state.score,
    );

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          CustomAppBar(
            title: AppLocalizations.getString(
              context,
              'assessment.resultTitle',
            ),
            isHome: false,
          ),
        ],
        body: score == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                children: [
                  _BandCard(score: score),
                  if (score.hasActiveWarning &&
                      score.symptomAlerts.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _WarningCard(alerts: score.symptomAlerts),
                  ],
                  if (score.contributing.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: AppLocalizations.getString(
                        context,
                        'assessment.contributing',
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final c in score.contributing)
                      _FactorRow(
                        item: c,
                        accent: Theme.of(context).colorScheme.error,
                      ),
                  ],
                  if (score.protective.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: AppLocalizations.getString(
                        context,
                        'assessment.protective',
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final p in score.protective)
                      _FactorRow(
                        item: p,
                        accent: const Color(0xFF10B981),
                      ),
                  ],
                  if (score.recommendations.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: AppLocalizations.getString(
                        context,
                        'assessment.recommendations',
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final r in score.recommendations)
                      _RecommendationRow(title: r.title, detail: r.detail),
                  ],
                  if (score.screeningRecommendation != null) ...[
                    const SizedBox(height: 24),
                    _ScreeningCard(rec: score.screeningRecommendation!),
                  ],
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BandCard extends StatelessWidget {
  final AssessmentScore score;
  const _BandCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = switch (score.band.toLowerCase()) {
      'low' => const Color(0xFF10B981),
      'moderate' => const Color(0xFFF59E0B),
      'higher' || 'high' => const Color(0xFFDC2626),
      _ => cs.primary,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            score.bandLabel.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          if (score.metric != null) ...[
            Text(
              score.metric!.value,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                height: 1.1,
              ),
            ),
            Text(
              score.metric!.label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
          if (score.bandBlurb != null) ...[
            const SizedBox(height: 14),
            Text(
              score.bandBlurb!,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  final List<SymptomAlert> alerts;
  const _WarningCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: cs.error, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.getString(context, 'assessment.warnings'),
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: cs.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final a in alerts) ...[
            Text(
              a.title,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: cs.onSurface,
              ),
            ),
            if (a.detail != null) ...[
              const SizedBox(height: 4),
              Text(
                a.detail!,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  height: 1.45,
                  color: cs.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  final ScoreItem item;
  final Color accent;

  const _FactorRow({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: cs.onSurface,
                  ),
                ),
                if (item.detail != null && item.detail!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.detail!,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.45,
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  final String title;
  final String? detail;

  const _RecommendationRow({required this.title, this.detail});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: cs.onSurface,
                  ),
                ),
                if (detail != null && detail!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail!,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.45,
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreeningCard extends StatelessWidget {
  final ScreeningRecommendation rec;
  const _ScreeningCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rec.title,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          if (rec.message != null) ...[
            const SizedBox(height: 8),
            Text(
              rec.message!,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ],
      ),
    );
  }
}