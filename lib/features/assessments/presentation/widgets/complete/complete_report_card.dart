import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:google_fonts/google_fonts.dart';

class CompleteReportCard extends StatelessWidget {
  final bool downloading;
  final bool emailing;
  final VoidCallback onDownload;
  final VoidCallback onEmail;
  final VoidCallback onShare;

  const CompleteReportCard({
    super.key,
    required this.downloading,
    required this.emailing,
    required this.onDownload,
    required this.onEmail,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final note = GoogleFonts.inter(
      fontSize: 11.5,
      height: 1.4,
      color: cs.onSurfaceVariant,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keep Your Report',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Save, email or share your assessment report.',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.45,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ReportAction(
                  icon: Icons.file_download_outlined,
                  label: downloading ? 'Preparing…' : 'Download my report',
                  busy: downloading,
                  onTap: onDownload,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReportAction(
                  icon: Icons.mail_outline_rounded,
                  label: emailing ? 'Sending…' : 'Email the report',
                  busy: emailing,
                  onTap: onEmail,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReportAction(
                  icon: Icons.share_outlined,
                  label: AppLocalizations.getString(
                    context,
                    'assessment.shareWithDoctor',
                  ),
                  onTap: onShare,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'For your privacy, this PDF is password-protected — the password hint appears after downloading.',
                  style: note,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You can also share the report with your healthcare provider to support further discussion, clinical review and appropriate care.',
            style: note,
          ),
        ],
      ),
    );
  }
}

class _ReportAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool busy;
  final VoidCallback onTap;

  const _ReportAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (busy)
              const ShimmerBox(width: 24, height: 8, radius: 4)
            else
              Icon(icon, size: 18, color: cs.primary),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
