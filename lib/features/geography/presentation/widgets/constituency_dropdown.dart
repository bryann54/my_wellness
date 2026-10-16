import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/features/geography/domain/entities/constituency.dart';
import 'package:my_wellness/features/geography/presentation/bloc/geography_bloc.dart';

class ConstituencyDropdown extends StatelessWidget {
  const ConstituencyDropdown({
    super.key,
    required this.countyId,
    required this.selectedConstituencyId,
    required this.onChanged,
  });

  final int? countyId;
  final int? selectedConstituencyId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeographyBloc, GeographyState>(
      buildWhen: (prev, curr) =>
          prev.constituencies != curr.constituencies ||
          prev.constituenciesStatus != curr.constituenciesStatus,
      builder: (context, state) {
        final isLoading = state.constituenciesStatus == LoadStatus.loading;
        final constituencies = countyId == null
            ? const <Constituency>[]
            : state.constituenciesIn(countyId!);

        Constituency? selected;
        if (selectedConstituencyId != null) {
          for (final c in constituencies) {
            if (c.id == selectedConstituencyId) {
              selected = c;
              break;
            }
          }
        }

        final disabled =
            countyId == null || isLoading || constituencies.isEmpty;

        return DropDownWidget<Constituency>(
          label: AppLocalizations.getString(context, 'auth.constituency'),
          isRequired: true,
          isEnabled: !disabled,
          selectedItem: selected,
          hintText: countyId == null
              ? AppLocalizations.getString(context, 'auth.selectCountyFirst')
              : isLoading
              ? AppLocalizations.getString(context, 'common.loading')
              : AppLocalizations.getString(context, 'auth.selectConstituency'),
          items: constituencies
              .map(
                (c) => DropdownMenuItem<Constituency>(
                  value: c,
                  child: Text(c.name),
                ),
              )
              .toList(),
          onChanged: disabled ? null : (c) => onChanged(c?.id),
        );
      },
    );
  }
}
