import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_capture_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/utils/classification_colors.dart';

@RoutePage()
class VitalsReadingEntryScreen extends StatelessWidget {
  final VitalsCaptureKind kind;
  const VitalsReadingEntryScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<VitalsCaptureBloc>(),
      child: kind == VitalsCaptureKind.bp ? const _BpForm() : const _BsForm(),
    );
  }
}

class _BpForm extends StatefulWidget {
  const _BpForm();

  @override
  State<_BpForm> createState() => _BpFormState();
}

class _BpFormState extends State<_BpForm> {
  final _formKey = GlobalKey<FormState>();
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _sysCtrl.addListener(_onChanged);
    _diaCtrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final sys = int.tryParse(_sysCtrl.text.trim());
    final dia = int.tryParse(_diaCtrl.text.trim());
    if (sys == null || dia == null) {
      context.read<VitalsCaptureBloc>().add(const ClearPreviewEvent());
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<VitalsCaptureBloc>().add(
        PreviewBpEvent(systolic: sys, diastolic: dia),
      );
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final payload = <String, dynamic>{
      'systolic': int.parse(_sysCtrl.text.trim()),
      'diastolic': int.parse(_diaCtrl.text.trim()),
      'pulse': int.parse(_pulseCtrl.text.trim()),
    };
    context.read<VitalsCaptureBloc>().add(SubmitVitalsReadingEvent(payload));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VitalsCaptureBloc>().state;
    final isSubmitting = state.step == VitalsCaptureStep.submitting;
    final preview = state.previewClassification;

    // Route based on server status. Only `done` is final.
    if (state.step == VitalsCaptureStep.done) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.router.replace(VitalsResultRoute(kind: state.kind!));
      });
    } else if (state.step == VitalsCaptureStep.awaitingSecondReading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.router.push(VitalsSecondReadingRoute(kind: state.kind!));
      });
    } else if (state.step == VitalsCaptureStep.awaitingWellbeing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.router.push(VitalsWellbeingRoute(kind: state.kind!));
      });
    }

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
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: [
              Text(
                AppLocalizations.getString(context, 'vitals.logBp'),
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: SoftInput(
                      controller: _sysCtrl,
                      label: 'Systolic',
                      suffixText: 'mmHg',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _requiredInt(50, 300),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SoftInput(
                      controller: _diaCtrl,
                      label: 'Diastolic',
                      suffixText: 'mmHg',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _requiredInt(30, 200),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SoftInput(
                controller: _pulseCtrl,
                label: 'Pulse',
                suffixText: 'bpm',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _requiredInt(20, 250),
              ),
              if (preview != null && preview != 'neutral') ...[
                const SizedBox(height: AppSpacing.md),
                _PreviewChip(classification: preview),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                onPressed: isSubmitting ? null : _submit,
                label: AppLocalizations.getString(context, 'common.save'),
                color: AppColors.primaryColor,
                borderRadius: 12,
                isLoading: isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? Function(String?) _requiredInt(int min, int max) => (v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Numbers only';
    if (n < min || n > max) return 'Must be $min–$max';
    return null;
  };
}

class _PreviewChip extends StatelessWidget {
  final String classification;

  const _PreviewChip({required this.classification});

  @override
  Widget build(BuildContext context) {
    final color = classificationColor(classification);
    final label = classification
        .split('_')
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join(' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            'Preview: $label',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BsForm extends StatefulWidget {
  const _BsForm();

  @override
  State<_BsForm> createState() => _BsFormState();
}

class _BsFormState extends State<_BsForm> {
  final _formKey = GlobalKey<FormState>();
  final _valueCtrl = TextEditingController();
  String _unit = 'mmol/L';
  String _readingType = 'random';
  String? _mealTiming;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _valueCtrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final value = double.tryParse(_valueCtrl.text.trim());
    if (value == null) {
      context.read<VitalsCaptureBloc>().add(const ClearPreviewEvent());
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<VitalsCaptureBloc>().add(
        PreviewBsEvent(
          value: _valueCtrl.text.trim(),
          unit: _unit,
          readingType: _readingType,
          mealTiming: _readingType == 'post_meal' ? _mealTiming : null,
        ),
      );
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final payload = <String, dynamic>{
      'value': _valueCtrl.text.trim(),
      if (_readingType != 'hba1c') 'unit': _unit,
      'reading_type': _readingType,
      if (_readingType == 'post_meal' && _mealTiming != null)
        'meal_timing': _mealTiming,
    };
    context.read<VitalsCaptureBloc>().add(SubmitVitalsReadingEvent(payload));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VitalsCaptureBloc>().state;
    final isSubmitting = state.step == VitalsCaptureStep.submitting;
    final preview = state.previewClassification;
    final isHba1c = _readingType == 'hba1c';
    final isPostMeal = _readingType == 'post_meal';

    if (state.step == VitalsCaptureStep.done) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.router.replace(VitalsResultRoute(kind: state.kind!));
      });
    }

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
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: [
              Text(
                AppLocalizations.getString(context, 'vitals.logBs'),
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SoftDropdown<String>(
                value: _readingType,
                label: 'Reading type',
                items: const [
                  DropdownMenuItem(value: 'random', child: Text('Random')),
                  DropdownMenuItem(value: 'fasting', child: Text('Fasting')),
                  DropdownMenuItem(value: 'pre_meal', child: Text('Pre-meal')),
                  DropdownMenuItem(
                    value: 'post_meal',
                    child: Text('Post-meal'),
                  ),
                  DropdownMenuItem(value: 'hba1c', child: Text('HbA1c')),
                ],
                onChanged: (v) => setState(() {
                  _readingType = v ?? 'random';
                  if (_readingType != 'post_meal') _mealTiming = null;
                }),
              ),
              if (isPostMeal) ...[
                const SizedBox(height: AppSpacing.md),
                SoftDropdown<String>(
                  value: _mealTiming,
                  label: 'Meal timing',
                  items: const [
                    DropdownMenuItem(
                      value: 'less_than_2h',
                      child: Text('Less than 2h'),
                    ),
                    DropdownMenuItem(
                      value: 'at_least_2h',
                      child: Text('At least 2h'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _mealTiming = v),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SoftInput(
                      controller: _valueCtrl,
                      label: isHba1c ? 'Value (%)' : 'Value',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v.trim());
                        if (n == null) return 'Numbers only';
                        return null;
                      },
                    ),
                  ),
                  if (!isHba1c) ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: SoftDropdown<String>(
                        value: _unit,
                        label: 'Unit',
                        items: const [
                          DropdownMenuItem(
                            value: 'mmol/L',
                            child: Text('mmol/L'),
                          ),
                          DropdownMenuItem(
                            value: 'mg/dL',
                            child: Text('mg/dL'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _unit = v ?? 'mmol/L'),
                      ),
                    ),
                  ],
                ],
              ),
              if (preview != null && preview != 'neutral') ...[
                const SizedBox(height: AppSpacing.md),
                _PreviewChip(classification: preview),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                onPressed: isSubmitting ? null : _submit,
                label: AppLocalizations.getString(context, 'common.save'),
                color: AppColors.primaryColor,
                borderRadius: 12,
                isLoading: isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
