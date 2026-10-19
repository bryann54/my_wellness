import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_capture_bloc.dart';

@RoutePage()
class VitalsBmiScreen extends StatelessWidget {
  final VitalsCaptureKind kind;
  const VitalsBmiScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<VitalsCaptureBloc>()),
        BlocProvider.value(value: context.read<AssessmentsBloc>()),
      ],
      child: _Body(kind: kind),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.kind});
  final VitalsCaptureKind kind;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final state = context.read<VitalsCaptureBloc>().state;
    if (state.weightKg != null) {
      _weightCtrl.text = state.weightKg!.toStringAsFixed(1);
    }
    if (state.heightCm != null) {
      _heightCtrl.text = state.heightCm!.toStringAsFixed(1);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerPreview());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    context.read<AssessmentsBloc>().add(const ClearBmiPreviewEvent());
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _triggerPreview);
  }

  void _triggerPreview() {
    final w = _weightCtrl.text.trim();
    final h = _heightCtrl.text.trim();
    final weightKg = double.tryParse(w);
    final heightCm = double.tryParse(h);
    if (weightKg == null ||
        heightCm == null ||
        !weightKg.isFinite ||
        !heightCm.isFinite ||
        weightKg <= 0 ||
        heightCm <= 0) {
      return;
    }
    context.read<AssessmentsBloc>().add(
      PreviewBmiEvent(weightKg: w, heightCm: h),
    );
  }

  String? get _currentInputKey {
    final weightKg = double.tryParse(_weightCtrl.text.trim());
    final heightCm = double.tryParse(_heightCtrl.text.trim());
    if (weightKg == null ||
        heightCm == null ||
        !weightKg.isFinite ||
        !heightCm.isFinite ||
        weightKg <= 0 ||
        heightCm <= 0) {
      return null;
    }
    return '${weightKg.toString()}|${heightCm.toString()}';
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final bmiState = context.read<AssessmentsBloc>().state;
    final preview = bmiState.bmiPreview;
    if (preview == null || bmiState.bmiPreviewInputKey != _currentInputKey) {
      return;
    }
    context.read<VitalsCaptureBloc>().add(
      ConfirmBmiEvent(
        weightKg: double.parse(_weightCtrl.text.trim()),
        heightCm: double.parse(_heightCtrl.text.trim()),
        bmi: preview.bmi,
      ),
    );
    context.router.push(VitalsReadingEntryRoute(kind: widget.kind));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bmiState = context.watch<AssessmentsBloc>().state;
    final preview = bmiState.bmiPreview;
    final isPreviewReady =
        preview != null &&
        bmiState.bmiPreviewInputKey == _currentInputKey &&
        !bmiState.bmiPreviewLoading;
    final canContinue = isPreviewReady && !bmiState.bmiPreviewLoading;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(
            title: AppLocalizations.getString(context, 'vitals.title'),
            isHome: false,
          ),
        ],
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
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
                        'assessment.bmi.weightKg',
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
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return AppLocalizations.getString(
                            context,
                            'common.required',
                          );
                        }
                        final n = double.tryParse(v.trim());
                        if (n == null) {
                          return AppLocalizations.getString(
                            context,
                            'vitals.bmiNumbersOnly',
                          );
                        }
                        if (n < 20 || n > 400) {
                          return AppLocalizations.getString(
                            context,
                            'vitals.bmiWeightRange',
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SoftInput(
                      controller: _heightCtrl,
                      label: AppLocalizations.getString(
                        context,
                        'assessment.bmi.heightCm',
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
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return AppLocalizations.getString(
                            context,
                            'common.required',
                          );
                        }
                        final n = double.tryParse(v.trim());
                        if (n == null) {
                          return AppLocalizations.getString(
                            context,
                            'vitals.bmiNumbersOnly',
                          );
                        }
                        if (n < 60 || n > 250) {
                          return AppLocalizations.getString(
                            context,
                            'vitals.bmiHeightRange',
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isPreviewReady)
                _BmiPreviewCard(
                  bmi: preview.bmi,
                  classification: preview.classification,
                  deficitKg: preview.deficitKg,
                ),
              const SizedBox(height: 28),
              AppPrimaryButton(
                onPressed: canContinue ? _submit : null,
                label: AppLocalizations.getString(context, 'common.continue'),
                color: cs.primary,
                borderRadius: 12,
                isLoading: bmiState.bmiPreviewLoading,
                disabled: !canContinue,
              ),
            ],
          ),
        ),
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
        borderRadius: BorderRadius.circular(12),
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
