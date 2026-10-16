import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/features/geography/domain/entities/ward.dart';
import 'package:my_wellness/features/geography/presentation/bloc/geography_bloc.dart';

class WardDropdown extends StatelessWidget {
  const WardDropdown({
    super.key,
    required this.constituencyId,
    required this.selectedWardId,
    required this.onChanged,
    this.isOptional = false,
  });

  final int? constituencyId;
  final int? selectedWardId;
  final ValueChanged<int?> onChanged;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeographyBloc, GeographyState>(
      buildWhen: (prev, curr) =>
          prev.wards != curr.wards || prev.wardsStatus != curr.wardsStatus,
      builder: (context, state) {
        final isLoading = state.wardsStatus == LoadStatus.loading;
        final wards = constituencyId == null
            ? const <Ward>[]
            : state.wardsIn(constituencyId!);

        Ward? selected;
        if (selectedWardId != null) {
          for (final w in wards) {
            if (w.id == selectedWardId) {
              selected = w;
              break;
            }
          }
        }

        final disabled = constituencyId == null || isLoading || wards.isEmpty;

        return DropDownWidget<Ward>(
          label: AppLocalizations.getString(context, 'auth.ward'),
          isRequired: !isOptional,
          isEnabled: !disabled,
          selectedItem: selected,
          hintText: constituencyId == null
              ? AppLocalizations.getString(
                  context,
                  'auth.selectConstituencyFirst',
                )
              : isLoading
              ? AppLocalizations.getString(context, 'common.loading')
              : AppLocalizations.getString(context, 'auth.selectWard'),
          items: wards
              .map((w) => DropdownMenuItem<Ward>(value: w, child: Text(w.name)))
              .toList(),
          onChanged: disabled ? null : (w) => onChanged(w?.id),
        );
      },
    );
  }
}
