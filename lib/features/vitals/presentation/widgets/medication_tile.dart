import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/custom_alert_dialog.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication.dart';

class MedicationTile extends StatefulWidget {
  const MedicationTile({
    super.key,
    required this.medication,
    required this.onDelete,
  });

  final Medication medication;
  final VoidCallback onDelete;

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
                  duration: AppDurations.medium,
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
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
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
  const _Header({required this.medication, required this.expanded});

  final Medication medication;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final subtitle = _subtitle(medication);
    final condition = medication.condition?.trim();
    final showCondition =
        condition != null &&
        condition.isNotEmpty &&
        condition.toLowerCase() != 'other';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: cs.secondary.withValues(alpha: 0.04),
          child: Image.asset(
            'assets/images/meds.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                Icon(Icons.shield_rounded, size: 22, color: cs.primary),
          ),
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
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: 0.6),
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
        const SizedBox(width: AppSpacing.sm),
        AnimatedRotation(
          turns: expanded ? 0.5 : 0,
          duration: AppDurations.medium,
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
  const _Details({required this.medication});

  final Medication medication;

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
          const SizedBox(height: AppSpacing.xs),
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
  const _LabeledRow({required this.label, this.value, this.multiline = false});

  final String label;
  final String? value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: cs.onSurface.withValues(alpha: 0.55),
    );

    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: multiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: AppSpacing.xs),
                Text(value ?? '', style: valueStyle),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(width: AppSpacing.md),
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
  const _ConditionBadge({required this.condition});

  final String condition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final label = switch (condition.toLowerCase()) {
      'hypertension' => AppLocalizations.getString(
        context,
        'condition.hypertension',
      ),
      'diabetes' => AppLocalizations.getString(context, 'condition.diabetes'),
      _ => condition,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 1,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.smAll,
        border: Border.all(color: cs.primary.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: cs.primary,
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onTap});

  final VoidCallback onTap;

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
  const _DismissBackground({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.lgAll),
      child: Icon(
        Icons.delete_outline_rounded,
        color: Theme.of(context).colorScheme.onError,
      ),
    );
  }
}
