import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';

class CompleteReportActions extends StatelessWidget {
  final VoidCallback? onDownloadPdf;
  final VoidCallback? onEmailReport;
  final VoidCallback? onRetake;

  const CompleteReportActions({
    super.key,
    this.onDownloadPdf,
    this.onEmailReport,
    this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onDownloadPdf != null)
          _ActionTile(
            icon: Icons.picture_as_pdf_outlined,
            label: AppLocalizations.getString(
              context,
              'assessment.downloadPdf',
            ),
            onTap: onDownloadPdf!,
          ),
        if (onEmailReport != null) ...[
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.mail_outline_rounded,
            label: AppLocalizations.getString(
              context,
              'assessment.emailReport',
            ),
            onTap: onEmailReport!,
          ),
        ],
        if (onRetake != null) ...[
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.refresh_rounded,
            label: AppLocalizations.getString(context, 'assessment.retake'),
            onTap: onRetake!,
            foreground: cs.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? foreground;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = foreground ?? cs.primary;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: cs.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
