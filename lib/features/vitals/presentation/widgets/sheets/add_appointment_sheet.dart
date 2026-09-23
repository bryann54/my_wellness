// lib/features/vitals/presentation/widgets/sheets/add_appointment_sheet.dart
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
  final _clinicCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _date = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  String? _condition;

  @override
  void dispose() {
    _clinicCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      AppSnackbar.warning(context, 'Please check the highlighted fields.');
      return;
    }

    final dt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final payload = <String, dynamic>{
      if (_condition != null) 'condition': _condition,
      'clinic_name': _clinicCtrl.text.trim(),
      'appointment_date': isoDate(dt),
      'appointment_time': isoTimestampUtc(dt),
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
    };

    context.read<VitalsBloc>().add(AddAppointmentEvent(payload));
    Navigator.of(context).pop();
    AppSnackbar.success(context, 'Appointment booked.');
  }

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
            SoftInput(
              controller: _clinicCtrl,
              label: AppLocalizations.getString(context, 'appointments.clinic'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppLocalizations.getString(context, 'common.required')
                  : null,
            ),
            const SizedBox(height: 12),
            SoftDropdown<String>(
              value: _condition,
              label: AppLocalizations.getString(
                context,
                'appointments.condition',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'hypertension',
                  child: Text('Hypertension'),
                ),
                DropdownMenuItem(value: 'diabetes', child: Text('Diabetes')),
              ],
              onChanged: (v) => setState(() => _condition = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.getString(
                          context,
                          'appointments.date',
                        ),
                        prefixIcon: const Icon(Icons.event_outlined, size: 20),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          isoDate(_date),
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.getString(
                          context,
                          'appointments.time',
                        ),
                        prefixIcon: const Icon(Icons.schedule, size: 20),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          _time.format(context),
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SoftInput(
              controller: _notesCtrl,
              label: AppLocalizations.getString(context, 'common.notes'),
              maxLines: 3,
              minLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
