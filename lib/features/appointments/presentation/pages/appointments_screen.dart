import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/widgets/app_fab.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:my_wellness/features/appointments/presentation/widgets/appointments_toast_listener.dart';
import 'package:my_wellness/features/appointments/presentation/widgets/add_appointment_sheet.dart';
import 'package:my_wellness/features/appointments/presentation/widgets/appointment_tile.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_empty_state.dart';

@RoutePage()
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    final bloc = context.read<AppointmentsBloc>();
    if (bloc.state.status == CollectionStatus.initial) {
      bloc.add(const LoadAppointmentsEvent());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<AppointmentsBloc>().add(const LoadMoreAppointmentsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppointmentsToastListener(
      child: Scaffold(
        floatingActionButton: BlocBuilder<AppointmentsBloc, AppointmentsState>(
          buildWhen: (p, c) => p.appointments.isEmpty != c.appointments.isEmpty,
          builder: (context, state) {
            return AppFabSlot(
              visible: state.appointments.isNotEmpty,
              child: AppFab.extended(
                label: AppLocalizations.getString(context, 'appointments.book'),
                icon: const Icon(Icons.add),
                onPressed: () => AddAppointmentSheet.show(context),
              ),
            );
          },
        ),
        body: BlocBuilder<AppointmentsBloc, AppointmentsState>(
          buildWhen: (p, c) =>
              p.status != c.status ||
              p.appointments != c.appointments ||
              p.cursor != c.cursor,
          builder: (context, state) {
            final appts = state.appointments;
            return RefreshIndicator.adaptive(
              onRefresh: () async => context.read<AppointmentsBloc>().add(
                const LoadAppointmentsEvent(),
              ),
              child: NestedScrollView(
                headerSliverBuilder: (_, _) => [
                  CustomAppBar(
                    title: AppLocalizations.getString(
                      context,
                      'common.appointments',
                    ),
                    titleHeroTag: HeroTags.homeAppointments,
                    isHome: false,
                  ),
                ],
                body: appts.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.sizeOf(context).height * 0.5,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 480,
                                ),
                                child: Padding(
                                  padding: AppSpacing.page,
                                  child: VitalsEmptyState(
                                    icon: Icons.calendar_today_outlined,
                                    title: AppLocalizations.getString(
                                      context,
                                      'appointments.empty',
                                    ),
                                    subtitle: AppLocalizations.getString(
                                      context,
                                      'appointments.emptySub',
                                    ),
                                    ctaLabel: AppLocalizations.getString(
                                      context,
                                      'appointments.book',
                                    ),
                                    onCta: () =>
                                        AddAppointmentSheet.show(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          112,
                        ),
                        itemCount:
                            appts.length + (state.cursor != null ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= appts.length) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                          }
                          final a = appts[i];
                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 680),
                              child: AppointmentTile(
                                appointment: a,
                                onDelete: () => context
                                    .read<AppointmentsBloc>()
                                    .add(DeleteAppointmentEvent(a.id)),
                              ),
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
