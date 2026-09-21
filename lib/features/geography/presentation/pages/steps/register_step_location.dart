import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/presentation/bloc/geography_bloc.dart';
import 'package:my_wellness/features/geography/presentation/widgets/county_dropdown.dart';
import 'package:my_wellness/features/geography/presentation/widgets/sub_county_dropdown.dart';

typedef LocationCallback =
    void Function({required County county, required SubCounty subCounty});

class RegisterStepLocation extends StatefulWidget {
  final County? initialCounty;
  final SubCounty? initialSubCounty;
  final LocationCallback onContinue;

  const RegisterStepLocation({
    super.key,
    this.initialCounty,
    this.initialSubCounty,
    required this.onContinue,
  });

  @override
  State<RegisterStepLocation> createState() => _RegisterStepLocationState();
}

class _RegisterStepLocationState extends State<RegisterStepLocation> {
  County? _county;
  SubCounty? _subCounty;

  @override
  void initState() {
    super.initState();
    _county = widget.initialCounty;
    _subCounty = widget.initialSubCounty;
  }

  void _continue() {
    if (_county == null || _subCounty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select county and sub-county')),
      );
      return;
    }
    widget.onContinue(county: _county!, subCounty: _subCounty!);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.getString(context, 'auth.whereAreYou'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'We use this to show you relevant health facilities and services.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          CountyDropdown(
            selectedCountyId: _county?.id,
            onChanged: (id) {
              // Look the entity back up so state holds the canonical object.
              if (id == null) {
                setState(() {
                  _county = null;
                  _subCounty = null;
                });
                return;
              }
              final selected = context
                  .read<GeographyBloc>()
                  .state
                  .countyByIdOrNull(id);
              setState(() {
                _county = selected;
                _subCounty = null; // invalidate child when parent changes
              });
            },
          ),
          const SizedBox(height: 16),
          SubCountyDropdown(
            countyId: _county?.id,
            selectedSubCountyId: _subCounty?.id,
            onChanged: (id) {
              if (id == null) {
                setState(() => _subCounty = null);
                return;
              }
              final selected = context
                  .read<GeographyBloc>()
                  .state
                  .subCountiesIn(_county!.id)
                  .firstWhere((s) => s.id == id);
              setState(() => _subCounty = selected);
            },
          ),
          const SizedBox(height: 32),
          AppPrimaryButton(
            onPressed: _continue,
            label: AppLocalizations.getString(context, 'common.continue'),
          ),
        ],
      ),
    );
  }
}
