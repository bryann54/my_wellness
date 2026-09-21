import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/presentation/bloc/geography_bloc.dart';

class SubCountyDropdown extends StatelessWidget {
  final int? countyId;
  final int? selectedSubCountyId;
  final ValueChanged<int?> onChanged;

  const SubCountyDropdown({
    super.key,
    required this.countyId,
    required this.selectedSubCountyId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeographyBloc, GeographyState>(
      buildWhen: (prev, curr) =>
          prev.subCounties != curr.subCounties ||
          prev.subCountiesStatus != curr.subCountiesStatus,
      builder: (context, state) {
        final isLoading = state.subCountiesStatus == LoadStatus.loading;
        final subCounties = countyId == null
            ? const <SubCounty>[]
            : state.subCountiesIn(countyId!);

        SubCounty? selected;
        if (selectedSubCountyId != null) {
          for (final s in subCounties) {
            if (s.id == selectedSubCountyId) {
              selected = s;
              break;
            }
          }
        }

        final disabled = countyId == null || isLoading || subCounties.isEmpty;

        return DropDownWidget<SubCounty>(
          label: AppLocalizations.getString(context, 'auth.subCounty'),
          isRequired: true,
          isEnabled: !disabled,
          selectedItem: selected,
          hintText: countyId == null
              ? AppLocalizations.getString(context, 'auth.selectCountyFirst')
              : isLoading
              ? AppLocalizations.getString(context, 'common.loading')
              : AppLocalizations.getString(context, 'auth.selectSubCounty'),
          items: subCounties
              .map(
                (s) =>
                    DropdownMenuItem<SubCounty>(value: s, child: Text(s.name)),
              )
              .toList(),
          onChanged: disabled ? null : (sc) => onChanged(sc?.id),
        );
      },
    );
  }
}
