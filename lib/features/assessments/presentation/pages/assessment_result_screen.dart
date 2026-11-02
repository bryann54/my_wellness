import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/hex_color.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_toast_listener.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_next_step.dart';

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
  final GlobalKey _checklistKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<AssessmentsBloc>();
      if (bloc.state.score == null) {
        bloc.add(const FetchScoreEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AssessmentsBloc>().state;
    final score = state.score;
    final firstName = _firstNameOf(
      context.watch<AccountBloc>().state.profile?.displayName,
    );

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(
            title: AppLocalizations.getString(
              context,
              'assessment.resultTitle',
            ),
            isHome: false,
          ),
        ],
        body: score == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator.adaptive(),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.getString(
                        context,
                        'assessment.loadingResult',
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                children: [
                  if (score.resultDisplay != null)
                    _ResultDisplayView(
                      score: score,
                      firstName: firstName,
                      referral: state.referral,
                      canRetake: state.canStart?.allowed == true,
                      shortTitle: state.definition?.shortTitle ?? '',
                      checklistKey: _checklistKey,
                      onCta: (key) {
                        final cta = state.definition?.ctaByKey(key);
                        if (cta == null) return;
                        // Booking feature owns the actual booking route;
                        // hook it here where that route exists.
                      },
                      onRetake: () => context.router.push(
                        AssessmentIntroRoute(slug: widget.slug),
                      ),
                      onDownload: () {
                        // §6 report download endpoint is a separate feature.
                      },
                      onEmail: () {
                        // §6 report email endpoint is a separate feature.
                      },
                    )
                  else
                    _LegacyScoreFallback(score: score),
                ],
              ),
      ),
    );
  }

  static String? _firstNameOf(String? display) {
    if (display == null) return null;
    final t = display.trim();
    if (t.isEmpty) return null;
    return t.split(RegExp(r'\s+')).first;
  }
}

class _ResultDisplayView extends StatelessWidget {
  final AssessmentScore score;
  final String? firstName;
  final Referral? referral;
  final bool canRetake;
  final String shortTitle;
  final GlobalKey checklistKey;
  final void Function(String key) onCta;
  final VoidCallback onRetake;
  final VoidCallback onDownload;
  final VoidCallback onEmail;

  const _ResultDisplayView({
    required this.score,
    required this.referral,
    required this.canRetake,
    required this.shortTitle,
    required this.checklistKey,
    required this.onCta,
    required this.onRetake,
    required this.onDownload,
    required this.onEmail,
    this.firstName,
  });

