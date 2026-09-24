import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_fab.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/sheets/add_appointment_sheet.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/appointment_tile.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_empty_state.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_toast_listener.dart';

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
      context.read<VitalsBloc>().add(const LoadMoreAppointmentsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return VitalsToastListener(
      child: Scaffold(
        floatingActionButton: BlocBuilder<VitalsBloc, VitalsState>(
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
        body: BlocBuilder<VitalsBloc, VitalsState>(
          buildWhen: (p, c) =>
              p.status != c.status ||
              p.appointments != c.appointments ||
              p.appointmentsCursor != c.appointmentsCursor,
          builder: (context, state) {
            final appts = state.appointments;
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<VitalsBloc>().add(const LoadVitalsEvent()),
              child: NestedScrollView(
                headerSliverBuilder: (_, __) => [
                  CustomAppBar(
                    title: AppLocalizations.getString(
                      context,
                      'common.appointments',
                    ),
                    isHome: false,
                  ),
                ],
                body: appts.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.5,
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
                              onCta: () => AddAppointmentSheet.show(context),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount:
                            appts.length +
                            (state.appointmentsCursor != null ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= appts.length) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final a = appts[i];
                          return AppointmentTile(
                            appointment: a,
                            onDelete: () => context.read<VitalsBloc>().add(
                              DeleteAppointmentEvent(a.id),
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
