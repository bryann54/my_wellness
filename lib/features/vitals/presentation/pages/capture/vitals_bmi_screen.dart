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
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/domain/entities/bmi_measurement.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_capture_bloc.dart';

@RoutePage()
class VitalsBmiScreen extends StatelessWidget {
  const VitalsBmiScreen({super.key, required this.kind});

  final VitalsCaptureKind kind;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<VitalsCaptureBloc>()),
        BlocProvider.value(value: context.read<AccountBloc>()),
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
  bool _isSaving = false;
  BmiMeasurement? _pendingMeasurement;

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
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  BmiMeasurement? get _measurement {
    final weightKg = double.tryParse(_weightCtrl.text.trim());
    final heightCm = double.tryParse(_heightCtrl.text.trim());
    if (weightKg == null || heightCm == null) return null;
    try {
      return BmiMeasurement.calculate(weightKg: weightKg, heightCm: heightCm);
    } on FormatException {
      return null;
    }
  }

  bool get _bothBlank =>
      _weightCtrl.text.trim().isEmpty && _heightCtrl.text.trim().isEmpty;

  String? _validateMeasurement(String? _) {
    if (_bothBlank || _measurement != null) return null;
    return AppLocalizations.getString(context, 'vitals.bmiBothOrBlank');
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final measurement = _measurement;
    if (!_bothBlank && measurement == null) return;

    setState(() {
      _isSaving = true;
      _pendingMeasurement = measurement;
    });
    context.read<AccountBloc>().add(
      UpdateProfileEvent(
        updatedData: measurement == null
            ? const {'bmi_prompt_skipped': true}
            : {
                'weight_kg': measurement.weightKg,
                'height_cm': measurement.heightCm,
              },
      ),
    );
  }

  void _onProfileState(BuildContext context, AccountState state) {
    if (!_isSaving) return;
    if (state.status == AccountStatus.error) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.errorMessage ??
                AppLocalizations.getString(context, 'common.error'),
          ),
        ),
      );
      return;
    }
    if (state.status != AccountStatus.updated) return;

    final measurement = _pendingMeasurement;
    final capture = context.read<VitalsCaptureBloc>();
    if (measurement == null) {
      capture.add(const SkipBmiEvent());
    } else {
      capture.add(
        ConfirmBmiEvent(
          weightKg: measurement.weightKg,
          heightCm: measurement.heightCm,
          bmi: measurement.bmi,
        ),
      );
    }
    context.router.push(VitalsReadingEntryRoute(kind: widget.kind));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final measurement = _measurement;
    final canContinue = !_isSaving && (_bothBlank || measurement != null);

    return BlocListener<AccountBloc, AccountState>(
      listener: _onProfileState,
      child: Scaffold(
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
                  AppLocalizations.getString(
                    context,
                    'assessment.bmi.subtitle',
                  ),
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
                        onChanged: (_) => setState(() {}),
                        validator: _validateMeasurement,
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
                        onChanged: (_) => setState(() {}),
                        validator: _validateMeasurement,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (measurement != null)
                  _BmiPreviewCard(measurement: measurement),
                const SizedBox(height: 28),
                AppPrimaryButton(
                  onPressed: canContinue ? _submit : null,
                  label: AppLocalizations.getString(context, 'common.continue'),
                  color: cs.primary,
                  borderRadius: 12,
                  isLoading: _isSaving,
                  disabled: !canContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BmiPreviewCard extends StatelessWidget {
  const _BmiPreviewCard({required this.measurement});

  final BmiMeasurement measurement;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final within = measurement.category == BmiCategory.withinReference;
    final color = within ? const Color(0xFF10B981) : const Color(0xFFDC2626);
    final label = switch (measurement.category) {
      BmiCategory.belowReference => 'Below reference range',
      BmiCategory.withinReference => 'Within reference range',
      BmiCategory.aboveReference => 'Above reference range',
      BmiCategory.wellAboveReference => 'Well above reference range',
    };
    final guidance = switch (measurement.category) {
      BmiCategory.belowReference =>
        'Reference weight ${measurement.referenceWeightLowKg.toStringAsFixed(1)}–${measurement.referenceWeightHighKg.toStringAsFixed(1)} kg; current weight ${measurement.weightKg.toStringAsFixed(1)} kg. Weight loss is not recommended based on this BMI. Consider discussing nutrition and your weight with a healthcare professional.',
      BmiCategory.withinReference =>
        'Reference weight ${measurement.referenceWeightLowKg.toStringAsFixed(1)}–${measurement.referenceWeightHighKg.toStringAsFixed(1)} kg; current weight ${measurement.weightKg.toStringAsFixed(1)} kg. Your BMI is within the general adult reference range. Maintain healthy habits; BMI alone does not determine overall health.',
      BmiCategory.aboveReference || BmiCategory.wellAboveReference =>
        'A BMI near 24.9 corresponds to approximately ${measurement.referenceWeightHighKg.toStringAsFixed(1)} kg. Weight difference ${measurement.weightDifferenceKg.toStringAsFixed(1)} kg. An illustrative first milestone is ${measurement.firstMilestoneKg.toStringAsFixed(1)} kg (about ${(measurement.weightKg - measurement.firstMilestoneKg).toStringAsFixed(1)} kg body weight). Discuss goals with your clinician.',
    };

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
              measurement.bmi.toStringAsFixed(1),
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
                  'YOUR CALCULATED BMI',
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
                  guidance,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.45,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
