import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/custom_alert_dialog.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication.dart';

class MedicationTile extends StatefulWidget {
  final Medication medication;
  final VoidCallback onDelete;

  const MedicationTile({
    super.key,
    required this.medication,
    required this.onDelete,
  });

  @override
  State<MedicationTile> createState() => _MedicationTileState();
}

class _MedicationTileState extends State<MedicationTile> {
  bool _isExpanded = false;

  Medication get m => widget.medication;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(m.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => AppDialogs.ask(
        context,
        title: AppLocalizations.getString(
          context,
          'medications.deleteConfirmTitle',
        ),
        message: AppLocalizations.getString(
          context,
          'medications.deleteConfirmMessage',
        ),
        isDestructive: true,
      ),
      background: _DismissBackground(color: cs.error),
      onDismissed: (_) => widget.onDelete(),
      child: _Card(
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(medication: m, expanded: _isExpanded),
                AnimatedSize(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.md),
                            Divider(
                              height: 1,
                              color: cs.outlineVariant.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _Details(medication: m),
                            const SizedBox(height: AppSpacing.xs),
                            Divider(
                              height: 1,
                              color: cs.outlineVariant.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _DeleteButton(onTap: () => _confirmDelete(context)),
                          ],
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await AppDialogs.ask(
      context,
      title: AppLocalizations.getString(
        context,
        'medications.deleteConfirmTitle',
      ),
      message: AppLocalizations.getString(
        context,
        'medications.deleteConfirmMessage',
      ),
      isDestructive: true,
    );
    if (ok == true && mounted) widget.onDelete();
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Medication medication;
  final bool expanded;

  const _Header({required this.medication, required this.expanded});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final subtitle = _subtitle(medication);
    final condition = medication.condition?.trim();
    final showCondition =
        condition != null &&
        condition.isNotEmpty &&
        condition.toLowerCase() != 'other';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.medication_outlined, size: 21, color: cs.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                medication.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  height: 1.25,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: 0.6),
                    height: 1.2,
                  ),
                ),
              ],
              if (showCondition) ...[
                const SizedBox(height: AppSpacing.sm),
                _ConditionBadge(condition: condition),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        AnimatedRotation(
          turns: expanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22,
            color: cs.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  static String _humanize(String raw) {
    final s = raw.trim().replaceAll('_', ' ');
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  static String? _subtitle(Medication m) {
    final dosage = m.dosage.trim();
    final frequency = _humanize(m.frequency);

    if (dosage.isEmpty && frequency.isEmpty) return null;
    if (frequency.isEmpty) return dosage;
    if (dosage.isEmpty) return frequency;
    return '$dosage · $frequency';
  }
}

class _Details extends StatelessWidget {
  final Medication medication;
  const _Details({required this.medication});

  @override
  Widget build(BuildContext context) {
    final m = medication;

    final notes = m.notes?.trim();
    final hasNotes = notes != null && notes.isNotEmpty;
    final hasStart = m.startDate != null;
    final hasDuration =
        m.durationValue != null && m.durationUnit?.trim().isNotEmpty == true;
    final hasEnd = m.endDate != null;
    final condition = m.condition?.trim();
    final hasCondition = condition != null && condition.isNotEmpty;
    final prescription = m.prescription?.trim();
    final hasPrescription = prescription != null && prescription.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasCondition)
          _LabeledRow(
            label: _t(context, 'medications.condition'),
            value: _conditionLabel(context, condition),
          ),
        if (hasStart)
          _LabeledRow(
            label: _t(context, 'medications.started'),
            value: _formatDate(m.startDate),
          ),
        if (hasDuration)
          _LabeledRow(
            label: _t(context, 'medications.duration'),
            value: _durationLabel(m, context),
          ),
        if (hasEnd)
          _LabeledRow(
            label: _t(context, 'medications.ends'),
            value: _formatDate(m.endDate) ?? '—',
          ),
        if (m.source.isNotEmpty)
          _LabeledRow(
            label: _t(context, 'medications.addedVia'),
            value: _sourceLabel(m.source, context),
          ),
        if (hasPrescription)
          _LabeledRow(
            label: _t(context, 'medications.prescription'),
            value: _t(context, 'common.available'),
          ),
        if (hasNotes) ...[
          const SizedBox(height: 4),
          _LabeledRow(
            label: _t(context, 'medications.notes'),
            value: notes,
            multiline: true,
          ),
        ],
      ],
    );
  }

  static String _durationLabel(Medication m, BuildContext context) {
    final value = m.durationValue;
    final unit = m.durationUnit?.trim() ?? '';
    if (value == null || unit.isEmpty) return '';
    final label = switch (unit) {
      'day' || 'days' =>
        value == 1
            ? _t(context, 'medications.unitDay')
            : _t(context, 'medications.unitDays'),
      'week' || 'weeks' =>
        value == 1
            ? _t(context, 'medications.unitWeek')
            : _t(context, 'medications.unitWeeks'),
      'month' || 'months' =>
        value == 1
            ? _t(context, 'medications.unitMonth')
            : _t(context, 'medications.unitMonths'),
      _ => unit,
    };
    return '$value $label';
  }

  static String _sourceLabel(String source, BuildContext context) {
    final s = source.toLowerCase();
    return switch (s) {
      'scan' || 'photo' => _t(context, 'medications.sourceScanned'),
      'prescription' => _t(context, 'medications.sourcePrescription'),
      _ => _t(context, 'medications.sourceManual'),
    };
  }

  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    final d = date.day.toString().padLeft(2, '0');
    final mo = date.month.toString().padLeft(2, '0');
    return '$d/$mo/${date.year}';
  }

  static String _t(BuildContext context, String key) =>
      AppLocalizations.getString(context, key);

  static String _conditionLabel(BuildContext context, String? condition) {
    final value = condition?.trim() ?? '';
    return switch (value.toLowerCase()) {
      'hypertension' => _t(context, 'condition.hypertension'),
      'diabetes' => _t(context, 'condition.diabetes'),
      'other' => _t(context, 'condition.other'),
      _ => value.replaceAll('_', ' '),
    };
  }
}

class _LabeledRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool multiline;

  const _LabeledRow({required this.label, this.value, this.multiline = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final labelStyle = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: cs.onSurface.withValues(alpha: 0.55),
      height: 1.3,
    );

    final valueStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
      height: 1.4,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: multiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: 4),
                Text(value ?? '', style: valueStyle),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      value ?? '',
                      style: valueStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ConditionBadge extends StatelessWidget {
  final String condition;
  const _ConditionBadge({required this.condition});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final label = switch (condition.toLowerCase()) {
      'hypertension' => AppLocalizations.getString(
        context,
        'condition.hypertension',
      ),
      'diabetes' => AppLocalizations.getString(context, 'condition.diabetes'),
      _ => condition,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.primary.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: cs.primary,
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: cs.error,
          minimumSize: const Size(48, 44),
        ),
        icon: const Icon(Icons.delete_outline_rounded, size: 18),
        label: Text(AppLocalizations.getString(context, 'common.delete')),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  final Color color;
  const _DismissBackground({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.lgAll),
      child: Icon(
        Icons.delete_outline_rounded,
        color: Theme.of(context).colorScheme.onError,
      ),
    );
  }
}
