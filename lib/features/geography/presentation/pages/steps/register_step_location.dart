import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/geography/domain/entities/constituency.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/domain/entities/ward.dart';
import 'package:my_wellness/features/geography/presentation/bloc/geography_bloc.dart';
import 'package:my_wellness/features/geography/presentation/widgets/constituency_dropdown.dart';
import 'package:my_wellness/features/geography/presentation/widgets/county_dropdown.dart';
import 'package:my_wellness/features/geography/presentation/widgets/sub_county_dropdown.dart';
import 'package:my_wellness/features/geography/presentation/widgets/ward_dropdown.dart';

typedef LocationCallback =
    void Function({
      required County county,
      required SubCounty subCounty,
      required Constituency constituency,
      Ward? ward,
    });

class RegisterStepLocation extends StatefulWidget {
  const RegisterStepLocation({
    super.key,
    this.initialCounty,
    this.initialSubCounty,
    this.initialConstituency,
    this.initialWard,
    this.seedCountyId,
    this.seedSubCountyId,
    this.seedConstituencyId,
    this.seedWardId,
    required this.onContinue,
  });

  final County? initialCounty;
  final SubCounty? initialSubCounty;
  final Constituency? initialConstituency;
  final Ward? initialWard;

  
  final int? seedCountyId;
  final int? seedSubCountyId;
  final int? seedConstituencyId;
  final int? seedWardId;

  final LocationCallback onContinue;

  @override
  State<RegisterStepLocation> createState() => _RegisterStepLocationState();
}

class _RegisterStepLocationState extends State<RegisterStepLocation> {
  County? _county;
  SubCounty? _subCounty;
  Constituency? _constituency;
  Ward? _ward;

  bool _seedApplied = false;

  bool get _canContinue =>
      _county != null && _subCounty != null && _constituency != null;

  @override
  void initState() {
    super.initState();
    _county = widget.initialCounty;
    _subCounty = widget.initialSubCounty;
    _constituency = widget.initialConstituency;
    _ward = widget.initialWard;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applySeed(context.read<GeographyBloc>().state);
    });
  }

  void _applySeed(GeographyState state) {
    if (_seedApplied) return;

    final hasAnySeed =
        widget.seedCountyId != null ||
        widget.seedSubCountyId != null ||
        widget.seedConstituencyId != null ||
        widget.seedWardId != null;
    if (!hasAnySeed) {
      _seedApplied = true;
      return;
    }

    Ward? seedWard;
    if (widget.seedWardId != null) {
      for (final w in state.wards) {
        if (w.id == widget.seedWardId) {
          seedWard = w;
          break;
        }
      }
    }

    Constituency? seedConstituency;
    if (widget.seedConstituencyId != null) {
      for (final c in state.constituencies) {
        if (c.id == widget.seedConstituencyId) {
          seedConstituency = c;
          break;
        }
      }
    }

    SubCounty? seedSubCounty;
    if (widget.seedSubCountyId != null) {
      for (final s in state.subCounties) {
        if (s.id == widget.seedSubCountyId) {
          seedSubCounty = s;
          break;
        }
      }
    }

    final seedCountyId =
        widget.seedCountyId ??
        seedSubCounty?.countyId ??
        seedConstituency?.countyId;
    final seedCounty = seedCountyId == null
        ? null
        : state.countyByIdOrNull(seedCountyId);

    if (seedCounty == null &&
        seedSubCounty == null &&
        seedConstituency == null &&
        seedWard == null) {
      return;
    }

    setState(() {
      if (seedCounty != null && _county == null) _county = seedCounty;
      if (seedSubCounty != null && _subCounty == null) {
        _subCounty = seedSubCounty;
      }
      if (seedConstituency != null && _constituency == null) {
        _constituency = seedConstituency;
      }
      if (seedWard != null && _ward == null) _ward = seedWard;
    });
    _seedApplied = true;
  }

  void _continue() {
    if (!_canContinue) return;
    widget.onContinue(
      county: _county!,
      subCounty: _subCounty!,
      constituency: _constituency!,
      ward: _ward,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<GeographyBloc, GeographyState>(
      listenWhen: (previous, current) =>
          previous.counties != current.counties ||
          previous.subCounties != current.subCounties ||
          previous.constituencies != current.constituencies ||
          previous.wards != current.wards,
      listener: (context, state) => _applySeed(state),
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
              AppLocalizations.getString(context, 'auth.whereAreYouSub'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 24),

            CountyDropdown(
              selectedCountyId: _county?.id,
              onChanged: (id) {
                setState(() {
                  _county = id == null
                      ? null
                      : context.read<GeographyBloc>().state.countyByIdOrNull(
                          id,
                        );
                  _subCounty = null;
                  _constituency = null;
                  _ward = null;
                });
              },
            ),
            const SizedBox(height: 16),

            SubCountyDropdown(
              countyId: _county?.id,
              selectedSubCountyId: _subCounty?.id,
              onChanged: (id) {
                setState(() {
                  if (id == null) {
                    _subCounty = null;
                    return;
                  }
                  _subCounty = context
                      .read<GeographyBloc>()
                      .state
                      .subCountiesIn(_county!.id)
                      .firstWhere((s) => s.id == id);
                });
              },
            ),
            const SizedBox(height: 16),

            ConstituencyDropdown(
              countyId: _county?.id,
              selectedConstituencyId: _constituency?.id,
              onChanged: (id) {
                setState(() {
                  if (id == null) {
                    _constituency = null;
                    _ward = null;
                    return;
                  }
                  _constituency = context
                      .read<GeographyBloc>()
                      .state
                      .constituenciesIn(_county!.id)
                      .firstWhere((c) => c.id == id);
                  _ward = null;
                });
              },
            ),
            const SizedBox(height: 16),

            WardDropdown(
              constituencyId: _constituency?.id,
              selectedWardId: _ward?.id,
              isOptional: true,
              onChanged: (id) {
                setState(() {
                  if (id == null) {
                    _ward = null;
                    return;
                  }
                  _ward = context
                      .read<GeographyBloc>()
                      .state
                      .wardsIn(_constituency!.id)
                      .firstWhere((w) => w.id == id);
                });
              },
            ),
            const SizedBox(height: 32),

            AppPrimaryButton(
              borderRadius: 12,
              color: AppColors.primaryColor,
              onPressed: _canContinue ? _continue : null,
              label: AppLocalizations.getString(context, 'common.continue'),
            ),
          ],
        ),
      ),
    );
  }
}
