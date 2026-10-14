import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/home/presentation/widgets/quick_action_chip.dart';

class QuickActionRow extends StatelessWidget {
  const QuickActionRow({super.key});

  static double preferredHeight(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width - 2 * AppSpacing.lg;
    final itemWidth = availableWidth / 4;
    return QuickActionChip.preferredHeight(context, itemWidth);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: PhosphorIconsRegular.pill,
        label: AppLocalizations.getString(context, 'common.medication'),
        route: const MedicationsRoute(),
      ),
      (
        icon: PhosphorIconsRegular.chartLineUp,
        label: AppLocalizations.getString(context, 'common.myHealth'),
        route: const MyHealthRoute(),
      ),
      (
        icon: PhosphorIconsRegular.calendarCheck,
        label: AppLocalizations.getString(context, 'common.appointments'),
        route: const AppointmentsRoute(),
      ),
      (
        icon: PhosphorIconsRegular.heartbeat,
        label: AppLocalizations.getString(context, 'common.vitals'),
        route: VitalsRoute(),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            for (final item in items)
              Expanded(
                child: QuickActionChip(
                  icon: item.icon,
                  label: item.label,
                  route: item.route,
                  width: constraints.maxWidth / items.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
