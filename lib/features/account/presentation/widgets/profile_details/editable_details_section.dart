import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/editable/profile_contact_fields.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/editable/profile_location_fields.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/editable/profile_occupation_fields.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/profile_section_card.dart';
import 'package:my_wellness/features/geography/domain/entities/constituency.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/domain/entities/ward.dart';

class EditableDetailsSection extends StatefulWidget {
  final HealthProfile profile;
  const EditableDetailsSection({super.key, required this.profile});

  @override
  State<EditableDetailsSection> createState() => _EditableDetailsSectionState();
}

class _EditableDetailsSectionState extends State<EditableDetailsSection> {
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _occupationCtrl;

  County? _county;
  SubCounty? _subCounty;
  Constituency? _constituency;
  Ward? _ward;

  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.profile.phone)
      ..addListener(_onChanged);
    _occupationCtrl = TextEditingController(text: widget.profile.occupation)
      ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _occupationCtrl.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

void _hydrate(
    County? county,
    SubCounty? subCounty,
    Constituency? constituency,
    Ward? ward,
  ) {
    if (_hydrated) return;
    _hydrated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _county = county;
        _subCounty = subCounty;
        _constituency = constituency;
        _ward = ward;
      });
    });
  }

  bool get _isDirty {
    final p = widget.profile;
    return _phoneCtrl.text.trim() != p.phone ||
        _occupationCtrl.text.trim() != p.occupation ||
        _county?.name != p.county ||
        _subCounty?.id != p.subCounty ||
        _constituency?.id != p.constituency ||
        _ward?.id != p.ward;
  }

  void _submit() {
    final payload = <String, dynamic>{
      'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      'county': _county?.name,
      'sub_county': _subCounty?.id,
      'constituency': _constituency?.id,
      'ward': _ward?.id,
      'occupation': _occupationCtrl.text.trim(),
    };
    context.read<AccountBloc>().add(UpdateProfileEvent(updatedData: payload));
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select<AccountBloc, bool>(
      (b) => b.state.status == AccountStatus.updating,
    );

    return ProfileSectionCard(
      icon: Icons.tune_rounded,
      title: AppLocalizations.getString(context, 'profile.yourDetails'),
      children: [
        ProfileContactFields(
          profile: widget.profile,
          phoneController: _phoneCtrl,
        ),
        const SizedBox(height: 20),
        ProfileLocationFields(
          profile: widget.profile,
          county: _county,
          subCounty: _subCounty,
          constituency: _constituency,
          ward: _ward,
          onHydrate: _hydrate,
          onCountyChanged: (c) => setState(() {
            _county = c;
            _subCounty = null;
            _constituency = null;
            _ward = null;
          }),
          onSubCountyChanged: (s) => setState(() => _subCounty = s),
          onConstituencyChanged: (c) => setState(() {
            _constituency = c;
            _ward = null;
          }),
          onWardChanged: (w) => setState(() => _ward = w),
        ),
        const SizedBox(height: 20),
        ProfileOccupationFields(
          profile: widget.profile,
          occupationController: _occupationCtrl,
        ),
        const SizedBox(height: 24),
     AppPrimaryButton(onPressed: (!_isDirty || isSaving) ? null : _submit, 
     color: AppColors.primaryColor,
     borderRadius: 12,
     label: AppLocalizations.getString(context, 'profile.saveChanges'))
      ],
    );
  }
}
