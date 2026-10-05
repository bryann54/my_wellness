import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication_scan.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/medication_candidate_picker.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/scan_medication_card.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_toast_listener.dart';

@RoutePage()
class AddMedicationScreen extends StatelessWidget {
  final String? condition;

  const AddMedicationScreen({super.key, this.condition});

  @override
  Widget build(BuildContext context) {
    return VitalsToastListener(
      child: BlocProvider.value(
        value: context.read<VitalsBloc>(),
        child: _AddMedicationBody(condition: condition),
      ),
    );
  }
}

class _AddMedicationBody extends StatefulWidget {
  final String? condition;
  const _AddMedicationBody({this.condition});

  @override
  State<_AddMedicationBody> createState() => _AddMedicationBodyState();
}

class _AddMedicationBodyState extends State<_AddMedicationBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _freqCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();

  String? _condition;
  String _durationUnit = 'days';
  DateTime _startDate = DateTime.now();

  bool _scanning = false;
  MedicationScanResult? _scanResult;
  MedicationCandidateOption? _pickedCandidate;

  @override
  void initState() {
    super.initState();
    _condition = widget.condition;
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

  Future<void> _scan(ImageSource source) async {
    if (_scanning) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (file == null || !mounted) return;

    setState(() {
      _scanning = true;
      _scanResult = null;
      _pickedCandidate = null;
    });

    final result = await context.read<VitalsBloc>().scanMedication(
      filePath: file.path,
    );

    if (!mounted) return;

    result.fold(
      (f) {
        setState(() => _scanning = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f)));
      },
      (scan) {
        setState(() {
          _scanning = false;
          _scanResult = scan;
        });
        _applyScanResult(scan);
      },
    );
  }

  void _applyScanResult(MedicationScanResult scan) {
    if (scan.confirmed.isNotEmpty) {
      final m = scan.confirmed.first;
      _nameCtrl.text = m.name ?? m.rawName ?? '';
      _doseCtrl.text = m.dosage ?? '';
      _freqCtrl.text = m.frequency ?? '';
      _notesCtrl.text = m.notes ?? '';
      return;
    }

    if (scan.needsConfirmation.isNotEmpty) {
      final nc = scan.needsConfirmation.first;
      _nameCtrl.text = nc.rawName ?? '';
      _doseCtrl.text = nc.dosage ?? '';
      _freqCtrl.text = nc.frequency ?? '';
      _notesCtrl.text = nc.notes ?? '';

      if (nc.candidates.isNotEmpty) {
        _pickedCandidate = nc.candidates.first;
        _nameCtrl.text = _pickedCandidate!.name;
      }
    }
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
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSubmitting = context.select<VitalsBloc, bool>(
      (b) => b.state.isSubmitting,
    );

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          CustomAppBar(
            title: AppLocalizations.getString(context, 'medications.addTitle'),
            isHome: false,
          ),
        ],
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    ScanMedicationCard(
                      scanning: _scanning,
                      onCamera: () => _scan(ImageSource.camera),
                      onUpload: () => _scan(ImageSource.gallery),
                    ),
                    if (_scanResult != null &&
                        _scanResult!.needsConfirmation.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      MedicationCandidatePicker(
                        entry: _scanResult!.needsConfirmation.first,
                        selected: _pickedCandidate,
                        onSelected: (opt) {
                          setState(() {
                            _pickedCandidate = opt;
                            _nameCtrl.text = opt.name;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildFormFields(cs),
                  ],
                ),
              ),
              _buildBottomBar(cs, isSubmitting),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name
        SoftInput(
          controller: _nameCtrl,
          label: AppLocalizations.getString(context, 'medications.name'),
          textCapitalization: TextCapitalization.words,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 14),

        // Dosage + Frequency
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SoftInput(
                controller: _doseCtrl,
                label: AppLocalizations.getString(
                  context,
                  'medications.dosage',
                ),
                hint: '10 mg',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SoftInput(
                controller: _freqCtrl,
                label: AppLocalizations.getString(
                  context,
                  'medications.frequency',
                ),
                hint: 'Twice daily',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Condition
        SoftDropdown<String>(
          value: _condition,
          label: AppLocalizations.getString(
            context,
            'medications.conditionLabel',
          ),
          items: [
            DropdownMenuItem(
              value: 'hypertension',
              child: Text(
                AppLocalizations.getString(context, 'condition.hypertension'),
              ),
            ),
            DropdownMenuItem(
              value: 'diabetes',
              child: Text(
                AppLocalizations.getString(context, 'condition.diabetes'),
              ),
            ),
          ],
          onChanged: (v) => setState(() => _condition = v),
        ),
        const SizedBox(height: 14),

        // Start date
        InkWell(
          onTap: _pickStart,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: AppLocalizations.getString(
                context,
                'medications.startDate',
              ),
              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              labelStyle: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                isoDate(_startDate),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Duration
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SoftInput(
                controller: _durationCtrl,
                label: AppLocalizations.getString(
                  context,
                  'medications.duration',
                ),
                hint: AppLocalizations.getString(
                  context,
                  'medications.optional',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SoftDropdown<String>(
                value: _durationUnit,
                label: AppLocalizations.getString(
                  context,
                  'medications.durationUnit',
                ),
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
                onChanged: (v) => setState(() => _durationUnit = v ?? 'days'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Notes
        SoftInput(
          controller: _notesCtrl,
          label: AppLocalizations.getString(context, 'medications.notes'),
          maxLines: 3,
          minLines: 2,
        ),
      ],
    );
  }

  Widget _buildBottomBar(ColorScheme cs, bool isSubmitting) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSubmitting ? null : () => context.router.maybePop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
                foregroundColor: cs.onSurface,
              ),
              child: Text(
                AppLocalizations.getString(context, 'common.cancel'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AppPrimaryButton(
              color: AppColors.primaryColor,
              onPressed: _submit,
              isLoading: isSubmitting,
              borderRadius: 14,
              label: AppLocalizations.getString(context, 'medications.save'),
            ),
          ),
        ],
      ),
    );
  }
}