  ResultDisplay get d => score.resultDisplay!;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCancer = d.isCancerTiered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isCancer)
          _ResultCard(
            palette: _paletteFor(d.severity),
            display: d,
            checklistKey: checklistKey,
            onCta: onCta,
          )
        else
          _GenericResultCard(palette: _genericPalette(d), display: d),
        if (referral != null) ...[
          const SizedBox(height: 16),
          CompleteNextStep(referral: referral),
        ],
        if (isCancer && d.importantNotice != null) ...[
          const SizedBox(height: 16),
          _NoticeCard(
            notice: d.importantNotice!,
            personaliseFirstName: firstName,
            isSuccess: d.importantNotice!.heading == 'Congratulations!',
          ),
        ],
        if (isCancer && d.screeningSection != null) ...[
          const SizedBox(height: 16),
          _ScreeningCard(
            section: d.screeningSection!,
            shortTitle: shortTitle,
            firstName: firstName,
          ),
        ],
        if (!isCancer && d.screeningSection != null) ...[
          const SizedBox(height: 16),
          _GenericScreeningCard(section: d.screeningSection!, onCta: onCta),
        ],
        if (!isCancer &&
            d.ctaSection != null &&
            d.ctaSection!.items.isNotEmpty) ...[
          const SizedBox(height: 16),
          _GenericCtaCard(section: d.ctaSection!, onCta: onCta),
        ],
        const SizedBox(height: 16),
        _ReportCard(
          showReport: d.showReportCard,
          onDownload: onDownload,
          onEmail: onEmail,
        ),
        if (canRetake) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetake,
            child: Text(
              AppLocalizations.getString(context, 'assessment.retakeButton'),
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          child: Text(
            AppLocalizations.getString(context, 'assessment.backToDashboard'),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.getString(context, 'assessment.resultDisclaimer'),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            height: 1.4,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _ResultPalette palette;
  final ResultDisplay display;
  final GlobalKey checklistKey;
  final void Function(String key) onCta;

  const _ResultCard({
    required this.palette,
    required this.display,
    required this.checklistKey,
    required this.onCta,
  });

  void _scrollToChecklist() {
    final ctx = checklistKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final severityKey = display.severity ?? 'neutral';
    final colourName = AppLocalizations.getString(
      context,
      'assessment.severity.$severityKey',
    );
    final ctaLabel = _ctaLabelFor(context, display.severity);
    final firstCtaKey = display.ctaSection?.items.isNotEmpty == true
        ? display.ctaSection!.items.first.key
        : null;
    final isTrack =
        display.severity == 'good' || display.severity == 'attention';
    final showButton = ctaLabel != null && (isTrack || firstCtaKey != null);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.fill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.getString(context, 'assessment.resultKicker'),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: palette.accent,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              AppLocalizations.t(context, 'assessment.resultPill', {
                'colour': colourName,
              }),
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: palette.accent,
              ),
            ),
          ),
          if (display.title != null) ...[
            const SizedBox(height: 14),
            Text(
              display.title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: cs.onSurface,
              ),
            ),
          ],
          if (display.body != null) ...[
            const SizedBox(height: 8),
            Text(
              display.body!,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
          if (display.criticalNotice != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1EF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF3D6D2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    display.criticalNotice!.heading,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB84140),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    display.criticalNotice!.body,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.45,
                      color: cs.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (display.actionSummary != null)
            Column(
              key: checklistKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                Text(
                  display.actionSummary!.title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                for (final item in display.actionSummary!.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: palette.accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              height: 1.45,
                              color: cs.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          if (showButton) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isTrack
                    ? _scrollToChecklist
                    : () => onCta(firstCtaKey!),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(ctaLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String? _ctaLabelFor(BuildContext context, String? severity) {
    final key = 'assessment.ctaBySeverity.${severity ?? "neutral"}';
    final resolved = AppLocalizations.getString(context, key);
    return resolved == key ? null : resolved;
  }
}

class _GenericResultCard extends StatelessWidget {
  final _ResultPalette palette;
  final ResultDisplay display;

  const _GenericResultCard({required this.palette, required this.display});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = display;
    final label = [
      d.colourEmoji,
      d.colourLabel,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    final alerts = d.symptomAlertsSection;

    TextStyle body({
      double size = 13,
      FontWeight? weight,
      double alpha = 0.8,
    }) => GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: 1.5,
      color: cs.onSurface.withValues(alpha: alpha),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.fill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.getString(context, 'assessment.resultKicker'),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: palette.accent,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: palette.accent,
                ),
              ),
            ),
          ],
          if (d.categoryLabel != null && d.categoryLabel!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              d.categoryLabel!,
              style: body(size: 12, weight: FontWeight.w600, alpha: 0.6),
            ),
          ],
          if (d.title != null) ...[
            const SizedBox(height: 14),
            Text(
              d.title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: cs.onSurface,
              ),
            ),
          ],
          if (d.body != null) ...[
            const SizedBox(height: 8),
            Text(d.body!, style: body(size: 13.5)),
          ],
          if (d.metric != null) ...[
            const SizedBox(height: 14),
            Text(
              d.metric!.value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: palette.accent,
              ),
            ),
            Text(d.metric!.label, style: body(size: 12, alpha: 0.6)),
          ],
          if (d.recommendationHeading != null ||
              d.recommendationBody != null) ...[
            const SizedBox(height: 14),
            if (d.recommendationHeading != null)
              Text(
                d.recommendationHeading!,
                style: body(size: 13, weight: FontWeight.w700, alpha: 1),
              ),
            if (d.recommendationBody != null) ...[
              const SizedBox(height: 4),
              Text(d.recommendationBody!, style: body(size: 12.5)),
            ],
          ],
          if (d.observations.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final o in d.observations)
              _BulletRow(text: o, color: palette.accent),
          ],
          if (d.immediateRecommendation != null) ...[
            const SizedBox(height: 14),
            Text(d.immediateRecommendation!, style: body(size: 13)),
          ],
          if (d.nutritionRecommendation != null) ...[
            const SizedBox(height: 14),
            Text(
              d.nutritionRecommendation!.label,
              style: body(size: 13, weight: FontWeight.w700, alpha: 1),
            ),
            if (d.nutritionRecommendation!.description != null) ...[
              const SizedBox(height: 4),
              Text(
                d.nutritionRecommendation!.description!,
                style: body(size: 12.5),
              ),
            ],
          ],
          if (alerts != null && alerts.alerts.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              alerts.heading,
              style: body(size: 13, weight: FontWeight.w700, alpha: 1),
            ),
            if (alerts.intro != null) ...[
              const SizedBox(height: 4),
              Text(alerts.intro!, style: body(size: 12.5)),
            ],
            const SizedBox(height: 8),
            for (final a in alerts.alerts)
              _BulletRow(
                text: a.detail != null ? '${a.title} — ${a.detail}' : a.title,
                color: palette.accent,
              ),
            if (alerts.outro != null) ...[
              const SizedBox(height: 4),
              Text(alerts.outro!, style: body(size: 12.5)),
            ],
          ],
          if (d.importantNote != null) ...[
            const SizedBox(height: 14),
            Text(d.importantNote!, style: body(size: 12.5, alpha: 0.7)),
          ],
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  final Color color;
  const _BulletRow({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.45,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenericScreeningCard extends StatelessWidget {
  final ScreeningSection section;
  final void Function(String key) onCta;

  const _GenericScreeningCard({required this.section, required this.onCta});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = section.due
        ? const Color(0xFFB84140)
        : const Color(0xFF158370);
    final lead = section.message ?? section.intro;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: section.due ? const Color(0xFFFFF1EF) : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: section.due
              ? const Color(0xFFF3D6D2)
              : cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.heading != null)
            Text(
              section.heading!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: section.due ? accent : cs.onSurface,
              ),
            ),
          if (lead != null) ...[
            const SizedBox(height: 6),
            Text(
              lead,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
          if (section.bullets.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final b in section.bullets) _BulletRow(text: b, color: accent),
          ],
          if (section.ctas.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in section.ctas)
                  FilledButton(
                    onPressed: () => onCta(c.key),
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    child: Text(c.label),
                  ),
              ],
            ),
          ],
          if (section.independenceNote != null) ...[
            const SizedBox(height: 10),
            Text(
              section.independenceNote!,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                height: 1.45,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GenericCtaCard extends StatelessWidget {
  final CtaSection section;
  final void Function(String key) onCta;

  const _GenericCtaCard({required this.section, required this.onCta});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (section.heading != null)
            Text(
              section.heading!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          if (section.subheading != null) ...[
            const SizedBox(height: 4),
            Text(
              section.subheading!,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.45,
                color: cs.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
          const SizedBox(height: 10),
          for (final item in section.items) ...[
            OutlinedButton(
              onPressed: () => onCta(item.key),
              child: Text(item.label),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final NoticeBlock notice;
  final String? personaliseFirstName;
  final bool isSuccess;

  const _NoticeCard({
    required this.notice,
    this.personaliseFirstName,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final heading =
        notice.heading == 'Congratulations!' &&
            personaliseFirstName != null &&
            personaliseFirstName!.isNotEmpty
        ? AppLocalizations.t(
            context,
            'assessment.importantNoticeCongratulations',
            {'firstName': personaliseFirstName!},
          )
        : notice.heading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isSuccess) ...[
                Icon(Icons.check_circle, size: 18, color: cs.primary),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  heading,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            notice.body,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.5,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreeningCard extends StatelessWidget {
  final ScreeningSection section;
  final String shortTitle;
  final String? firstName;

  const _ScreeningCard({
    required this.section,
    required this.shortTitle,
    this.firstName,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final organ = _organFrom(shortTitle);
    final pill = _pillFor(context, section.statusCode, organ, firstName);
    final pillColor = _pillColor(section.statusCode);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.t(context, 'assessment.screeningKicker', {
              'shortTitle': shortTitle,
            }),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.getString(context, 'assessment.screeningHeading'),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          if (pill != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: pillColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                pill,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: pillColor,
                ),
              ),
            ),
          ],
          if (section.method != null) ...[
            const SizedBox(height: 12),
            Text(
              section.method!,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ],
          if (section.description != null) ...[
            const SizedBox(height: 6),
            Text(
              section.description!,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.45,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
          if (section.interval != null || section.basis != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _FactCell(
                    label: AppLocalizations.getString(
                      context,
                      'assessment.screeningIntervalLabel',
                    ),
                    value:
                        section.interval ??
                        AppLocalizations.getString(
                          context,
                          'assessment.screeningIntervalFallback',
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FactCell(
                    label: AppLocalizations.getString(
                      context,
                      'assessment.screeningBasisLabel',
                    ),
                    value:
                        section.basis ??
                        AppLocalizations.getString(
                          context,
                          'assessment.screeningBasisFallback',
                        ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _organFrom(String shortTitle) {
    final t = shortTitle.toLowerCase().replaceAll('cancer', '').trim();
    return t.isEmpty ? shortTitle : t;
  }

  static String? _pillFor(
    BuildContext context,
    String? code,
    String organ,
    String? firstName,
  ) {
    if (code == null) return null;
    final hasName = firstName != null && firstName.isNotEmpty;
    final key = 'assessment.screeningStatus.$code${hasName ? "Named" : ""}';
    final params = <String, String>{
      'organ': organ,
      if (hasName) 'firstName': firstName,
    };
    final resolved = AppLocalizations.t(context, key, params);
    return resolved == key ? null : resolved;
  }

  static Color _pillColor(String? code) => switch (code) {
    'due' => const Color(0xFFC46E2B),
    'upToDate' => const Color(0xFF158370),
    'highrisk' => const Color(0xFFB84140),
    _ => const Color(0xFF6B7280),
  };
}

class _FactCell extends StatelessWidget {
  final String label;
  final String value;
  const _FactCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final bool showReport;
  final VoidCallback onDownload;
  final VoidCallback onEmail;

  const _ReportCard({
    required this.showReport,
    required this.onDownload,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    if (!showReport) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.getString(context, 'assessment.reportTitle'),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: onDownload,
                child: Text(
                  AppLocalizations.getString(
                    context,
                    'assessment.reportDownload',
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: onEmail,
                child: Text(
                  AppLocalizations.getString(context, 'assessment.reportEmail'),
                ),
              ),
              OutlinedButton(
                onPressed: onEmail,
                child: Text(
                  AppLocalizations.getString(context, 'assessment.reportShare'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultPalette {
  final Color accent;
  final Color fill;
  final Color border;
  const _ResultPalette({
    required this.accent,
    required this.fill,
    required this.border,
  });
}

_ResultPalette _genericPalette(ResultDisplay d) {
  final c = d.color;
  if (c == null) return _paletteFor(d.severity);
  final accent = hexToColor(c.accent);
  return _ResultPalette(
    accent: accent,
    fill: hexToColor(c.background),
    border: accent.withValues(alpha: 0.25),
  );
}

_ResultPalette _paletteFor(String? severity) => switch (severity) {
  'good' => const _ResultPalette(
    accent: Color(0xFF158370),
    fill: Color(0xFFEDF8F3),
    border: Color(0xFFCCE9DC),
  ),
  'attention' => const _ResultPalette(
    accent: Color(0xFFB47C12),
    fill: Color(0xFFFFF8E9),
    border: Color(0xFFF4DFAE),
  ),
  'concern' => const _ResultPalette(
    accent: Color(0xFFC46E2B),
    fill: Color(0xFFFFF5EB),
    border: Color(0xFFF4DAC4),
  ),
  'urgent' => const _ResultPalette(
    accent: Color(0xFFB84140),
    fill: Color(0xFFFFF1EF),
    border: Color(0xFFF3D6D2),
  ),
  _ => const _ResultPalette(
    accent: Color(0xFF6B7280),
    fill: Color(0xFFF3F4F6),
    border: Color(0xFFE5E7EB),
  ),
};

class _LegacyScoreFallback extends StatelessWidget {
  final AssessmentScore score;
  const _LegacyScoreFallback({required this.score});

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
        color: color.withValues(alpha: 0.08),
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
          if (score.bandBlurb != null) ...[
            const SizedBox(height: 12),
            Text(score.bandBlurb!),
          ],
        ],
      ),
    );
  }
}
