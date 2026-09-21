import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/presentation/bloc/geography_bloc.dart';

class CountyDropdown extends StatelessWidget {
  final int? selectedCountyId;
  final ValueChanged<int?> onChanged;

  const CountyDropdown({
    super.key,
    required this.selectedCountyId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeographyBloc, GeographyState>(
      buildWhen: (prev, curr) =>
          prev.counties != curr.counties ||
          prev.countiesStatus != curr.countiesStatus,
      builder: (context, state) {
        final counties = state.counties;
        final isLoading = state.countiesStatus == LoadStatus.loading;

        // Match the selected item by id — DropDownWidget compares by identity,
        // so we must pass the SAME object that's in `items`.
        County? selected;
        if (selectedCountyId != null) {
          for (final c in counties) {
            if (c.id == selectedCountyId) {
              selected = c;
              break;
            }
          }
        }

        return DropDownWidget<County>(
          label: AppLocalizations.getString(context, 'auth.county'),
          isRequired: true,
          isEnabled: !isLoading && counties.isNotEmpty,
          selectedItem: selected,
          hintText: isLoading
              ? AppLocalizations.getString(context, 'common.loading')
              : AppLocalizations.getString(context, 'auth.selectCounty'),
          items: counties
              .map(
                (c) => DropdownMenuItem<County>(value: c, child: Text(c.name)),
              )
              .toList(),
          onChanged: (county) => onChanged(county?.id),
        );
      },
    );
  }
}
