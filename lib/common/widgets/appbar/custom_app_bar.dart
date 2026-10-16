import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_clipper.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_flexible_header.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';

class CustomAppBar extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final bool isHome;
  final bool isTabRoot;
  final double? expandedHeight;
  final PreferredSizeWidget? bottom;
  final String? titleHeroTag;

  static const curveExtra = AppBarClipper.radius;

  // Home content stack (from top of the flexibleSpace area):
  //   brand row (44) + gap (12) + quick-action label (14) + gap (10)
  //   + pill row 1 (54) + gap (8) + pill row 2 (54) + breathing room (12)
  // = 208 base + curveExtra.
  static const _homeBrandRowHeight = 44.0;
  static const _homeBrandToLabelGap = 12.0;
  static const _homeSectionLabelHeight = 14.0;
  static const _homeLabelToGridGap = 10.0;
  static const _homePillHeight = 54.0;
  static const _homePillGap = 8.0;
  static const _homeGridToCurveGap = 12.0;

  static const homeContentHeight =
      _homeBrandRowHeight +
      _homeBrandToLabelGap +
      _homeSectionLabelHeight +
      _homeLabelToGridGap +
      _homePillHeight +
      _homePillGap +
      _homePillHeight +
      _homeGridToCurveGap +
      curveExtra;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.isHome = false,
    this.isTabRoot = false,
    this.expandedHeight,
    this.bottom,
    this.titleHeroTag,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (previous, current) => previous.profile != current.profile,
      builder: (context, state) {
        final resolvedExpanded = isHome
            ? (expandedHeight ?? homeContentHeight)
            : (expandedHeight ?? kToolbarHeight + curveExtra);

        return SliverAppBar(
          expandedHeight: resolvedExpanded,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textOnPrimary,
          iconTheme: const IconThemeData(
            color: AppColors.textOnPrimary,
            size: 24,
          ),
          actionsIconTheme: const IconThemeData(
            color: AppColors.textOnPrimary,
            size: 24,
          ),
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          automaticallyImplyLeading: !isTabRoot,
          title: isHome || title == null
              ? null
              : _AppBarTitle(
                  title: title!,
                  heroTag: titleHeroTag,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.textOnPrimary,
                  ),
                ),
          actions: actions,
          bottom: bottom,
          flexibleSpace: AppBarFlexibleHeader(
            isHome: isHome,
            username: state.profile?.displayName ?? '',
            expandedHeight: resolvedExpanded,
            bottomHeight: bottom?.preferredSize.height ?? 0,
          ),
        );
      },
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({required this.title, required this.style, this.heroTag});

  final String title;
  final TextStyle style;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      title.toUpperCase(),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    final tag = heroTag;
    if (tag == null) return text;
    return Hero(
      tag: tag,
      flightShuttleBuilder: (_, _, _, _, toHero) =>
          (toHero.widget as Hero).child,
      child: Material(color: Colors.transparent, child: text),
    );
  }
}
