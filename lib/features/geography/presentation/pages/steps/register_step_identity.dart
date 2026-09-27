import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/auth_validators.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_text_field.dart';

class IdentityDraft {
  final IdType idType;
  final String idNumber;
  final String firstName;
  final String surname;
  final String? gender;
  final DateTime? dateOfBirth;

  const IdentityDraft({
    required this.idType,
    required this.idNumber,
    required this.firstName,
    required this.surname,
    this.gender,
    this.dateOfBirth,
  });
}

class RegisterStepIdentity extends StatefulWidget {
  final IdentityDraft? initial;
  final void Function(IdentityDraft) onContinue;

  const RegisterStepIdentity({
    super.key,
    this.initial,
    required this.onContinue,
  });

  @override
  State<RegisterStepIdentity> createState() => _RegisterStepIdentityState();
}

class _RegisterStepIdentityState extends State<RegisterStepIdentity> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _idCtrl;
  late final TextEditingController _firstCtrl;
  late final TextEditingController _surnameCtrl;

  IdType _idType = IdType.nationalId;
  String? _gender;
  DateTime? _dob;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _idType = i?.idType ?? IdType.nationalId;
    _idCtrl = TextEditingController(text: i?.idNumber ?? '');
    _firstCtrl = TextEditingController(text: i?.firstName ?? '');
    _surnameCtrl = TextEditingController(text: i?.surname ?? '');
    _gender = i?.gender;
    _dob = i?.dateOfBirth;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _firstCtrl.dispose();
    _surnameCtrl.dispose();
    super.dispose();
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _continue() {
    if (_formKey.currentState?.validate() != true) return;
    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.getString(context, 'auth.selectGender'),
          ),
        ),
      );
      return;
    }
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.getString(context, 'auth.selectDob')),
        ),
      );
      return;
    }
    widget.onContinue(
      IdentityDraft(
        idType: _idType,
        idNumber: _idCtrl.text.trim(),
        firstName: _firstCtrl.text.trim(),
        surname: _surnameCtrl.text.trim(),
        gender: _gender,
        dateOfBirth: _dob,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.getString(context, 'auth.idType'),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _IdTypeOption(
                    label: AppLocalizations.getString(
                      context,
                      'auth.idTypeNational',
                    ),
                    selected: _idType == IdType.nationalId,
                    onTap: () => setState(() => _idType = IdType.nationalId),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IdTypeOption(
                    label: AppLocalizations.getString(
                      context,
                      'auth.idTypeMaisha',
                    ),
                    selected: _idType == IdType.maisha,
                    onTap: () => setState(() => _idType = IdType.maisha),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _idCtrl,
              label: AppLocalizations.getString(context, 'auth.idNumber'),
              icon: Icons.credit_card_outlined,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().length < 6) {
                  return AppLocalizations.getString(
                    context,
                    'auth.invalidIdNumber',
                  );
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.getString(context, 'auth.yourDetails'),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _firstCtrl,
              label: AppLocalizations.getString(context, 'auth.firstName'),
              icon: Icons.person_outline,
              validator: (v) => AuthValidators.validateName(context, v),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _surnameCtrl,
              label: AppLocalizations.getString(context, 'auth.surname'),
              icon: Icons.person_outline,
              validator: (v) => AuthValidators.validateName(context, v),
            ),
            const SizedBox(height: 16),
            DropDownWidget<String>(
              label: AppLocalizations.getString(context, 'auth.gender'),
              selectedItem: _gender,
              isRequired: true,
              items: [
                DropdownMenuItem(
                  value: 'male',
                  child: Text(
                    AppLocalizations.getString(context, 'auth.genderMale'),
                  ),
                ),
                DropdownMenuItem(
                  value: 'female',
                  child: Text(
                    AppLocalizations.getString(context, 'auth.genderFemale'),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: AppLocalizations.getString(
                    context,
                    'auth.dateOfBirth',
                  ),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _dob == null
                      ? AppLocalizations.getString(context, 'auth.selectDate')
                      : _isoDate(_dob!),
                ),
              ),
            ),
            const SizedBox(height: 32),
            AppPrimaryButton(
              onPressed: _continue,
              label: AppLocalizations.getString(context, 'common.continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdTypeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _IdTypeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.08) : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.6),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? cs.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? cs.primary : Colors.grey.shade400,
                  width: 1.6,
                ),
              ),
              child: selected
                  ? const Center(
                      child: Icon(Icons.circle, size: 7, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
