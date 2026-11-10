import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_choice_tile.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_option.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
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
    final pathway = state.content?.pathway;

    if (state.step == VitalsCaptureStep.reading ||
        state.step == VitalsCaptureStep.bmi) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (context.router.current.name != VitalsPathwayRoute.name) return;
        context.router.replace(
          state.step == VitalsCaptureStep.bmi
              ? VitalsBmiRoute(kind: state.kind!)
              : VitalsReadingEntryRoute(kind: state.kind!),
        );
      });
      return const _PathwaySkeleton();
    }

    if (pathway == null) {
      return const _PathwaySkeleton();
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
            Text(
              pathway.pathwayQuestion,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
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

            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              onPressed: state.pathwayCanContinue
                  ? () {
                      final needsFollowup =
                          state.needsProviderPlan ||
                          state.needsTreatmentGap ||
                          state.needsDialysisDays;
                      if (needsFollowup) {
                        context.router.push(
                          VitalsPathwayFollowupRoute(kind: state.kind!),
                        );
                      } else {
                        context.read<VitalsCaptureBloc>().add(
                          const CaptureContinueFromPathwayEvent(),
                        );
                        context.read<AccountBloc>().add(
                          UpdateProfileEvent(
                            updatedData: {
                              (state.kind == VitalsCaptureKind.bp
                                      ? 'htn_onboarding_seen'
                                      : 'dm_onboarding_seen'):
                                  true,
                            },
                          ),
                        );
                        final bmiDue =
                            context
                                .read<AccountBloc>()
                                .state
                                .profile
                                ?.bmiPromptDue ??
                            true;
                        context.router.push(
                          bmiDue
                              ? VitalsBmiRoute(kind: state.kind!)
                              : VitalsReadingEntryRoute(kind: state.kind!),
                        );
                      }
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

class _PathwaySkeleton extends StatelessWidget {
  const _PathwaySkeleton();

  @override
  Widget build(BuildContext context) {
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
          children: const [
            ShimmerLine(width: 220, height: 20),
            SizedBox(height: AppSpacing.md),
            ShimmerCard(height: 64, radius: 12),
            SizedBox(height: 10),
            ShimmerCard(height: 64, radius: 12),
            SizedBox(height: 10),
            ShimmerCard(height: 64, radius: 12),
            SizedBox(height: AppSpacing.xl),
            ShimmerCard(height: 50, radius: 12),
          ],
        ),
      ),
    );
  }
}
