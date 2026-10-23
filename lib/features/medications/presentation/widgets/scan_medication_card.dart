import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';

class ScanMedicationCard extends StatelessWidget {
  const ScanMedicationCard({
    super.key,
    required this.scanning,
    required this.onCamera,
    required this.onUpload,
  });

  final bool scanning;
  final VoidCallback onCamera;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.document_scanner_outlined,
                size: 20,
                color: cs.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppLocalizations.getString(context, 'medications.scanTitle'),
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            AppLocalizations.getString(context, 'medications.scanSubtitle'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.65),
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (scanning)
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  AppLocalizations.getString(context, 'medications.scanning'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onCamera,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: Text(
                      AppLocalizations.getString(context, 'medications.camera'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onUpload,
                    icon: const Icon(Icons.upload_outlined, size: 18),
                    label: Text(
                      AppLocalizations.getString(context, 'medications.upload'),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
