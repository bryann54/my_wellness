import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/profile_section_label.dart';
import 'package:my_wellness/features/geography/domain/entities/constituency.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/domain/entities/ward.dart';
import 'package:my_wellness/features/geography/presentation/bloc/geography_bloc.dart';

typedef HydrateCallback =
    void Function(
      County? county,
      SubCounty? subCounty,
      Constituency? constituency,
      Ward? ward,
    );

class ProfileLocationFields extends StatefulWidget {
  final HealthProfile profile;
  final County? county;
  final SubCounty? subCounty;
  final Constituency? constituency;
  final Ward? ward;

  final HydrateCallback onHydrate;
  final ValueChanged<County?> onCountyChanged;
  final ValueChanged<SubCounty?> onSubCountyChanged;
  final ValueChanged<Constituency?> onConstituencyChanged;
  final ValueChanged<Ward?> onWardChanged;

  const ProfileLocationFields({
    super.key,
    required this.profile,
    required this.county,
    required this.subCounty,
    required this.constituency,
    required this.ward,
    required this.onHydrate,
    required this.onCountyChanged,
    required this.onSubCountyChanged,
    required this.onConstituencyChanged,
    required this.onWardChanged,
  });

  @override
  State<ProfileLocationFields> createState() => _ProfileLocationFieldsState();
}

class _ProfileLocationFieldsState extends State<ProfileLocationFields> {
  bool _fetched = false;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  void _fetch() {
    if (!mounted || _fetched) return;
    _fetched = true;
    final bloc = context.read<GeographyBloc>();
    final s = bloc.state;
    if (s.counties.isEmpty) bloc.add(const LoadAllGeographyEvent());
    if (s.constituencies.isEmpty) {
      bloc.add(const LoadConstituenciesEvent());
    }
    if (s.wards.isEmpty) bloc.add(const LoadWardsEvent());
  }

  void _hydrateOnce(GeographyState geo) {
    if (_hydrated || geo.counties.isEmpty) return;
    _hydrated = true;

    final p = widget.profile;
    final county = geo.counties.firstWhereOrNull((c) => c.name == p.county);
    final subCounty = county == null || p.subCounty == null
        ? null
        : geo.subCounties.firstWhereOrNull(
            (s) => s.countyId == county.id && s.id == p.subCounty,
          );
    final constituency = county == null || p.constituency == null
        ? null
        : geo.constituencies.firstWhereOrNull(
            (c) => c.countyId == county.id && c.id == p.constituency,
          );
    final ward = constituency == null || p.ward == null
        ? null
        : geo.wards.firstWhereOrNull(
            (w) => w.constituencyId == constituency.id && w.id == p.ward,
          );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onHydrate(county, subCounty, constituency, ward);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeographyBloc, GeographyState>(
      builder: (context, geo) {
        _hydrateOnce(geo);

        final counties = geo.counties;
        final subCounties = widget.county == null
            ? const <SubCounty>[]
            : geo.subCounties
                  .where((s) => s.countyId == widget.county!.id)
                  .toList();
        final constituencies = widget.county == null
            ? const <Constituency>[]
            : geo.constituencies
                  .where((c) => c.countyId == widget.county!.id)
                  .toList();
        final wards = widget.constituency == null
            ? const <Ward>[]
            : geo.wards
                  .where((w) => w.constituencyId == widget.constituency!.id)
                  .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileSectionLabel(
              AppLocalizations.getString(context, 'profile.locationSection'),
            ),
            const SizedBox(height: 10),

            DropDownWidget<County>(
              label: AppLocalizations.getString(context, 'profile.county'),
              selectedItem: widget.county,
              isEnabled: counties.isNotEmpty,
              isDense: true,
              contentPadding: 8,
              padding: EdgeInsets.zero,
              hintText: AppLocalizations.getString(
                context,
                'profile.selectCounty',
              ),
              items: counties
                  .map(
                    (c) =>
                        DropdownMenuItem<County>(value: c, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: widget.onCountyChanged,
            ),
            const SizedBox(height: 10),

            DropDownWidget<SubCounty>(
              label: AppLocalizations.getString(context, 'profile.subCounty'),
              selectedItem: widget.subCounty,
              isEnabled: widget.county != null && subCounties.isNotEmpty,
              isDense: true,
              contentPadding: 8,
              padding: EdgeInsets.zero,
              hintText: widget.county == null
                  ? AppLocalizations.getString(
                      context,
                      'profile.selectCountyFirst',
                    )
                  : AppLocalizations.getString(
                      context,
                      'profile.selectSubCounty',
                    ),
              items: subCounties
                  .map(
                    (s) => DropdownMenuItem<SubCounty>(
                      value: s,
                      child: Text(s.name),
                    ),
                  )
                  .toList(),
              onChanged: widget.onSubCountyChanged,
            ),
            const SizedBox(height: 10),

            DropDownWidget<Constituency>(
              label: AppLocalizations.getString(
                context,
                'profile.constituency',
              ),
              selectedItem: widget.constituency,
              isEnabled: widget.county != null && constituencies.isNotEmpty,
              isDense: true,
              contentPadding: 8,
              padding: EdgeInsets.zero,
              hintText: widget.county == null
                  ? AppLocalizations.getString(
                      context,
                      'profile.selectCountyFirst',
                    )
                  : AppLocalizations.getString(
                      context,
                      'profile.selectConstituency',
                    ),
              items: constituencies
                  .map(
                    (c) => DropdownMenuItem<Constituency>(
                      value: c,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              onChanged: widget.onConstituencyChanged,
            ),
            const SizedBox(height: 10),

            DropDownWidget<Ward>(
              label: AppLocalizations.getString(context, 'profile.ward'),
              selectedItem: widget.ward,
              isEnabled: widget.constituency != null && wards.isNotEmpty,
              isDense: true,
              contentPadding: 8,
              padding: EdgeInsets.zero,
              hintText: widget.constituency == null
                  ? AppLocalizations.getString(
                      context,
                      'profile.selectConstituencyFirst',
                    )
                  : AppLocalizations.getString(context, 'profile.selectWard'),
              items: wards
                  .map(
                    (w) =>
                        DropdownMenuItem<Ward>(value: w, child: Text(w.name)),
                  )
                  .toList(),
              onChanged: widget.onWardChanged,
            ),
          ],
        );
      },
    );
  }
}
