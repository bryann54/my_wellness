import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';

class AssessmentCard extends StatelessWidget {
  final AssessmentSummary summary;
  final VoidCallback onTap;
  final bool isRecommended;

  const AssessmentCard({
    super.key,
    required this.summary,
    required this.onTap,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = CategoryStyle.forCategory(summary.category);

    final background = isRecommended
        ? cs.primaryContainer
        : cs.surfaceContainerLow;
    final border = isRecommended
        ? cs.primary.withValues(alpha: 0.22)
        : cs.outlineVariant.withValues(alpha: 0.55);

    return Semantics(
      button: true,
      label: '${summary.shortTitle}. ${summary.tagline}',
      excludeSemantics: true,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(isRecommended ? 20 : 16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isRecommended ? 20 : 16),
              border: Border.all(color: border),
            ),
            padding: EdgeInsets.all(isRecommended ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRecommended) ...[
                  Text(
                    style.localizedLabel(context, summary.category),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Hero(
                  tag: assessmentTitleTag(summary.slug),
                  flightShuttleBuilder: textShuttleBuilder,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      summary.shortTitle,
                      style: GoogleFonts.inter(
                        fontSize: isRecommended ? 20 : 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Hero(
                  tag: assessmentTaglineTag(summary.slug),
                  flightShuttleBuilder: textShuttleBuilder,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      summary.tagline,
                      style: GoogleFonts.inter(
                        fontSize: isRecommended ? 14 : 13.5,
                        height: 1.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                if (isRecommended) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: cs.primary,
                    ),
                  ),
                ],
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
