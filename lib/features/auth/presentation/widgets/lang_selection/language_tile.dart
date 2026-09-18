// ── Language tile ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/features/auth/presentation/widgets/lang_selection/lang_model.dart';

class LanguageTile extends StatelessWidget {
  final Language language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageTile({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected
            ? cs.primary.withValues(alpha: 0.06)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.4)
              : cs.outlineVariant.withValues(alpha: 0.3),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    language.flagAsset,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40,
                      height: 28,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    language.label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? cs.primary : cs.outlineVariant,
                      width: isSelected ? 5 : 1.5,
                    ),
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
