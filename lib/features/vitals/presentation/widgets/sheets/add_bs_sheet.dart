// lib/features/vitals/presentation/widgets/sheets/add_bs_sheet.dart
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

class AddBsSheet extends StatefulWidget {
  const AddBsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<VitalsBloc>(),
        child: const AddBsSheet(),
      ),
    );
  }

  @override
  State<AddBsSheet> createState() => _AddBsSheetState();
}

class _AddBsSheetState extends State<AddBsSheet> {
  final _formKey = GlobalKey<FormState>();
  final _valueCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _unit = 'mmol/L';
  String _readingType = 'random';
  String? _mealTiming;
  DateTime _takenAt = DateTime.now();

  @override
  void dispose() {
    _valueCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      AppSnackbar.warning(context, 'Please check the highlighted fields.');
      return;
    }

    final payload = <String, dynamic>{
      'value': _valueCtrl.text.trim(),
      'unit': _unit,
      'reading_type': _readingType,
      if (_mealTiming != null) 'meal_timing': _mealTiming,
      if (_weightCtrl.text.trim().isNotEmpty)
        'weight_kg': _weightCtrl.text.trim(),
      'taken_at': isoTimestampUtc(_takenAt),
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
    };

    context.read<VitalsBloc>().add(AddBsReadingEvent(payload));
    Navigator.of(context).pop();
    AppSnackbar.success(context, 'Blood sugar reading saved.');
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
      title: AppLocalizations.getString(context, 'vitals.logBs'),
      subtitle: AppLocalizations.getString(context, 'vitals.logBsSub'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SoftInput(
                    controller: _valueCtrl,
                    label: AppLocalizations.getString(context, 'vitals.value'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? AppLocalizations.getString(context, 'common.required')
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SoftDropdown<String>(
                    value: _unit,
                    label: AppLocalizations.getString(context, 'vitals.unit'),
                    items: const [
                      DropdownMenuItem(value: 'mmol/L', child: Text('mmol/L')),
                      DropdownMenuItem(value: 'mg/dL', child: Text('mg/dL')),
                    ],
                    onChanged: (v) => setState(() => _unit = v ?? 'mmol/L'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SoftDropdown<String>(
              value: _readingType,
              label: AppLocalizations.getString(context, 'vitals.readingType'),
              items: const [
                DropdownMenuItem(value: 'random', child: Text('Random')),
                DropdownMenuItem(value: 'fasting', child: Text('Fasting')),
                DropdownMenuItem(value: 'post_meal', child: Text('Post-meal')),
              ],
              onChanged: (v) => setState(() => _readingType = v ?? 'random'),
            ),
            const SizedBox(height: 12),
            SoftDropdown<String>(
              value: _mealTiming,
              label: AppLocalizations.getString(context, 'vitals.mealTiming'),
              items: const [
                DropdownMenuItem(
                  value: 'less_than_2h',
                  child: Text('Less than 2h'),
                ),
                DropdownMenuItem(
                  value: 'more_than_2h',
                  child: Text('More than 2h'),
                ),
              ],
              onChanged: (v) => setState(() => _mealTiming = v),
            ),
            const SizedBox(height: 12),
            SoftInput(
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
