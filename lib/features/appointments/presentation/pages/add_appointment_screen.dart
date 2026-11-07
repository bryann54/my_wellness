import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:my_wellness/features/appointments/presentation/widgets/facility_search_field.dart';

@RoutePage()
class AddAppointmentScreen extends StatelessWidget {
  const AddAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AppointmentsBloc>(),
      child: const _AddAppointmentBody(),
    );
  }
}

class _AddAppointmentBody extends StatefulWidget {
  const _AddAppointmentBody();

  @override
  State<_AddAppointmentBody> createState() => _AddAppointmentBodyState();
}

class _AddAppointmentBodyState extends State<_AddAppointmentBody> {
  static const _clinicTypes = <String>[
    'general',
    'hypertension',
    'diabetes',
    'cardiology',
    'oncology',
    'gynaecology',
    'mental_health',
    'surgical',
    'other',
  ];

  String _clinicTypeLabel(BuildContext context, String value) {
    final key = switch (value) {
      'general' => 'appointments.clinicGeneral',
      'hypertension' => 'appointments.clinicHypertension',
      'diabetes' => 'appointments.clinicDiabetes',
      'cardiology' => 'appointments.clinicCardiology',
      'oncology' => 'appointments.clinicOncology',
      'gynaecology' => 'appointments.clinicGynaecology',
      'mental_health' => 'appointments.clinicMentalHealth',
      'surgical' => 'appointments.clinicSurgical',
      _ => 'appointments.clinicOther',
    };
    return AppLocalizations.getString(context, key);
  }

  final _typeText = TextEditingController();
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();

  String? _clinicType;
  DateTime? _date;
  TimeOfDay? _time;
  String? _clinicName;
  String? _facilityId;

  @override
  void dispose() {
    _typeText.dispose();
    _dateText.dispose();
    _timeText.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _clinicType != null &&
      _date != null &&
      (_clinicName?.trim().isNotEmpty ?? false);

  Future<void> _pickClinicType() async {
    FocusScope.of(context).unfocus();
    final primary = Theme.of(context).colorScheme.primary;

    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        children: [
          for (final value in _clinicTypes)
            ListTile(
              title: Text(_clinicTypeLabel(context, value)),
              trailing: value == _clinicType
                  ? Icon(Icons.check_rounded, color: primary)
                  : null,
              onTap: () => Navigator.of(ctx).pop(value),
            ),
        ],
      ),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _clinicType = picked;
      _typeText.text = _clinicTypeLabel(context, picked);
    });
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      locale: Localizations.localeOf(context),
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _date = picked;
      _dateText.text = fmtDate(picked);
    });
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Localizations.override(
        context: context,
        locale: Localizations.localeOf(context),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _time = picked;
      _timeText.text = picked.format(context);
    });
  }

  void _clearTime() => setState(() {
    _time = null;
    _timeText.clear();
  });

  static String _hm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  void _submit() {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();

    context.read<AppointmentsBloc>().add(
      AddAppointmentEvent({
        'clinic_name': _clinicName!.trim(),
        'condition': _clinicType!,
        'appointment_date': isoDate(_date!),
        if (_time != null) 'appointment_time': _hm(_time!),
        if (_facilityId != null) 'facility_id': _facilityId,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSubmitting = context.select<AppointmentsBloc, bool>(
      (b) => b.state.isSubmitting,
    );

    return BlocListener<AppointmentsBloc, AppointmentsState>(
      listenWhen: (p, c) =>
          p.isSubmitting && !c.isSubmitting && c.toastType == ToastType.success,
      listener: (context, _) => context.router.pop(),
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            CustomAppBar(
              title: AppLocalizations.getString(context, 'appointments.book'),
              isHome: false,
            ),
          ],
          body: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              24,
              AppSpacing.lg,
              24,
              AppSpacing.lg,
            ),
            children: [
              FacilitySearchField(
                onChanged: (name, id) => setState(() {
                  _clinicName = name;
                  _facilityId = id;
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              SoftInput(
                controller: _typeText,
                label: AppLocalizations.getString(
                  context,
                  'appointments.clinicType',
                ),
                hint: AppLocalizations.getString(
                  context,
                  'appointments.selectClinicType',
                ),
                readOnly: true,
                onTap: _pickClinicType,
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SoftInput(
                      controller: _dateText,
                      label: AppLocalizations.getString(
                        context,
                        'appointments.date',
                      ),
                      hint: AppLocalizations.getString(
                        context,
                        'appointments.selectDate',
                      ),
                      readOnly: true,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 4),
                  Expanded(
                    child: SoftInput(
                      controller: _timeText,
                      label: AppLocalizations.getString(
                        context,
                        'appointments.timeOptional',
                      ),
                      hint: AppLocalizations.getString(
                        context,
                        'appointments.selectTime',
                      ),
                      readOnly: true,
                      onTap: _pickTime,
                      suffixIcon: _time == null
                          ? null
                          : IconButton(
                              onPressed: _clearTime,
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: cs.onSurfaceVariant,
                              visualDensity: VisualDensity.compact,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: AppPrimaryButton(
              onPressed: (!_canSubmit || isSubmitting) ? null : _submit,
              label: AppLocalizations.getString(context, 'appointments.save'),
              isLoading: isSubmitting,
            ),
          ),
        ),
      ),
    );
  }
}
