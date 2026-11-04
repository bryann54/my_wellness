import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_capture_bloc.dart';

@RoutePage()
class VitalsWellbeingScreen extends StatelessWidget {
  final VitalsCaptureKind kind;
  const VitalsWellbeingScreen({super.key, required this.kind});

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
    final result = state.result;
    final isSubmitting = state.step == VitalsCaptureStep.submitting;

    if (state.step == VitalsCaptureStep.done) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.router.replace(VitalsResultRoute(kind: state.kind!));
      });
    }

    final question = result?.wellbeingQuestionText.isNotEmpty == true
        ? result!.wellbeingQuestionText
        : 'Are you feeling unwell or experiencing general body weakness?';

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
              question,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _AnswerTile(
              label: 'Yes, I feel unwell',
              selected: false,
              enabled: !isSubmitting,
              onTap: () => context.read<VitalsCaptureBloc>().add(
                const AnswerWellbeingEvent(true),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _AnswerTile(
              label: 'No, I feel fine',
              selected: false,
              enabled: !isSubmitting,
              onTap: () => context.read<VitalsCaptureBloc>().add(
                const AnswerWellbeingEvent(false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _AnswerTile({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
