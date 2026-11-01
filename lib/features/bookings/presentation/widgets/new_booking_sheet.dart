import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';

class NewBookingSheet extends StatelessWidget {
  const NewBookingSheet({super.key});

  static Future<ServiceType?> show(BuildContext context) {
    return showModalBottomSheet<ServiceType>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => const NewBookingSheet(),
    );
  }

  static const _options = <(ServiceType, String)>[
    (ServiceType.navigator, 'navigator'),
    (ServiceType.screening, 'screening'),
    (ServiceType.dnaTest, 'dnaTest'),
    (ServiceType.secondOpinion, 'secondOpinion'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, AppSpacing.lg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.getString(context, 'bookings.newBookingTitle'),
              style: tt.titleLarge?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (type, key) in _options) ...[
                      Material(
                        color: cs.surfaceContainerLow,
                        borderRadius: AppRadius.mdAll,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(type),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.mdAll,
                              border: Border.all(
                                color: cs.outlineVariant.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.getString(
                                          context,
                                          'bookings.service.$key',
                                        ),
                                        style: tt.titleSmall?.copyWith(
                                          color: cs.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        AppLocalizations.getString(
                                          context,
                                          'bookings.service.${key}Sub',
                                        ),
                                        style: tt.bodySmall?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: cs.onSurface.withValues(alpha: 0.28),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
