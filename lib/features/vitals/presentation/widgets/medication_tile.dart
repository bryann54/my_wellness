import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(medication: m, expanded: _isExpanded),
                AnimatedSize(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  child: _isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 14),
                            Divider(),
                            const SizedBox(height: 12),
                            _Details(medication: m),
                            const SizedBox(height: 12),
                            Divider(),
                            const SizedBox(height: 8),
                            _DeleteButton(onTap: () => _confirmDelete(context)),
                          ],
                        )
                      : const SizedBox.shrink(),
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
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.6),
              width: 1,
            ),
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

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                medication.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  height: 1.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: cs.onSurface.withValues(alpha: 0.6),
                    height: 1.2,
                  ),
                ),
              ],
              if (medication.notes != null) ...[
                const SizedBox(height: 3),
                Text(
                  medication.notes.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: cs.onSurface.withValues(alpha: 0.6),
                    height: 1.2,
                  ),
                ),
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
            size: 20,
            color: cs.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  static String? _subtitle(Medication m) {
    final dosage = m.dosage.trim();
    final frequency = m.frequency.trim();

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
    final hasCondition = m.condition != null && m.condition!.trim().isNotEmpty;
    final hasNotes = notes != null && notes.isNotEmpty;
    final hasEnd = m.endDate != null;
    final hasPrescription =
        m.prescription != null && m.prescription!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (m.dosage.trim().isNotEmpty)
          _LabeledRow(
            label: _t(context, 'medications.dosage'),
            value: m.dosage.trim(),
          ),
        if (m.frequency.trim().isNotEmpty)
          _LabeledRow(
            label: _t(context, 'medications.frequency'),
            value: m.frequency.trim(),
          ),
        if (hasCondition)
          _LabeledRow(
            label: _t(context, 'medications.condition'),
            trailing: _ConditionBadge(condition: m.condition!),
          ),
        _LabeledRow(
          label: _t(context, 'medications.started'),
          value: _formatDate(m.startDate) ?? _t(context, 'medications.notSet'),
        ),
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
    if (value == null || unit.isEmpty) {
      return _t(context, 'medications.ongoing');
    }
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
}

class _LabeledRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? trailing;
  final bool multiline;

  const _LabeledRow({
    required this.label,
    this.value,
    this.trailing,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final labelStyle = GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: cs.onSurface.withValues(alpha: 0.55),
      height: 1.3,
    );

    final valueStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
      height: 1.35,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
                    child:
                        trailing ??
                        Text(
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

    final (label, color) = switch (condition.toLowerCase()) {
      'hypertension' => ('Hypertension', const Color(0xFF2563EB)),
      'diabetes' => ('Diabetes', const Color(0xFFDC2626)),
      _ => (condition, cs.primary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: color,
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
    return Align(
      alignment: Alignment.centerRight,
      child: AppPrimaryButton(
        onPressed: onTap,
        borderRadius: 6,
        height: 40,
        width: 150,
        label: AppLocalizations.getString(context, 'common.delete'),
        icon: Icons.delete_outline_rounded,
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
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
    );
  }
}
