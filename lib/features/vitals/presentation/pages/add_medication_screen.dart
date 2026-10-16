import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
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
  final _notesCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();

  late String _condition;
  String _frequency = 'once_daily';
  String _durationUnit = 'days';
  DateTime _startDate = DateTime.now();

  bool _scanning = false;
  MedicationScanResult? _scanResult;
  MedicationCandidateOption? _pickedCandidate;

  @override
  void initState() {
    super.initState();
    _condition = widget.condition ?? 'other';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _notesCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _scan(ImageSource source) async {
    if (_scanning) return;
    if (_condition.isEmpty) {
      AppSnackbar.warning(
        context,
        AppLocalizations.getString(context, 'medications.conditionRequired'),
      );
      return;
    }

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
      condition: _condition,
    );

    if (!mounted) return;

    result.fold(
      (f) {
        setState(() => _scanning = false);
        AppSnackbar.error(context, f);
      },
      (scan) {
        setState(() {
          _scanning = false;
          _scanResult = scan;
          _applyScanResult(scan);
        });
      },
    );
  }

  void _applyScanResult(MedicationScanResult scan) {
    if (scan.confirmed.isNotEmpty) {
      final m = scan.confirmed.first;
      _nameCtrl.text = m.name ?? m.rawName ?? '';
      _doseCtrl.text = m.dosage ?? '';
      _notesCtrl.text = m.notes ?? '';
      if (m.frequency?.isNotEmpty ?? false) {
        _frequency = m.frequency!;
      }
      return;
    }

    if (scan.needsConfirmation.isNotEmpty) {
      final nc = scan.needsConfirmation.first;
      _nameCtrl.text = nc.rawName ?? '';
      _doseCtrl.text = nc.dosage ?? '';
      _notesCtrl.text = nc.notes ?? '';
      if (nc.frequency?.isNotEmpty ?? false) {
        _frequency = nc.frequency!;
      }
      if (nc.candidates.isNotEmpty) {
        final first = nc.candidates.first;
        _pickedCandidate = first;
        _applyCandidate(first);
      }
    }
  }

  void _applyCandidate(MedicationCandidateOption candidate) {
    _nameCtrl.text = candidate.name;
    if (candidate.dosage?.isNotEmpty ?? false) {
      _doseCtrl.text = candidate.dosage!;
    }
    if (candidate.frequency?.isNotEmpty ?? false) {
      _frequency = candidate.frequency!;
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
    if (_pickedCandidate == null) return;

    final payload = <String, dynamic>{
      'condition': _condition,
      'generic_product_id': _pickedCandidate!.id,
      'dosage': _doseCtrl.text.trim(),
      'frequency': _frequency,
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
        headerSliverBuilder: (_, _) => [
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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  children: [
                    ScanMedicationCard(
                      scanning: _scanning,
                      onCamera: () => _scan(ImageSource.camera),
                      onUpload: () => _scan(ImageSource.gallery),
                    ),
                    if (_scanResult != null &&
                        _scanResult!.needsConfirmation.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      MedicationCandidatePicker(
                        entry: _scanResult!.needsConfirmation.first,
                        selected: _pickedCandidate,
                        onSelected: (opt) {
                          setState(() {
                            _pickedCandidate = opt;
                            _applyCandidate(opt);
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
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
        SoftInput(
          controller: _nameCtrl,
          label: AppLocalizations.getString(context, 'medications.name'),
          textCapitalization: TextCapitalization.words,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: AppSpacing.md),
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
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: SoftDropdown<String>(
                value: _frequency,
                label: AppLocalizations.getString(
                  context,
                  'medications.frequency',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'once_daily',
                    child: Text('Once daily'),
                  ),
                  DropdownMenuItem(
                    value: 'twice_daily',
                    child: Text('Twice daily'),
                  ),
                  DropdownMenuItem(
                    value: 'thrice_daily',
                    child: Text('Three times daily'),
                  ),
                  DropdownMenuItem(
                    value: 'four_times_daily',
                    child: Text('Four times daily'),
                  ),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(
                    value: 'as_needed',
                    child: Text('As needed'),
                  ),
                ],
                onChanged: (v) =>
                    setState(() => _frequency = v ?? 'once_daily'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SoftDropdown<String>(
          value: _condition,
          label: AppLocalizations.getString(
            context,
            'medications.conditionLabel',
          ),
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
          onChanged: (v) => setState(() => _condition = v ?? 'other'),
        ),
        const SizedBox(height: AppSpacing.md),
        InkWell(
          onTap: _pickStart,
          borderRadius: AppRadius.mdAll,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: AppLocalizations.getString(
                context,
                'medications.startDate',
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              labelStyle: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
              floatingLabelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: BorderSide(color: cs.primary, width: 1.6),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
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
        const SizedBox(height: AppSpacing.md),
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
            const SizedBox(width: AppSpacing.md),
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
        const SizedBox(height: AppSpacing.md),
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
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.md,
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
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
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
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: AppPrimaryButton(
              color: AppColors.primaryColor,
              onPressed: _pickedCandidate == null ? null : _submit,
              isLoading: isSubmitting,
              borderRadius: AppRadius.md,
              label: AppLocalizations.getString(context, 'medications.save'),
            ),
          ),
        ],
      ),
    );
  }
}
