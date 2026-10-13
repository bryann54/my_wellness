import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/colors.dart';
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
  final int? verifiedCountyId;
  final int? verifiedSubCountyId;
  final LocationCallback onContinue;

  const RegisterStepLocation({
    super.key,
    this.initialCounty,
    this.initialSubCounty,
    this.verifiedCountyId,
    this.verifiedSubCountyId,
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
    _applyVerifiedLocation(context.read<GeographyBloc>().state);
  }

  @override
  void didUpdateWidget(covariant RegisterStepLocation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.verifiedCountyId != widget.verifiedCountyId ||
        oldWidget.verifiedSubCountyId != widget.verifiedSubCountyId) {
      _applyVerifiedLocation(context.read<GeographyBloc>().state);
    }
  }

  void _applyVerifiedLocation(GeographyState state) {
    SubCounty? verifiedSubCounty;
    for (final subCounty in state.subCounties) {
      if (subCounty.id == widget.verifiedSubCountyId) {
        verifiedSubCounty = subCounty;
        break;
      }
    }
    final countyId = widget.verifiedCountyId ?? verifiedSubCounty?.countyId;
    final verifiedCounty = countyId == null
        ? null
        : state.countyByIdOrNull(countyId);

    if ((verifiedCounty != null && _county?.id != verifiedCounty.id) ||
        (verifiedSubCounty != null && _subCounty?.id != verifiedSubCounty.id)) {
      setState(() {
        if (verifiedCounty != null) _county = verifiedCounty;
        if (verifiedSubCounty != null) _subCounty = verifiedSubCounty;
      });
    }
  }

  void _continue() {
    if (_county == null || _subCounty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.getString(context, 'auth.selectCountyAndSub'),
          ),
        ),
      );
      return;
    }
    widget.onContinue(county: _county!, subCounty: _subCounty!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GeographyBloc, GeographyState>(
      listenWhen: (previous, current) =>
          previous.counties != current.counties ||
          previous.subCounties != current.subCounties,
      listener: (context, state) => _applyVerifiedLocation(state),
      child: SingleChildScrollView(
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
              isLocked:
                  widget.verifiedCountyId != null ||
                  widget.verifiedSubCountyId != null,
              onChanged: (id) {
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
                  _subCounty = null;
                });
              },
            ),
            const SizedBox(height: 16),
            SubCountyDropdown(
              countyId: _county?.id,
              selectedSubCountyId: _subCounty?.id,
              isLocked: widget.verifiedSubCountyId != null,
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
              borderRadius: 12,
              color: AppColors.primaryColor,
              onPressed: _continue,
              label: AppLocalizations.getString(context, 'common.continue'),
            ),
          ],
        ),
      ),
    );
  }
}
