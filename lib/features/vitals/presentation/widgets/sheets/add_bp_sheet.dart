import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/common/widgets/app_bottom_sheet.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';

class AddBpSheet extends StatefulWidget {
  const AddBpSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<VitalsBloc>(),
        child: const AddBpSheet(),
      ),
    );
  }

  @override
  State<AddBpSheet> createState() => _AddBpSheetState();
}

class _AddBpSheetState extends State<AddBpSheet> {
  final _formKey = GlobalKey<FormState>();
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _takenAt = DateTime.now();
  String? _dialysisPhase;

  @override
  void dispose() {
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _pulseCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String? _validateBp(String? v, {required int max}) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Numbers only';
    if (n < 30 || n > max) return 'Must be 30–$max';
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      AppSnackbar.warning(context, 'Please check the highlighted fields.');
      return;
    }

    final payload = <String, dynamic>{
      'systolic': int.parse(_sysCtrl.text.trim()),
      'diastolic': int.parse(_diaCtrl.text.trim()),
      if (_pulseCtrl.text.trim().isNotEmpty)
        'pulse': int.parse(_pulseCtrl.text.trim()),
      if (_weightCtrl.text.trim().isNotEmpty)
        'weight_kg': _weightCtrl.text.trim(),
      if (_dialysisPhase != null) 'dialysis_phase': _dialysisPhase,
      'taken_at': isoTimestampUtc(_takenAt),
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
    };

    context.read<VitalsBloc>().add(AddBpReadingEvent(payload));
    Navigator.of(context).pop();
    AppSnackbar.success(context, 'Blood pressure reading saved.');
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _takenAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_takenAt),
    );
    if (time == null) return;
    setState(() {
      _takenAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSubmitting = context.select<VitalsBloc, bool>(
      (b) => b.state.isSubmitting,
    );

    return AppBottomSheet(
      title: AppLocalizations.getString(context, 'vitals.logBp'),
      subtitle: AppLocalizations.getString(context, 'vitals.logBpSub'),
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
            Row(
              children: [
                Expanded(
                  child: SoftInput(
                    controller: _sysCtrl,
                    label: AppLocalizations.getString(
                      context,
                      'vitals.systolic',
                    ),
                    suffixText: 'mmHg',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => _validateBp(v, max: 300),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SoftInput(
                    controller: _diaCtrl,
                    label: AppLocalizations.getString(
                      context,
                      'vitals.diastolic',
                    ),
                    suffixText: 'mmHg',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => _validateBp(v, max: 200),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SoftInput(
                    controller: _pulseCtrl,
                    label: AppLocalizations.getString(context, 'vitals.pulse'),
                    suffixText: 'bpm',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SoftInput(
                    controller: _weightCtrl,
                    label: AppLocalizations.getString(context, 'vitals.weight'),
                    suffixText: 'kg',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SoftDropdown<String>(
              value: _dialysisPhase,
              label: AppLocalizations.getString(
                context,
                'vitals.dialysisPhase',
              ),
              items: const [
                DropdownMenuItem(value: 'pre', child: Text('Pre-dialysis')),
                DropdownMenuItem(value: 'intra', child: Text('Intra-dialysis')),
                DropdownMenuItem(value: 'post', child: Text('Post-dialysis')),
              ],
              onChanged: (v) => setState(() => _dialysisPhase = v),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: AppLocalizations.getString(
                    context,
                    'vitals.takenAt',
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
                    friendlyDateTime(_takenAt.toIso8601String()),
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SoftInput(
              controller: _notesCtrl,
              label: AppLocalizations.getString(context, 'medication.notes'),
              maxLines: 3,
              minLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
