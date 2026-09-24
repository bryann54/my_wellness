import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/debouncer.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';

class AssessmentBmiStep extends StatefulWidget {
  final String? initialWeightKg;
  final String? initialHeightCm;
  final VoidCallback onContinue;
  final bool submitting;

  const AssessmentBmiStep({
    super.key,
    this.initialWeightKg,
    this.initialHeightCm,
    required this.onContinue,
    this.submitting = false,
  });

  @override
  State<AssessmentBmiStep> createState() => _AssessmentBmiStepState();
}

class _AssessmentBmiStepState extends State<AssessmentBmiStep> {
  late final TextEditingController _weightCtrl = TextEditingController(
    text: widget.initialWeightKg ?? '',
  );
  late final TextEditingController _heightCtrl = TextEditingController(
    text: widget.initialHeightCm ?? '',
  );

  final _weightDebounce = Debouncer(milliseconds: 600);
  final _heightDebounce = Debouncer(milliseconds: 600);
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Kick an initial preview if we resumed with values already filled.
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerPreview());
  }

  @override
  void dispose() {
    _weightDebounce.cancel();
    _heightDebounce.cancel();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _triggerPreview() {
    final w = _weightCtrl.text.trim();
    final h = _heightCtrl.text.trim();
    if (w.isEmpty || h.isEmpty) return;
    context.read<AssessmentsBloc>().add(
      PreviewBmiEvent(weightKg: w, heightCm: h),
    );
  }

  void _onChanged() {
    _weightDebounce.run(_triggerPreview);
    _heightDebounce.run(_triggerPreview);
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AssessmentsBloc>().add(
      SubmitBmiEvent(
        weightKg: _weightCtrl.text.trim(),
        heightCm: _heightCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final preview = context.select<AssessmentsBloc, dynamic>(
      (b) => b.state.bmiPreview,
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.getString(context, 'assessment.bmi.title'),
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.getString(context, 'assessment.bmi.subtitle'),
            style: GoogleFonts.inter(
              fontSize: 13.5,
              height: 1.5,
              color: cs.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 24),
  Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SoftInput(
                  controller: _weightCtrl,
                  label: AppLocalizations.getString(
                    context,
                    'assessment.bmi.weightLabel',
                  ),
                  hint: 'e.g. 76',
                  suffixText: 'kg',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (_) => _onChanged(),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SoftInput(
                  controller: _heightCtrl,
                  label: AppLocalizations.getString(
                    context,
                    'assessment.bmi.heightLabel',
                  ),
                  hint: 'e.g. 177',
                  suffixText: 'cm',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (_) => _onChanged(),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
        
          const SizedBox(height: 20),
          if (preview != null)
            _BmiPreviewCard(
              bmi: preview.bmi as double,
              classification: preview.classification as String,
              deficitKg: preview.deficitKg as double,
            ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: widget.submitting ? null : _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    AppLocalizations.getString(context, 'common.continue'),
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BmiPreviewCard extends StatelessWidget {
  final double bmi;
  final String classification;
  final double deficitKg;

  const _BmiPreviewCard({
    required this.bmi,
    required this.classification,
    required this.deficitKg,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (color, label) = switch (classification.toLowerCase()) {
      'underweight' => (const Color(0xFF3B82F6), 'Underweight'),
      'normal' => (const Color(0xFF10B981), 'Healthy'),
      'overweight' => (const Color(0xFFF59E0B), 'Overweight'),
      'obese' => (const Color(0xFFDC2626), 'Obese'),
      _ => (cs.primary, classification),
    };

    final showDeficit = deficitKg > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              bmi.toStringAsFixed(1),
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR BMI',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  switch (classification.toLowerCase()) {
                    'underweight' =>
                      'BMI below 18.5 — a balanced diet can help.',
                    'normal' => 'BMI 18.5–24.9 — keep up the healthy habits.',
                    'overweight' =>
                      'BMI 25–29.9 — small lifestyle changes can lower long-term risk.',
                    'obese' => 'BMI 30+ — a care plan can help reduce risk.',
                    _ => '',
                  },
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.45,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (showDeficit) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Lose about ${deficitKg.toStringAsFixed(1)} kg to reach a healthy weight.',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: color,
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
