import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_tab_bar.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/pages/tabs/bp_tab.dart';
import 'package:my_wellness/features/vitals/presentation/pages/tabs/bs_tab.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_toast_listener.dart';

@RoutePage()
class VitalsScreen extends StatefulWidget {
  final int initialTab;
  const VitalsScreen({super.key, this.initialTab = 0});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );

    // Guard: only fetch if the shared bloc hasn't loaded yet.
    final bloc = context.read<VitalsBloc>();
    if (bloc.state.status == VitalsStatus.initial) {
      bloc.add(const LoadVitalsEvent());
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VitalsToastListener(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            CustomAppBar(
              title: AppLocalizations.getString(context, 'vitals.title'),
              isHome: false,
              bottom: AppTabBar(
                controller: _tabs,
                tabs: [
                  AppLocalizations.getString(context, 'vitals.bloodPressure'),
                  AppLocalizations.getString(context, 'vitals.bloodSugar'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabs,
            children: const [BpTab(), BsTab()],
          ),
        ),
      ),
    );
  }
}
