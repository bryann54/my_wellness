import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/home/presentation/widgets/quick_action_chip.dart';

class QuickActionRow extends StatelessWidget {
  const QuickActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: PhosphorIconsRegular.pill,
        label: AppLocalizations.getString(context, 'common.medication'),
        route: const MedicationsRoute(),
        heroTag: HeroTags.homeMedication,
      ),
      (
        icon: PhosphorIconsRegular.chartLineUp,
        label: AppLocalizations.getString(context, 'common.myHealth'),
        route: const MyHealthRoute(),
        heroTag: HeroTags.homeMyHealth,
      ),
      (
        icon: PhosphorIconsRegular.calendarCheck,
        label: AppLocalizations.getString(context, 'common.appointments'),
        route: const AppointmentsRoute(),
        heroTag: HeroTags.homeAppointments,
      ),
      (
        icon: PhosphorIconsRegular.heartbeat,
        label: AppLocalizations.getString(context, 'common.vitals'),
        route: VitalsRoute(),
        heroTag: HeroTags.homeVitals,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth < 360 ? 4.0 : 8.0;
        final itemWidth =
            (constraints.maxWidth - gap * (items.length - 1)) / items.length;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                if (index > 0) SizedBox(width: gap),
                QuickActionChip(
                  width: itemWidth,
                  icon: items[index].icon,
                  label: items[index].label,
                  route: items[index].route,
                  heroTag: items[index].heroTag,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
