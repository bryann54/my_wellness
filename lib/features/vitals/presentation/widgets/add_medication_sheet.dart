import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';

class AddMedicationSheet extends StatefulWidget {
  const AddMedicationSheet({super.key, this.initialCondition});

  /// Optional pre-fill for the per-condition flow.
  final String? initialCondition;

  static Future<void> show(BuildContext context, {String? condition}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<VitalsBloc>(),
        child: AddMedicationSheet(initialCondition: condition),
      ),
    );
  }

  @override
  State<AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<AddMedicationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _freqCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();

  String? _condition;
  String _durationUnit = 'days';
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _condition = widget.initialCondition;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _freqCtrl.dispose();
    _notesCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    final payload = <String, dynamic>{
      if (_condition != null) 'condition': _condition,
      'name': _nameCtrl.text.trim(),
      'dosage': _doseCtrl.text.trim(),
      'frequency': _freqCtrl.text.trim(),
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      'start_date': isoDate(_startDate),
      if (_durationCtrl.text.trim().isNotEmpty)
        'duration_value': int.parse(_durationCtrl.text.trim()),
      'duration_unit': _durationUnit,
    };

    context.read<VitalsBloc>().add(AddMedicationEvent(payload));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSubmitting = context.select<VitalsBloc, bool>(
      (b) => b.state.isSubmitting,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.getString(
                        context,
                        'medications.addTitle',
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: InputDecoration(
                  labelText: AppLocalizations.getString(
                    context,
                    'medications.name',
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _doseCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: InputDecoration(
                  labelText: AppLocalizations.getString(
                    context,
                    'medications.dosage',
                  ),
                  hintText: '10 mg',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _freqCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: InputDecoration(
                  labelText: AppLocalizations.getString(
                    context,
                    'medications.frequency',
                  ),
                  hintText: 'Twice daily',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              DropDownWidget<String>(
                label: AppLocalizations.getString(
                  context,
                  'medications.conditionLabel',
                ),
                selectedItem: _condition,
                hintText: 'Optional',
                items: const [
                  DropdownMenuItem(
                    value: 'hypertension',
                    child: Text('Hypertension'),
                  ),
                  DropdownMenuItem(value: 'diabetes', child: Text('Diabetes')),
                ],
                onChanged: (v) => setState(() => _condition = v),
              ),
              const SizedBox(height: 4),

              InkWell(
                onTap: _pickStart,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.getString(
                      context,
                      'medications.startDate',
                    ),
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(isoDate(_startDate)),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _durationCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.getString(
                          context,
                          'medications.duration',
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropDownWidget<String>(
                      label: AppLocalizations.getString(
                        context,
                        'medications.durationUnit',
                      ),
                      selectedItem: _durationUnit,
                      showLabel: false,
                      items: [
                        DropdownMenuItem(
                          value: 'days',
                          child: Text(
                            AppLocalizations.getString(
                              context,
                              'medications.unitDays',
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'weeks',
                          child: Text(
                            AppLocalizations.getString(
                              context,
                              'medications.unitWeeks',
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'months',
                          child: Text(
                            AppLocalizations.getString(
                              context,
                              'medications.unitMonths',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _durationUnit = v ?? 'days'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: AppLocalizations.getString(
                    context,
                    'medications.notes',
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              FilledButton(
                onPressed: isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppLocalizations.getString(context, 'medications.save'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
