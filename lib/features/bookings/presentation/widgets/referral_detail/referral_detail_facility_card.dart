import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/bookings/domain/entities/facility.dart';
import 'package:my_wellness/features/bookings/domain/entities/referral.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferralDetailFacilityCard extends StatelessWidget {
  final Referral referral;

  const ReferralDetailFacilityCard({super.key, required this.referral});

  Future<void> _navigate(Facility f) async {
    final query = f.latitude != null && f.longitude != null
        ? '${f.latitude},${f.longitude}'
        : Uri.encodeComponent('${f.name} ${f.town}');
    await launchUrl(
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
      mode: LaunchMode.externalApplication,
    );
  }

  String _sha(BuildContext context, String? status) => switch (status) {
    'accredited' => AppLocalizations.getString(
      context,
      'referral.sha.accredited',
    ),
    'not_accredited' => AppLocalizations.getString(
      context,
      'referral.sha.notAccredited',
    ),
    _ => AppLocalizations.getString(context, 'referral.sha.unavailable'),
  };

  @override
  Widget build(BuildContext context) {
    final f = referral.recommendedFacility;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (f == null) {
      return Text(
        AppLocalizations.getString(context, 'referral.noFacility'),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.7),
        ),
      );
    }

    final locality = [
      if (f.address.isNotEmpty) f.address,
      if (f.town.isNotEmpty) f.town,
    ].join(', ');

    final meta = [
      if (referral.distanceKm != null) '${referral.distanceKm} km',
      if (referral.travelTimeMinutes != null)
        '${referral.travelTimeMinutes} min',
      _sha(context, referral.shaAccreditationStatus),
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_hospital_outlined, size: 18, color: cs.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(f.name, style: theme.textTheme.titleMedium)),
            ],
          ),
          if (locality.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              locality,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
          if (meta.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              meta,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => _navigate(f),
            icon: const Icon(Icons.directions_outlined, size: 18),
            label: Text(
              AppLocalizations.getString(context, 'referral.navigate'),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
          ),
        ],
      ),
    );
  }
}
