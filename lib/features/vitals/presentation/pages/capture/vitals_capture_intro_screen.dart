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
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_intro_skeleton.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_capture_bloc.dart';

@RoutePage()
class VitalsCaptureIntroScreen extends StatelessWidget {
  final VitalsCaptureKind kind;
  const VitalsCaptureIntroScreen({super.key, required this.kind});

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
    final content = state.content;

    if (content == null || state.step == VitalsCaptureStep.loadingContent) {
      return const Scaffold(body: SafeArea(child: AssessmentIntroSkeleton()));
    }

    final intro = content.onboarding.intro;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(title: intro.title, isHome: false),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                intro.heading,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final p in intro.paragraphs) ...[
                Text(
                  p,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.55,
                    color: cs.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                onPressed: () {
                  context.read<VitalsCaptureBloc>().add(
                    const CaptureContinueFromIntroEvent(),
                  );
                  context.router.push(VitalsPathwayRoute(kind: state.kind!));
                },
                label: AppLocalizations.getString(context, 'common.continue'),
                color: AppColors.primaryColor,
                borderRadius: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
