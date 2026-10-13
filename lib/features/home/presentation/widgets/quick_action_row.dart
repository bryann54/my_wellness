import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/home/presentation/widgets/quick_action_chip.dart';

class QuickActionRow extends StatelessWidget {
  static const _minimumFourColumnWidth = 192.0;
  static const _columnSpacing = 8.0;
  static const _rowSpacing = 8.0;

  const QuickActionRow({super.key});

  static double preferredHeight(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width - 2 * AppSpacing.lg;
    final columns = availableWidth < _minimumFourColumnWidth ? 2 : 4;
    final spacing = columns == 2 ? _columnSpacing : 0.0;
    final itemWidth = (availableWidth - spacing * (columns - 1)) / columns;
    final rows = (4 / columns).ceil();
    return QuickActionChip.preferredHeight(context, itemWidth) * rows +
        _rowSpacing * (rows - 1);
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
        builder: (context, constraints) {
          final columns = constraints.maxWidth < _minimumFourColumnWidth
              ? 2
              : items.length;
          final spacing = columns == 2 ? _columnSpacing : 0.0;
          final itemWidth =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: spacing,
            runSpacing: _rowSpacing,
            children: [
              for (final item in items)
                SizedBox(
                  width: itemWidth,
                  child: QuickActionChip(
                    icon: item.icon,
                    label: item.label,
                    route: item.route,
                    width: itemWidth,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
