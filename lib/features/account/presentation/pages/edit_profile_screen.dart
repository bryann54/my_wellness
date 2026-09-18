// lib/features/account/presentation/screens/edit_profile_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_form_field.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';

@RoutePage()
class EditProfileScreen extends StatefulWidget {
  final HealthProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalIdController;

  String? _selectedGender;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _nationalIdController = TextEditingController(
      text: widget.profile.nationalIdNumber ?? '',
    );

    _selectedGender = widget.profile.gender.isEmpty
        ? null
        : widget.profile.gender;
    _dateOfBirth = widget.profile.dateOfBirth == null
        ? null
        : DateTime.tryParse(widget.profile.dateOfBirth!);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
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
      initialDate: _dateOfBirth ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  /// Splits `full_name` on the first whitespace so we can still send
  /// `first_name` + `surname` to the PATCH endpoint.
  ({String first, String last}) _splitName(String full) {
    final trimmed = full.trim();
    if (trimmed.isEmpty) return (first: '', last: '');
    final idx = trimmed.indexOf(' ');
    if (idx < 0) return (first: trimmed, last: '');
    return (
      first: trimmed.substring(0, idx),
      last: trimmed.substring(idx + 1).trim(),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _splitName(_fullNameController.text);

    final updatedData = <String, dynamic>{
      'first_name': name.first,
      'surname': name.last,
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      if (_selectedGender != null) 'gender': _selectedGender,
      'date_of_birth': _dateOfBirth == null ? null : _isoDate(_dateOfBirth!),
      'national_id_number': _nationalIdController.text.trim().isEmpty
          ? null
          : _nationalIdController.text.trim(),
    };

    context.read<AccountBloc>().add(
      UpdateProfileEvent(updatedData: updatedData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: context.read<AccountBloc>(),
      child: BlocListener<AccountBloc, AccountState>(
        listenWhen: (prev, curr) =>
            curr.status == AccountStatus.updated ||
            curr.status == AccountStatus.error,
        listener: (context, state) {
          if (state.status == AccountStatus.updated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'Profile updated'),
                backgroundColor: Colors.green,
              ),
            );
            context.router.maybePop();
          } else if (state.status == AccountStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error'),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              CustomAppBar(
                title: AppLocalizations.getString(
                  context,
                  'profile.editProfile',
                ),
                isHome: false,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Full name
                          AppFormField(
                                controller: _fullNameController,
                                label: AppLocalizations.getString(
                                  context,
                                  'profile.fullName',
                                ),
                                hint: 'Alex Carter',
                                icon: const Icon(Icons.person_outline),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Name is required'
                                    : null,
                              )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Email (read-only — server does not allow changing
                          // this through the profile PATCH)
                          AppFormField(
                                controller: _emailController,
                                label: AppLocalizations.getString(
                                  context,
                                  'profile.email',
                                ),
                                hint: 'john@example.com',
                                icon: const Icon(Icons.email_outlined),
                                readOnly: true,
                              )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: 50.ms)
                              .slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Phone
                          AppFormField(
                                controller: _phoneController,
                                label: AppLocalizations.getString(
                                  context,
                                  'profile.phone',
                                ),
                                hint: '+254 700 000 000',
                                icon: const Icon(Icons.phone_outlined),
                              )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: 100.ms)
                              .slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Gender
                          DropDownWidget<String>(
                                label: AppLocalizations.getString(
                                  context,
                                  'profile.gender',
                                ),
                                selectedItem: _selectedGender,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'male',
                                    child: Text('Male'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'female',
                                    child: Text('Female'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'other',
                                    child: Text('Other'),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _selectedGender = v),
                                hintText: 'Select gender',
                              )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: 150.ms)
                              .slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Date of birth
                          InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.getString(
                                      context,
                                      'profile.dateOfBirth',
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _dateOfBirth == null
                                        ? 'Select date'
                                        : _isoDate(_dateOfBirth!),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: 200.ms)
                              .slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // National ID
                          AppFormField(
                                controller: _nationalIdController,
                                label: AppLocalizations.getString(
                                  context,
                                  'profile.nationalId',
                                ),
                                hint: '12345678',
                                icon: const Icon(Icons.credit_card_outlined),
                              )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: 250.ms)
                              .slideY(begin: 0.1),
                          const SizedBox(height: 32),

                          BlocBuilder<AccountBloc, AccountState>(
                            builder: (context, state) {
                              final isLoading =
                                  state.status == AccountStatus.updating;
                              return AppPrimaryButton(
                                    onPressed: isLoading ? null : _submit,
                                    label: AppLocalizations.getString(
                                      context,
                                      'common.save',
                                    ),
                                    isLoading: isLoading,
                                  )
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: 300.ms)
                                  .scale();
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
