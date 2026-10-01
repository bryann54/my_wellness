import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';

class AssessmentCard extends StatelessWidget {
  final AssessmentSummary summary;
  final VoidCallback onTap;
  final String? statusLabel;
  final bool isRecommended;

  const AssessmentCard({
    super.key,
    required this.summary,
    required this.onTap,
    this.statusLabel,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = CategoryStyle.forCategory(summary.category);

    final borderColor = isRecommended
        ? cs.primary.withValues(alpha: 0.25)
        : cs.outlineVariant.withValues(alpha: 0.6);
    final borderWidth = isRecommended ? 1.4 : 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.onPrimaryContainer.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: assessmentIconTag(summary.slug),
                  flightShuttleBuilder: iconShuttleBuilder,
                  child: CategoryIconTile(style: style, size: 40),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Hero(
                              tag: assessmentTitleTag(summary.slug),
                              flightShuttleBuilder: textShuttleBuilder,
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  summary.shortTitle,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                    color: cs.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          if (statusLabel != null) ...[
                            const SizedBox(width: 8),
                            _StatusPill(
                              label: statusLabel!,
                              color: style.color,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Hero(
                        tag: assessmentTaglineTag(summary.slug),
                        flightShuttleBuilder: textShuttleBuilder,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            summary.tagline,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              height: 1.4,
                              color: cs.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: cs.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: color,
        ),
      ),
    );
  }
}

String assessmentIconTag(String slug) => 'assessment_icon_$slug';
String assessmentTitleTag(String slug) => 'assessment_title_$slug';
String assessmentTaglineTag(String slug) => 'assessment_tagline_$slug';

Widget iconShuttleBuilder(
  BuildContext context,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final hero =
      (direction == HeroFlightDirection.push
              ? toHeroContext.widget
              : fromHeroContext.widget)
          as Hero;
  return hero.child;
}

Widget textShuttleBuilder(
  BuildContext context,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final hero =
      (direction == HeroFlightDirection.push
              ? toHeroContext.widget
              : fromHeroContext.widget)
          as Hero;
  return hero.child;
}

class CategoryIconTile extends StatelessWidget {
  final CategoryStyle style;
  final double size;
  final double? glyphSize;
  final double radius;

  const CategoryIconTile({
    super.key,
    required this.style,
    this.size = 44,
    this.glyphSize,
    this.radius = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.25,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            style.color.withValues(alpha: 0.92),
            style.color.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: FaIcon(
          style.icon,
          color: AppColors.background,
          size: glyphSize ?? size * 0.55,
        ),
      ),
    );
  }
}

class CategoryStyle {
  final FaIconData icon;
  final Color color;
  final String? i18nKey;

  const CategoryStyle({required this.icon, required this.color, this.i18nKey});

  static const cancer = CategoryStyle(
    icon: FontAwesomeIcons.ribbon,
    color: Color(0xFFD63384),
    i18nKey: 'assessment.category.cancer',
  );

  static const metabolic = CategoryStyle(
    icon: FontAwesomeIcons.droplet,
    color: Color(0xFFF97316),
    i18nKey: 'assessment.category.metabolic',
  );

  static const mentalHealth = CategoryStyle(
    icon: FontAwesomeIcons.brain,
    color: Color(0xFF7C3AED),
    i18nKey: 'assessment.category.mentalHealth',
  );

  static const sexualUrinary = CategoryStyle(
    icon: FontAwesomeIcons.personWalking,
    color: Color(0xFF0EA5E9),
    i18nKey: 'assessment.category.sexualUrinary',
  );

  static const fallback = CategoryStyle(
    icon: FontAwesomeIcons.clipboardCheck,
    color: Color(0xFF14B8A6),
  );

  static const _known = <String, CategoryStyle>{
    'cancer': cancer,
    'metabolic': metabolic,
    'mental health': mentalHealth,
    'sexual & urinary': sexualUrinary,
  };

  static CategoryStyle forCategory(String category) {
    return _known[category.trim().toLowerCase()] ?? fallback;
  }

  String localizedLabel(BuildContext context, String rawCategory) {
    if (i18nKey == null) return rawCategory;
    final localized = AppLocalizations.getString(context, i18nKey!);
    return localized == i18nKey ? rawCategory : localized;
  }
}
