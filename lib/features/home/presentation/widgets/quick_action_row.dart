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
        icon: FontAwesomeIcons.folder,
        label: AppLocalizations.getString(context, 'documents.myID'),
        route: const AccountRoute(),
      ),
      (
        icon: FontAwesomeIcons.solidBell,
        label: AppLocalizations.getString(context, 'common.alerts'),
        route: const AccountRoute(),
      ),
      (
        icon: FontAwesomeIcons.fileContract,
        label: AppLocalizations.getString(context, 'documents.title'),
        route: const AccountRoute(),
      ),
      (
        icon: FontAwesomeIcons.userTie,
        label: AppLocalizations.getString(context, 'attorneys.title'),
        route: const AccountRoute(),
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
