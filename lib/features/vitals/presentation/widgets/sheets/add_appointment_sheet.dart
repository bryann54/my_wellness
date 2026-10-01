import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/common/widgets/app_bottom_sheet.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/facility_search_field.dart';

class AddAppointmentSheet extends StatefulWidget {
  const AddAppointmentSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<VitalsBloc>(),
        child: const AddAppointmentSheet(),
      ),
    );
  }

  @override
  State<AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

class _AddAppointmentSheetState extends State<AddAppointmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();

  DateTime _when = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  String _condition = 'other';

  /// Populated by [FacilitySearchField].
  String? _clinicName;
  String? _facilityId;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickWhen() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: _time);
    if (time == null) return;

    setState(() {
      _when = DateTime(date.year, date.month, date.day);
      _time = time;
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    if (_clinicName == null || _clinicName!.trim().isEmpty) {
      AppSnackbar.warning(
        context,
        AppLocalizations.getString(context, 'appointments.clinicRequired'),
      );
      return;
    }

    final payload = <String, dynamic>{
      'condition': _condition,
      'clinic_name': _clinicName!.trim(),
      if (_facilityId != null) 'facility_id': _facilityId,
      'appointment_date': isoDate(_when),
      'appointment_time': _formatTimeHm(_time),
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
    };

    context.read<VitalsBloc>().add(AddAppointmentEvent(payload));
    Navigator.of(context).pop();
  }

  static String _formatTimeHm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSubmitting = context.select<VitalsBloc, bool>(
      (b) => b.state.isSubmitting,
    );

    return AppBottomSheet(
      title: AppLocalizations.getString(context, 'appointments.book'),
      subtitle: AppLocalizations.getString(context, 'appointments.bookSub'),
      primaryLabel: AppLocalizations.getString(context, 'common.save'),
      secondaryLabel: AppLocalizations.getString(context, 'common.cancel'),
      onSecondaryPressed: () => Navigator.of(context).maybePop(),
      isSubmitting: isSubmitting,
      onPrimaryPressed: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Facility ─────────────────────────────────────────────
            _SectionLabel(
              label: AppLocalizations.getString(
                context,
                'appointments.sectionFacility',
              ),
            ),
            const SizedBox(height: 8),
            FacilitySearchField(
              onChanged: (name, id) {
                setState(() {
                  _clinicName = name;
                  _facilityId = id;
                });
              },
            ),

            const SizedBox(height: 20),

            // ── Condition ────────────────────────────────────────────
            _SectionLabel(
              label: AppLocalizations.getString(
                context,
                'appointments.sectionCondition',
              ),
            ),
            const SizedBox(height: 8),
            SoftDropdown<String>(
              value: _condition,
              items: [
                DropdownMenuItem(
                  value: 'other',
                  child: Text(
                    AppLocalizations.getString(context, 'condition.other'),
                  ),
                ),
                DropdownMenuItem(
                  value: 'hypertension',
                  child: Text(
                    AppLocalizations.getString(
                      context,
                      'condition.hypertension',
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'diabetes',
                  child: Text(
                    AppLocalizations.getString(context, 'condition.diabetes'),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _condition = v ?? 'other'),
            ),

            const SizedBox(height: 20),

            // ── When ─────────────────────────────────────────────────
            _SectionLabel(
              label: AppLocalizations.getString(
                context,
                'appointments.sectionWhen',
              ),
            ),
            const SizedBox(height: 8),
            _WhenTile(when: _when, time: _time, onTap: _pickWhen, cs: cs),

            const SizedBox(height: 20),

            // ── Notes ────────────────────────────────────────────────
            _SectionLabel(
              label: AppLocalizations.getString(
                context,
                'appointments.sectionNotes',
              ),
            ),
            const SizedBox(height: 8),
            SoftInput(
              controller: _notesCtrl,
              hint: AppLocalizations.getString(context, 'common.optionalNotes'),
              maxLines: 3,
              minLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: cs.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

// ── When tile ────────────────────────────────────────────────────────────────

class _WhenTile extends StatelessWidget {
  final DateTime when;
  final TimeOfDay time;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _WhenTile({
    required this.when,
    required this.time,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel = _friendlyDay(when);
    final timeLabel = time.format(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.event_outlined, size: 20, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$dayLabel · $timeLabel',
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  static String _friendlyDay(DateTime d) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
