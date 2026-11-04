import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/debouncer.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication_scan.dart';
import 'package:my_wellness/features/vitals/domain/usecases/vitals_usecases.dart';
import 'package:my_wellness/features/medications/presentation/bloc/medications_bloc.dart';
import 'package:my_wellness/features/medications/presentation/widgets/medication_candidate_picker.dart';
import 'package:my_wellness/features/medications/presentation/widgets/scan_medication_card.dart';
import 'package:my_wellness/features/medications/presentation/widgets/medications_toast_listener.dart';

@RoutePage()
class AddMedicationScreen extends StatelessWidget {
  final String? condition;

  const AddMedicationScreen({super.key, this.condition});

  @override
  Widget build(BuildContext context) {
    return MedicationsToastListener(
      child: BlocProvider.value(
        value: context.read<MedicationsBloc>(),
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
  final _searchCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _quantityPerDoseCtrl = TextEditingController();
  final _quantityDispensedCtrl = TextEditingController();

  final _debouncer = Debouncer(milliseconds: 350);

  late String _condition;
  String _frequency = 'once_daily';
  String _durationUnit = 'days';
  String _dosageForm = 'tablet';
  DateTime _startDate = DateTime.now();

  bool _scanning = false;
  MedicationScanResult? _scanResult;
  MedicationCandidateOption? _pickedCandidate;

  // Formulary registry search
  bool _searching = false;
  bool _searchDone = false;
  List<Map<String, dynamic>> _searchResults = const [];

  final List<TimeOfDay> _reminderTimes = [];

  @override
  void initState() {
    super.initState();
    _condition = widget.condition ?? 'other';
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _notesCtrl.dispose();
    _durationCtrl.dispose();
    _quantityPerDoseCtrl.dispose();
    _quantityDispensedCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = const [];
        _searchDone = false;
      });
      return;
    }
    _debouncer.run(() => _searchRegistry(query));
  }

  Future<void> _searchRegistry(String query) async {
    if (!mounted) return;
    setState(() {
      _searching = true;
      _searchDone = true;
    });
    final useCase = getIt<SearchFormularyUseCase>();
    final result = await useCase((cursor: null, query: query));
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _searching = false;
        _searchResults = const [];
      }),
      (page) => setState(() {
        _searching = false;
        _searchResults = page.items;
      }),
    );
  }

  void _pickRegistryItem(Map<String, dynamic> item) {
    final id = item['id'] as String?;
    final name = (item['display'] ?? item['name'] ?? '') as String;
    if (id == null || id.isEmpty) return;
    setState(() {
      _pickedCandidate = MedicationCandidateOption(id: id, name: name);
      _nameCtrl.text = name;
      _searchCtrl.clear();
      _searchResults = const [];
      _searchDone = false;
    });
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

    final result = await context.read<MedicationsBloc>().scanMedication(
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
      locale: Localizations.localeOf(context),
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _addReminder() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (t != null) {
      setState(() => _reminderTimes.add(t));
    }
  }

  void _removeReminder(int i) {
    setState(() => _reminderTimes.removeAt(i));
  }

  String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    if (_pickedCandidate == null) {
      AppSnackbar.warning(
        context,
        'Pick the medication from the registry search or scan.',
      );
      return;
    }

    final payload = <String, dynamic>{
      'condition': _condition,
      'generic_product_id': _pickedCandidate!.id,
      'dosage': _doseCtrl.text.trim(),
      'frequency': _frequency,
      'dosage_form': _dosageForm,
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      'start_date': isoDate(_startDate),
      if (_durationCtrl.text.trim().isNotEmpty) ...{
        'duration_value': int.parse(_durationCtrl.text.trim()),
        'duration_unit': _durationUnit,
      },
      if (_reminderTimes.isNotEmpty)
        'reminder_times': _reminderTimes.map(_hhmm).toList(),
      if (_quantityPerDoseCtrl.text.trim().isNotEmpty)
        'quantity_per_dose': int.parse(_quantityPerDoseCtrl.text.trim()),
      if (_quantityDispensedCtrl.text.trim().isNotEmpty)
        'quantity_dispensed': int.parse(_quantityDispensedCtrl.text.trim()),
    };

    context.read<MedicationsBloc>().add(AddMedicationEvent(payload));
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSubmitting = context.select<MedicationsBloc, bool>(
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
                    _buildRegistrySearch(cs),
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

  Widget _buildRegistrySearch(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoftInput(
          controller: _searchCtrl,
          label: 'Search medication registry',
          hint: 'e.g. metformin',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
        ),
        if (_searching)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              ),
            ),
          )
        else if (_searchDone && _searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _searchResults.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                indent: 12,
                endIndent: 12,
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
              itemBuilder: (context, i) {
                final item = _searchResults[i];
                final name =
                    (item['display'] ?? item['name'] ?? 'Unnamed') as String;
                final code = item['code'] as String?;
                return InkWell(
                  onTap: () => _pickRegistryItem(item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (code != null && code.isNotEmpty)
                          Text(
                            code,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: cs.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else if (_searchDone && _searchResults.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'No matches in the registry.',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        if (_pickedCandidate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _pickedCandidate!.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _pickedCandidate = null),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
      ],
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
          value: _dosageForm,
          label: 'Dosage form',
          items: const [
            DropdownMenuItem(value: 'tablet', child: Text('Tablet')),
            DropdownMenuItem(value: 'capsule', child: Text('Capsule')),
            DropdownMenuItem(value: 'syrup', child: Text('Syrup')),
            DropdownMenuItem(value: 'injection', child: Text('Injection')),
            DropdownMenuItem(value: 'inhaler', child: Text('Inhaler')),
            DropdownMenuItem(value: 'cream', child: Text('Cream')),
            DropdownMenuItem(value: 'drops', child: Text('Drops')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (v) => setState(() => _dosageForm = v ?? 'tablet'),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SoftInput(
                controller: _quantityPerDoseCtrl,
                label: 'Quantity per dose',
                hint: '1',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: SoftInput(
                controller: _quantityDispensedCtrl,
                label: 'Quantity dispensed',
                hint: '30',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildReminders(cs),
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

  Widget _buildReminders(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.alarm_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reminder times',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _reminderTimes.length >= 12 ? null : _addReminder,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          if (_reminderTimes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'No reminders. Tap Add to set one.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _reminderTimes.length; i++)
                    Chip(
                      label: Text(_hhmm(_reminderTimes[i])),
                      onDeleted: () => _removeReminder(i),
                      deleteIcon: const Icon(Icons.close_rounded, size: 14),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ),
        ],
      ),
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
