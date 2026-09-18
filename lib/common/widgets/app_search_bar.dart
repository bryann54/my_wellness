// lib/common/widgets/app_search_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    required this.hintText,
    this.onChanged,
    this.onFilterTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        // ── Search field ───────────────────────────────────────────────
        Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      Icons.search_rounded,
                      size: 27,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          TextField(
                                controller: controller,
                                onChanged: onChanged,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: cs.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: hintText,
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: cs.onSurface.withValues(alpha: 0.4),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              )
                              .animate(delay: 300.ms)
                              .fadeIn(duration: 400.ms)
                              .slideY(
                                begin: 0.8,
                                end: 0,
                                curve: Curves.easeOut,
                              ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            )
            .animate(delay: 300.ms)
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.8, end: 0, curve: Curves.easeOut),

        if (onFilterTap != null) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onFilterTap,
            child:
                Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Center(
                        child:
                            Icon(
                                  Icons.tune_rounded,
                                  size: 30,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                )
                                .animate(delay: 300.ms)
                                .fadeIn(duration: 400.ms)
                                .slideX(
                                  begin: 0.8,
                                  end: 0,
                                  curve: Curves.easeOut,
                                ),
                      ),
                    )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 1.2, end: 0, curve: Curves.easeOut),
          ),
        ],
      ],
    );
  }
}
