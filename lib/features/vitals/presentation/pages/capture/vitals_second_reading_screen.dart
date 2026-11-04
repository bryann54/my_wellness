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
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_capture_bloc.dart';

@RoutePage()
class VitalsSecondReadingScreen extends StatelessWidget {
  final VitalsCaptureKind kind;
  const VitalsSecondReadingScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<VitalsCaptureBloc>(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _formKey = GlobalKey<FormState>();
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();

  @override
  void dispose() {
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final payload = <String, dynamic>{
      'systolic': int.parse(_sysCtrl.text.trim()),
      'diastolic': int.parse(_diaCtrl.text.trim()),
      'pulse': int.parse(_pulseCtrl.text.trim()),
    };
    context.read<VitalsCaptureBloc>().add(
      SubmitVitalsSecondReadingEvent(payload),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VitalsCaptureBloc>().state;
    final isSubmitting = state.step == VitalsCaptureStep.submitting;

    if (state.step == VitalsCaptureStep.done) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.router.replace(VitalsResultRoute(kind: state.kind!));
      });
    } else if (state.step == VitalsCaptureStep.awaitingWellbeing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.router.replace(VitalsWellbeingRoute(kind: state.kind!));
      });
    }

    final result = state.result;

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
                'Repeat the reading',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (result?.finalRecommendation.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  result!.finalRecommendation,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
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
