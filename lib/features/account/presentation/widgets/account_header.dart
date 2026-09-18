import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';

class AccountHeader extends StatelessWidget {
  final HealthProfile profile;
  final VoidCallback onLogout;

  const AccountHeader({
    super.key,
    required this.profile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 150,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            color: Colors.red,
          ),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final collapsedHeight =
              kToolbarHeight + MediaQuery.of(context).padding.top;
          const expandedHeight = 150.0;
          final progress =
              ((constraints.biggest.height - expandedHeight) /
                      (collapsedHeight - expandedHeight))
                  .clamp(0.0, 1.0);
          return FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            title: Opacity(
              opacity: progress,
              child: _buildCollapsedTitle(context),
            ),
            background: _buildExpandedHeader(context),
          );
        },
      ),
    );
  }

  Widget _buildCollapsedTitle(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
          child: Text(
            _getInitials(profile),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profile.displayName,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                profile.email,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: cs.onPrimaryFixed.withValues(alpha: 0.2),
            child: Text(
              _getInitials(profile),
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: cs.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  profile.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 String _getInitials(HealthProfile profile) {
    final name = profile.displayName;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }
}
