import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/pages/vitals_screen.dart';

@RoutePage()
class VitalsRouteScreen extends StatelessWidget {
  final int initialTab;
  const VitalsRouteScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<VitalsBloc>();
      if (bloc.state.status == VitalsStatus.initial) {
        bloc.add(const LoadVitalsEvent());
      }
    });
    return VitalsScreen(initialTab: initialTab);
  }
}
