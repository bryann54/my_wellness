// lib/common/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_flexible_header.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';

class CustomAppBar extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final bool isHome;
  final double expandedHeight;
  final PreferredSizeWidget? bottom;
  final bool showCart;
  static const curveExtra = 28.0;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.isHome = false,
    this.expandedHeight = 180.0,
    this.showCart = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (p, c) => p.profile != c.profile,
      builder: (context, state) {
        final resolvedExpanded =
            isHome ? expandedHeight + curveExtra : kToolbarHeight + curveExtra;

        return SliverAppBar(
          expandedHeight: resolvedExpanded,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: null,
          bottom: bottom,
          flexibleSpace: AppBarFlexibleHeader(
            isHome: isHome,
            username: state.profile?.displayName ?? '',
            
            title: title,
            actions: [
              if (actions != null) ...actions!,
             
            ],
            expandedHeight: resolvedExpanded,
            bottom: bottom,
          ),
        );
      },
    );
  }
}
