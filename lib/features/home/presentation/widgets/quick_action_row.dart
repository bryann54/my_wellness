import 'package:flutter/material.dart';

import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/home/presentation/widgets/quick_action_chip.dart';

class QuickActionRow extends StatelessWidget {
  const QuickActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      QuickActionChip(
        imageAsset: 'assets/images/meds.png',
        label: AppLocalizations.getString(context, 'common.medication'),
        route: const MedicationsRoute(),
        heroTag: HeroTags.homeMedication,
        fallbackIcon: Icons.medication_rounded,
      ),
      QuickActionChip(
        imageAsset: 'assets/images/heart.png',
        label: AppLocalizations.getString(context, 'common.myHealth'),
        route: const MyHealthRoute(),
        heroTag: HeroTags.homeMyHealth,
        fallbackIcon: Icons.show_chart_rounded,
      ),
      QuickActionChip(
        imageAsset: 'assets/images/appointments.png',
        label: AppLocalizations.getString(context, 'common.appointments'),
        route: const AppointmentsRoute(),
        heroTag: HeroTags.homeAppointments,
        fallbackIcon: Icons.event_available_rounded,
      ),
      QuickActionChip(
        imageAsset: 'assets/images/vitals.png',
        label: AppLocalizations.getString(context, 'common.vitals'),
        route: VitalsRoute(),
        heroTag: HeroTags.homeVitals,
        fallbackIcon: Icons.monitor_heart_rounded,
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xs),
          Expanded(child: items[i]),
        ],
      ],
    );
  }
}
