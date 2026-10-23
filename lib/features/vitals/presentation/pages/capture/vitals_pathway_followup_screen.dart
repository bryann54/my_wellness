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
import 'package:my_wellness/features/assessments/domain/entities/assessment_option.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_choice_tile.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_multi_choice_tile.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_capture_bloc.dart';

@RoutePage()
class VitalsPathwayFollowupScreen extends StatelessWidget {
  const VitalsPathwayFollowupScreen({super.key, required this.kind});
  final VitalsCaptureKind kind;

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: context.read<VitalsCaptureBloc>(),
    child: const _FollowupBody(),
  );
}

class _FollowupBody extends StatefulWidget {
  const _FollowupBody();

  @override
  State<_FollowupBody> createState() => _FollowupBodyState();
}

class _FollowupBodyState extends State<_FollowupBody> {
  final _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<VitalsCaptureBloc>();
    final state = bloc.state;
    final pathway = state.content!.pathway;
    final cs = Theme.of(context).colorScheme;
    final question = state.needsProviderPlan
        ? pathway.providerPlanQuestion
        : state.needsTreatmentGap
        ? pathway.treatmentGapQuestion
        : pathway.dialysisDaysQuestion;
    final hint = state.needsTreatmentGap
        ? pathway.treatmentGapHint
        : pathway.dialysisDaysHint;

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
            if (question != null)
              Text(
                question,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            if (hint != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                hint,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: cs.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (question != null && state.needsProviderPlan)
              for (final option in pathway.providerPlanOptions)
                AssessmentChoiceTile(
                  option: AssessmentOption(
                    value: option.value,
                    label: option.label,
                  ),
                  selected: state.providerPlanValue == option.value,
                  onTap: () => bloc.add(SelectProviderPlanEvent(option.value)),
                )
            else if (question != null && state.needsTreatmentGap) ...[
              for (final option in pathway.treatmentGapOptions)
                AssessmentMultiChoiceTile(
                  option: AssessmentOption(
                    value: option.value,
                    label: option.label,
                  ),
                  selected: state.treatmentGapValues.contains(option.value),
                  onTap: () => bloc.add(ToggleTreatmentGapEvent(option.value)),
                ),
              if (state.treatmentGapValues.contains('other')) ...[
                const SizedBox(height: AppSpacing.sm),
                SoftInput(
                  controller: _otherController,
                  hint: pathway.treatmentGapOtherHint ?? '',
                  onChanged: (v) => bloc.add(SetTreatmentGapOtherEvent(v)),
                ),
              ],
            ] else if (question != null)
              for (final day in pathway.dayOptions)
                AssessmentMultiChoiceTile(
                  option: AssessmentOption(value: day.value, label: day.label),
                  selected: state.dialysisDays.contains(
                    int.tryParse(day.value) ?? -1,
                  ),
                  onTap: () => bloc.add(
                    ToggleDialysisDayEvent(int.tryParse(day.value) ?? -1),
                  ),
                ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              onPressed: state.followupCanContinue
                  ? () {
                      bloc.add(const CaptureContinueFromPathwayEvent());
                      context.router.push(
                        VitalsPathwayTipsRoute(kind: state.kind!),
                      );
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
