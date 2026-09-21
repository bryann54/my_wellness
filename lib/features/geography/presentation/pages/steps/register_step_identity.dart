import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/auth_validators.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_text_field.dart';

class IdentityDraft {
  final String? firstName;
  final String? surname;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? nationalIdNumber;

  const IdentityDraft({
    this.firstName,
    this.surname,
    this.gender,
    this.dateOfBirth,
    this.nationalIdNumber,
  });
}

class RegisterStepIdentity extends StatefulWidget {
  final IdentityDraft initial;
  final void Function(IdentityDraft) onContinue;

  const RegisterStepIdentity({
    super.key,
    required this.initial,
    required this.onContinue,
  });

  @override
  State<RegisterStepIdentity> createState() => _RegisterStepIdentityState();
}

class _RegisterStepIdentityState extends State<RegisterStepIdentity> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstCtrl;
  late final TextEditingController _surnameCtrl;
  late final TextEditingController _nationalIdCtrl;

  String? _gender;
  DateTime? _dob;

  @override
  void initState() {
    super.initState();
    _firstCtrl = TextEditingController(text: widget.initial.firstName ?? '');
    _surnameCtrl = TextEditingController(text: widget.initial.surname ?? '');
    _nationalIdCtrl = TextEditingController(
      text: widget.initial.nationalIdNumber ?? '',
    );
    _gender = widget.initial.gender;
    _dob = widget.initial.dateOfBirth;
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _surnameCtrl.dispose();
    _nationalIdCtrl.dispose();
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
    widget.onContinue(
      IdentityDraft(
        firstName: _firstCtrl.text.trim(),
        surname: _surnameCtrl.text.trim(),
        gender: _gender,
        dateOfBirth: _dob,
        nationalIdNumber: _nationalIdCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _gender = v),
              hintText: 'Select gender',
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
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
                child: Text(_dob == null ? 'Select date' : _isoDate(_dob!)),
              ),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _nationalIdCtrl,
              label: AppLocalizations.getString(
                context,
                'auth.nationalIdNumber',
              ),
              icon: Icons.credit_card_outlined,
              validator: (v) => AuthValidators.validateNationalId(context, v),
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
