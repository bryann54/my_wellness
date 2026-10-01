import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication_scan.dart';

class MedicationCandidatePicker extends StatelessWidget {
  final MedicationCandidate entry;
  final MedicationCandidateOption? selected;
  final ValueChanged<MedicationCandidateOption> onSelected;

  const MedicationCandidatePicker({
    super.key,
    required this.entry,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final candidates = entry.candidates;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                size: 18,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.getString(
                    context,
                    'medications.confirmTitle',
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.getString(context, 'medications.confirmSubtitle'),
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.45,
              color: cs.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 14),

          if (candidates.isEmpty)
            // No candidates — the raw OCR text is all we have.
            Text(
              '${entry.rawName ?? "—"} • ${entry.dosage ?? "—"}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            )
          else
            // Candidates — use a dropdown so the user picks with one tap.
            DropdownButtonFormField<MedicationCandidateOption>(
              initialValue: selected,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.getString(
                  context,
                  'medications.pickMatch',
                ),
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final c in candidates)
                  DropdownMenuItem(
                    value: c,
                    child: Text(
                      c.dosage == null ? c.name : '${c.name} · ${c.dosage}',
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
