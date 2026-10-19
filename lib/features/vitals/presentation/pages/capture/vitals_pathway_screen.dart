import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_choice_tile.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_multi_choice_tile.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_option.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_capture_bloc.dart';

@RoutePage()
class VitalsPathwayScreen extends StatelessWidget {
  final VitalsCaptureKind kind;
  const VitalsPathwayScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<VitalsCaptureBloc>(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VitalsCaptureBloc>().state;
    final cs = Theme.of(context).colorScheme;
    final pathway = state.content?.pathway;

    if (pathway == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(
            title: AppLocalizations.getString(context, 'vitals.title'),
            isHome: false,
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            _QuestionLabel(text: pathway.pathwayQuestion),
            const SizedBox(height: AppSpacing.md),
            for (final opt in pathway.pathwayOptions) ...[
              AssessmentChoiceTile(
                option: AssessmentOption(value: opt.value, label: opt.label),
                selected: state.pathwayValue == opt.value,
                onTap: () => context.read<VitalsCaptureBloc>().add(
                  SelectPathwayEvent(opt.value),
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (state.needsProviderPlan &&
                pathway.providerPlanQuestion != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _QuestionLabel(text: pathway.providerPlanQuestion!),
              const SizedBox(height: AppSpacing.md),
              for (final opt in pathway.providerPlanOptions) ...[
                AssessmentChoiceTile(
                  option: AssessmentOption(value: opt.value, label: opt.label),
                  selected: state.providerPlanValue == opt.value,
                  onTap: () => context.read<VitalsCaptureBloc>().add(
                    SelectProviderPlanEvent(opt.value),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],

            if (state.needsTreatmentGap &&
                pathway.treatmentGapQuestion != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _QuestionLabel(text: pathway.treatmentGapQuestion!),
              if (pathway.treatmentGapHint != null) ...[
                const SizedBox(height: 4),
                Text(
                  pathway.treatmentGapHint!,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              for (final opt in pathway.treatmentGapOptions) ...[
                AssessmentMultiChoiceTile(
                  option: AssessmentOption(value: opt.value, label: opt.label),
                  selected: state.treatmentGapValues.contains(opt.value),
                  onTap: () => context.read<VitalsCaptureBloc>().add(
                    ToggleTreatmentGapEvent(opt.value),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (state.treatmentGapValues.contains('other')) ...[
                const SizedBox(height: AppSpacing.sm),
                SoftInput(
                  controller: TextEditingController(),
                  hint: pathway.treatmentGapOtherHint ?? '',
                  onChanged: (v) => context.read<VitalsCaptureBloc>().add(
                    SetTreatmentGapOtherEvent(v),
                  ),
                ),
              ],
            ],

            if (state.needsDialysisDays &&
                pathway.dialysisDaysQuestion != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _QuestionLabel(text: pathway.dialysisDaysQuestion!),
              if (pathway.dialysisDaysHint != null) ...[
                const SizedBox(height: 4),
                Text(
                  pathway.dialysisDaysHint!,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              for (final day in pathway.dayOptions) ...[
                AssessmentMultiChoiceTile(
                  option: AssessmentOption(value: day.value, label: day.label),
                  selected: state.dialysisDays.contains(
                    int.tryParse(day.value) ?? -1,
                  ),
                  onTap: () => context.read<VitalsCaptureBloc>().add(
                    ToggleDialysisDayEvent(int.tryParse(day.value) ?? -1),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],

            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              onPressed: state.pathwayCanContinue
                  ? () {
                      context.read<VitalsCaptureBloc>().add(
                        const CaptureContinueFromPathwayEvent(),
                      );
                      context.router.push(VitalsBmiRoute(kind: state.kind!));
                    }
                  : null,
              label: AppLocalizations.getString(context, 'common.continue'),
              color: AppColors.primaryColor,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionLabel extends StatelessWidget {
  final String text;
  const _QuestionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
