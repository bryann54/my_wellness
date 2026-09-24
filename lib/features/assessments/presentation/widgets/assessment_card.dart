import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';

class AssessmentCard extends StatelessWidget {
  final AssessmentSummary summary;
  final VoidCallback onTap;

  const AssessmentCard({super.key, required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = CategoryStyle.forCategory(summary.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.onPrimaryContainer.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: assessmentIconTag(summary.slug),
                  flightShuttleBuilder: iconShuttleBuilder,
                  child: CategoryIconTile(style: style, size: 44),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: assessmentTitleTag(summary.slug),
                        flightShuttleBuilder: textShuttleBuilder,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            summary.shortTitle,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // ── Tagline ─────────────────────────────────
                      Hero(
                        tag: assessmentTaglineTag(summary.slug),
                        flightShuttleBuilder: textShuttleBuilder,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            summary.tagline,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.45,
                              color: cs.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          AppLocalizations.getString(
                            context,
                            'assessment.takesFiveToTen',
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tealExtraDark.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurface.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
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
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.25,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [style.color, style.color.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: FaIcon(
          style.icon,
          color: Colors.white,
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
