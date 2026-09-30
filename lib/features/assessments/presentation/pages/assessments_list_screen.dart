import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/debouncer.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_empty_state.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_list_body.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_list_skeleton.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_search_bar_bottom.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_search_result_count.dart';
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

class _AssessmentsListBody extends StatefulWidget {
  const _AssessmentsListBody();

  @override
  State<_AssessmentsListBody> createState() => _AssessmentsListBodyState();
}

class _AssessmentsListBodyState extends State<_AssessmentsListBody> {
  final _searchDebouncer = Debouncer(milliseconds: 250);
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchDebouncer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _searchDebouncer.run(() {
      if (!mounted) return;
      context.read<AssessmentsBloc>().add(SearchAssessmentsEvent(q));
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchDebouncer.cancel();
    context.read<AssessmentsBloc>().add(const SearchAssessmentsEvent(''));
  }

  Future<void> _refresh() async {
    context.read<AssessmentsBloc>().add(const LoadAssessmentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AssessmentToastListener(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            CustomAppBar(
              title: AppLocalizations.getString(context, 'assessment.title'),
              isHome: false,
              isTabRoot: true,
              bottom: AssessmentSearchBarBottom(
                controller: _searchController,
                hintText: AppLocalizations.getString(
                  context,
                  'assessment.searchHint',
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ],
          body: BlocBuilder<AssessmentsBloc, AssessmentsState>(
            builder: (context, state) {
              if (state.status == AssessmentStatus.loading) {
                return const AssessmentListSkeleton();
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

              final items = state.filteredAssessments;
              final isSearching = state.searchQuery.trim().isNotEmpty;

              if (items.isEmpty) {
                return RefreshIndicator.adaptive(
                  onRefresh: _refresh,
                  child: AssessmentEmptyState(
                    query: state.searchQuery,
                    isSearching: isSearching,
                    onClear: _clearSearch,
                  ),
                );
              }

              return RefreshIndicator.adaptive(
                onRefresh: _refresh,
                child: Column(
                  children: [
                    if (isSearching)
                      AssessmentSearchResultCount(
                        count: items.length,
                        query: state.searchQuery,
                      ),
                    Expanded(
                      child: AssessmentListBody(
                        assessments: items,
                        searchQuery: state.searchQuery,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
