import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _formTick = ValueNotifier<int>(0);

  String? _clinicType;
  DateTime? _date;
  TimeOfDay? _time;
  String? _clinicName;
  String? _facilityId;
  bool _remindMe = true;
  final Set<String> _reminderChannels = {'whatsapp'};

  StreamSubscription<AppointmentsState>? _submissionSubscription;

  static const _clinicTypes = <(String, String)>[
    ('general', 'General medical clinic'),
    ('hypertension', 'Hypertension clinic'),
    ('diabetes', 'Diabetes clinic'),
    ('cardiology', 'Cardiology clinic'),
    ('oncology', 'Oncology clinic'),
    ('gynaecology', 'Gynaecology clinic'),
    ('mental_health', 'Mental health clinic'),
    ('surgical', 'Surgical clinic'),
    ('other', 'Other clinic'),
  ];

  @override
  void initState() {
    super.initState();
    _submissionSubscription = context.read<AppointmentsBloc>().stream.listen((
      state,
    ) {
      if (state.toastType == ToastType.success && mounted) {
        context.router.maybePop();
      }
    });
  }

  @override
  void dispose() {
    unawaited(_submissionSubscription?.cancel());
    _formTick.dispose();
    super.dispose();
  }

  void _markDirty() => _formTick.value++;

  bool get _canSubmit =>
      _clinicType != null &&
      _date != null &&
      (_clinicName?.trim().isNotEmpty ?? false);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: Localizations.localeOf(context),
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
      _markDirty();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Localizations.override(
        context: context,
        locale: Localizations.localeOf(context),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _time = picked);
      _markDirty();
    }
  }

  void _submit() {
    if (!_canSubmit) return;
    if (_formKey.currentState?.validate() != true) return;

    final payload = <String, dynamic>{
      'clinic_name': _clinicName!.trim(),
      'condition': _clinicType ?? 'general',
      'appointment_date': isoDate(_date!),
      if (_time != null) 'appointment_time': _formatTimeHm(_time!),
      if (_facilityId != null) 'facility_id': _facilityId,
    };
    context.read<AppointmentsBloc>().add(AddAppointmentEvent(payload));
  }

  static String _formatTimeHm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSubmitting = context.select<AppointmentsBloc, bool>(
      (b) => b.state.isSubmitting,
    );

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(
            title: AppLocalizations.getString(context, 'appointments.book'),
            isHome: false,
          ),
        ],
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, AppSpacing.md, 24, 40),
            children: [
              Text(
                'Keep track of your visits and never miss a checkup.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),

              _FieldLabel('Type of clinic'),
              const SizedBox(height: 8),
              SoftDropdown<String>(
                value: _clinicType,
                label: 'Select clinic type',
                items: _clinicTypes
                    .map(
                      (e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() => _clinicType = v);
                  _markDirty();
                },
              ),
              const SizedBox(height: 20),

              _FieldLabel('Appointment date'),
              const SizedBox(height: 8),
              _PickerField(
                value: _date == null ? 'Pick a date' : _formatDate(_date!),
                isPlaceholder: _date == null,
                icon: Icons.calendar_today_outlined,
                onTap: _pickDate,
              ),
              const SizedBox(height: 20),

              _FieldLabel('Time (optional)'),
              const SizedBox(height: 8),
              _PickerField(
                value: _time == null ? '--:-- --' : _time!.format(context),
                isPlaceholder: _time == null,
                icon: Icons.access_time_rounded,
                onTap: _pickTime,
                onClear: _time == null
                    ? null
                    : () {
                        setState(() => _time = null);
                        _markDirty();
                      },
              ),
              const SizedBox(height: 20),

              _FieldLabel('Facility'),
              const SizedBox(height: 8),
              FacilitySearchField(
                onChanged: (name, id) {
                  setState(() {
                    _clinicName = name;
                    _facilityId = id;
                  });
                  _markDirty();
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Pick a facility so we can send the right details.',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),

              const SizedBox(height: 24),
              _RemindersCard(
                remindMe: _remindMe,
                onRemindChanged: (v) => setState(() => _remindMe = v),
                channels: _reminderChannels,
                onChannelToggled: (channel) {
                  setState(() {
                    if (_reminderChannels.contains(channel)) {
                      _reminderChannels.remove(channel);
                    } else {
                      _reminderChannels.add(channel);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: ValueListenableBuilder<int>(
            valueListenable: _formTick,
            builder: (_, _, _) => AppPrimaryButton(
              onPressed: (!_canSubmit || isSubmitting) ? null : _submit,
              label: 'Save appointment',
              isLoading: isSubmitting,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String value;
  final bool isPlaceholder;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _PickerField({
    required this.value,
    required this.isPlaceholder,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  color: isPlaceholder
                      ? cs.onSurface.withValues(alpha: 0.4)
                      : cs.onSurface,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            Icon(icon, size: 20, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _RemindersCard extends StatelessWidget {
  final bool remindMe;
  final ValueChanged<bool> onRemindChanged;
  final Set<String> channels;
  final ValueChanged<String> onChannelToggled;

  const _RemindersCard({
    required this.remindMe,
    required this.onRemindChanged,
    required this.channels,
    required this.onChannelToggled,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: remindMe,
                  onChanged: (v) => onRemindChanged(v ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Remind me before this appointment',
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (remindMe) ...[
            const SizedBox(height: 16),
            Text(
              'Send reminders by (choose one or more)',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ChannelChip(
                  label: 'WhatsApp',
                  icon: Icons.chat_bubble_outline_rounded,
                  isSelected: channels.contains('whatsapp'),
                  onTap: () => onChannelToggled('whatsapp'),
                ),
                const SizedBox(width: 8),
                _ChannelChip(
                  label: 'Email',
                  icon: Icons.mail_outline_rounded,
                  isSelected: channels.contains('email'),
                  onTap: () => onChannelToggled('email'),
                ),
                const SizedBox(width: 8),
                _ChannelChip(
                  label: 'SMS',
                  icon: Icons.sms_outlined,
                  isSelected: channels.contains('sms'),
                  onTap: () => onChannelToggled('sms'),
                ),
                const SizedBox(width: 8),
                _ChannelChip(
                  label: 'Push',
                  icon: Icons.notifications_none_rounded,
                  isSelected: channels.contains('push'),
                  onTap: () => onChannelToggled('push'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'SMS: applicable charges apply. Delivery uses your verified '
              'contact details after consent and activation.',
              style: GoogleFonts.inter(
                fontSize: 11,
                height: 1.4,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChannelChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChannelChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? cs.primary
                  : cs.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
