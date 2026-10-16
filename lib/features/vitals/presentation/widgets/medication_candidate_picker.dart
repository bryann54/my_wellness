import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication_scan.dart';

class MedicationCandidatePicker extends StatelessWidget {
  const MedicationCandidatePicker({
    super.key,
    required this.entry,
    required this.selected,
    required this.onSelected,
  });

  final MedicationCandidate entry;
  final MedicationCandidateOption? selected;
  final ValueChanged<MedicationCandidateOption> onSelected;

  static const _warning = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final candidates = entry.candidates;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: _warning.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                size: 18,
                color: _warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppLocalizations.getString(
                    context,
                    'medications.confirmTitle',
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppLocalizations.getString(context, 'medications.confirmSubtitle'),
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.45,
              color: cs.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                '${entry.rawName ?? "—"} • ${entry.dosage ?? "—"}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            DropDownWidget<MedicationCandidateOption>(
              label: AppLocalizations.getString(
                context,
                'medications.pickMatch',
              ),
              selectedItem: selected,
              isRequired: true,
              filled: true,
              filledColor: cs.surfaceContainerHighest,
              borderRadius: AppRadius.md,
              contentPadding: AppSpacing.md,
              padding: EdgeInsets.zero,
              items: [
                for (final c in candidates)
                  DropdownMenuItem<MedicationCandidateOption>(
                    value: c,
                    child: Text(
                      c.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (opt) {
                if (opt != null) onSelected(opt);
              },
            ),
        ],
      ),
    );
  }
}