import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';

const _cancerTypes = <String>[
  'breast',
  'cervical',
  'prostate',
  'esophageal',
  'colorectal',
  'other',
];

String _cancerTypeLabel(BuildContext context, String value) {
  final key = switch (value) {
    'breast' => 'assessment.cancerBreast',
    'cervical' => 'assessment.cancerCervical',
    'prostate' => 'assessment.cancerProstate',
    'esophageal' => 'assessment.cancerOesophageal',
    'colorectal' => 'assessment.cancerColorectal',
    _ => 'assessment.cancerOther',
  };
  return AppLocalizations.getString(context, key);
}

class CancerPreScreeningGate extends StatefulWidget {
  final String slug;
  final String shortTitle;
  final String tagline;

  const CancerPreScreeningGate({
    super.key,
    required this.slug,
    required this.shortTitle,
    required this.tagline,
  });

  @override
  State<CancerPreScreeningGate> createState() => _CancerPreScreeningGateState();
}

class _CancerPreScreeningGateState extends State<CancerPreScreeningGate> {
  bool? _hasHistory;
  String? _type;
  int? _year;

  bool get _canSubmit {
    if (_hasHistory == null) return false;
    if (_hasHistory == true && _type == null) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final submitting =
        context.watch<AssessmentsBloc>().state.status ==
        AssessmentStatus.submitting;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Text(
              widget.shortTitle,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.tagline,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                AppLocalizations.getString(
                  context,
                  'assessment.healthInformation',
                ),
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.getString(
                context,
                'assessment.healthHistoryTitle',
              ),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.getString(
                context,
                'assessment.healthHistoryBody',
              ),
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            _Choice(
              label: AppLocalizations.getString(context, 'common.yes'),
              subtitle: AppLocalizations.getString(
                context,
                'assessment.yesCancerHistory',
              ),
              selected: _hasHistory == true,
              onTap: () => setState(() => _hasHistory = true),
            ),
            const SizedBox(height: 10),
            _Choice(
              label: AppLocalizations.getString(context, 'common.no'),
              subtitle: AppLocalizations.getString(
                context,
                'assessment.noCancerHistory',
              ),
              selected: _hasHistory == false,
              onTap: () => setState(() {
                _hasHistory = false;
                _type = null;
                _year = null;
              }),
            ),
            if (_hasHistory == true) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.getString(
                        context,
                        'assessment.diagnosisDetails',
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.getString(
                        context,
                        'assessment.diagnosisDetailsBody',
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        height: 1.4,
                        color: cs.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.getString(
                          context,
                          'assessment.cancerTypeQuestion',
                        ),
                      ),
                      items: [
                        for (final type in _cancerTypes)
                          DropdownMenuItem(
                            value: type,
                            child: Text(_cancerTypeLabel(context, type)),
                          ),
                      ],
                      onChanged: (v) => setState(() => _type = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _year,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.getString(
                          context,
                          'assessment.yearDiagnosedQuestion',
                        ),
                      ),
                      items: [
                        for (var y = DateTime.now().year; y >= 1940; y--)
                          DropdownMenuItem(value: y, child: Text('$y')),
                      ],
                      onChanged: (v) => setState(() => _year = v),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              onPressed: _canSubmit && !submitting
                  ? () {
                      context.read<AssessmentsBloc>().add(
                        SubmitCancerPreScreeningEvent(
                          priorCancerHistory: _hasHistory == true
                              ? 'yes'
                              : 'no',
                          priorCancerType: _hasHistory == true
                              ? (_type ?? '')
                              : '',
                          priorCancerYear: _hasHistory == true ? _year : null,
                        ),
                      );
                    }
                  : null,
              label: submitting
                  ? AppLocalizations.getString(context, 'assessment.submitting')
                  : AppLocalizations.getString(context, 'common.continue'),
              isLoading: submitting,
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _Choice({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.10) : cs.surface,
          border: Border.all(
            color: selected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.6),
            width: selected ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.4,
                color: cs.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
