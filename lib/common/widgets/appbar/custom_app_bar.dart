import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_clipper.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_flexible_header.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/home/presentation/widgets/quick_action_row.dart';

class CustomAppBar extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final bool isHome;
  final bool isTabRoot;

  /// Expanded sliver extent, excluding the system top inset and bottom widget.
  final double? expandedHeight;
  final PreferredSizeWidget? bottom;

  static const curveExtra = AppBarClipper.radius;
  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.isHome = false,
    this.isTabRoot = false,
    this.expandedHeight,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (p, c) => p.profile != c.profile,
      builder: (context, state) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final homeContentHeight =
            8.0 +
            (44.0 > 20.0 * textScale ? 44.0 : 20.0 * textScale) +
            16.0 +
            QuickActionRow.preferredHeight(context) +
            curveExtra +
            8.0;
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
              : Text(
                  title!.toUpperCase(),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
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
