import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_fab.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/add_medication_sheet.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/medication_tile.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/medication_tile_shimmer.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_empty_state.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_toast_listener.dart';

@RoutePage()
class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);

    final bloc = context.read<VitalsBloc>();
    if (bloc.state.status == VitalsStatus.initial) {
      bloc.add(const LoadVitalsEvent());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<VitalsBloc>().add(const LoadMoreMedicationsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return VitalsToastListener(
      child: Scaffold(
        floatingActionButton: BlocBuilder<VitalsBloc, VitalsState>(
          buildWhen: (p, c) => p.medications.isEmpty != c.medications.isEmpty,
          builder: (context, state) {
            return AppFabSlot(
              visible: state.medications.isNotEmpty,
              child: AppFab.extended(
                label: AppLocalizations.getString(context, 'medications.add'),
                icon: const Icon(Icons.add),
                onPressed: () => AddMedicationSheet.show(context),
              ),
            );
          },
        ),
        body: BlocBuilder<VitalsBloc, VitalsState>(
          buildWhen: (p, c) =>
              p.status != c.status ||
              p.medications != c.medications ||
              p.medicationsCursor != c.medicationsCursor,
          builder: (context, state) {
            final meds = state.medications;

            if (state.status == VitalsStatus.loading && meds.isEmpty) {
              return const _MedicationsSkeleton();
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<VitalsBloc>().add(const LoadVitalsEvent()),
              child: NestedScrollView(
                headerSliverBuilder: (_, __) => [
                  CustomAppBar(
                    title: AppLocalizations.getString(
                      context,
                      'medications.title',
                    ),
                    isHome: false,
                  ),
                ],
                body: meds.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.5,
                            child: VitalsEmptyState(
                              icon: Icons.medication_outlined,
                              title: AppLocalizations.getString(
                                context,
                                'medications.empty',
                              ),
                              subtitle: AppLocalizations.getString(
                                context,
                                'medications.emptySub',
                              ),
                              ctaLabel: AppLocalizations.getString(
                                context,
                                'medications.add',
                              ),
                              onCta: () => AddMedicationSheet.show(context),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount:
                            meds.length +
                            (state.medicationsCursor != null ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= meds.length) {
                            return const MedicationTileShimmer();
                          }
                          final m = meds[i];
                          return MedicationTile(
                            medication: m,
                            onDelete: () => context.read<VitalsBloc>().add(
                              DeleteMedicationEvent(m.id),
                            ),
                          );
                        },
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MedicationsSkeleton extends StatelessWidget {
  const _MedicationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (_, __) => [
        CustomAppBar(
          title: AppLocalizations.getString(context, 'medications.title'),
          isHome: false,
        ),
      ],
      body: const MedicationsShimmerList(),
    );
  }
}
