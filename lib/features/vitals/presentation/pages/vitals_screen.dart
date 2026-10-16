import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/constants/hero.dart';
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
          headerSliverBuilder: (_, _) => [
            CustomAppBar(
              title: AppLocalizations.getString(context, 'vitals.title'),
              titleHeroTag: HeroTags.homeVitals,
              isHome: false,
              bottom: AppTabBar(
                controller: _tabs,
                tabs: [
                  AppLocalizations.getString(context, 'vitals.bloodPressure'),
                  AppLocalizations.getString(context, 'vitals.bloodSugar'),
                ],
                heroTags: [HeroTags.homeBloodPressure, HeroTags.homeBloodSugar],
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
