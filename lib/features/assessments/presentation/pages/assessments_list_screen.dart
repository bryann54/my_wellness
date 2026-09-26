import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_card.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_toast_listener.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessments_access_gate.dart';

@RoutePage()
class AssessmentsListScreen extends StatelessWidget {
  const AssessmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userGender = context.select<AccountBloc, String?>(
      (b) => b.state.profile?.gender,
    );

    return BlocProvider(
      create: (_) =>
          getIt<AssessmentsBloc>()
            ..add(LoadAssessmentsEvent(userGender: userGender)),
      child: const _AssessmentsListBody(),
    );
  }
}

class _AssessmentsListBody extends StatelessWidget {
  const _AssessmentsListBody();

  @override
  Widget build(BuildContext context) {
    return AssessmentToastListener(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            CustomAppBar(
              title: AppLocalizations.getString(context, 'assessment.title'),
              isHome: false,
            ),
          ],
          body: BlocBuilder<AssessmentsBloc, AssessmentsState>(
            builder: (context, state) {
              if (state.status == AssessmentStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == AssessmentStatus.error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(state.errorMessage ?? 'Error'),
                  ),
                );
              }
              if (state.access != null && !state.access!.hasAccess) {
                return const AssessmentsBlockedView();
              }

              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  context.read<AssessmentsBloc>().add(
                    const LoadAssessmentsEvent(),
                  );
                },
                child: _GroupedAssessmentList(assessments: state.assessments),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GroupedAssessmentList extends StatelessWidget {
  final List<AssessmentSummary> assessments;
  const _GroupedAssessmentList({required this.assessments});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<AssessmentSummary>> grouped = {};
    for (final a in assessments) {
      grouped.putIfAbsent(a.category, () => []).add(a);
    }
    final categories = grouped.keys.toList(growable: false);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final category = categories[i];
        final items = grouped[category]!;
        final style = CategoryStyle.forCategory(category);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: i == 0 ? 4 : 24,
                bottom: 10,
                left: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                       style.localizedLabel(context, category).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppColors.shadowColor.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            for (final a in items)
              AssessmentCard(
                summary: a,
                onTap: () =>
                    context.router.push(AssessmentIntroRoute(slug: a.slug)),
              ),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }
}
