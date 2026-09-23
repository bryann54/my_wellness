import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/home/presentation/widgets/quick_action_chip.dart';

class QuickActionRow extends StatelessWidget {
  const QuickActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: FontAwesomeIcons.capsules,
        label: AppLocalizations.getString(context, 'common.medication'),
        route: const MedicationsRoute(),
      ),
      (
        icon: FontAwesomeIcons.waveSquare,
        label: AppLocalizations.getString(context, 'common.myHealth'),
        route: const MyHealthRoute(),
      ),
      (
        icon: FontAwesomeIcons.stethoscope,
        label: AppLocalizations.getString(context, 'common.appointments'),
        route: const AppointmentsRoute(),
      ),
      (
        icon: FontAwesomeIcons.shieldDog,
        label: AppLocalizations.getString(context, 'common.vitals'),
        route:  VitalsRoute(),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items
          .map(
            (item) => QuickActionChip(
              icon: item.icon,
              label: item.label,
              route: item.route,
            ),
          )
          .toList(),
    );
  }
}
