// lib/features/account/presentation/widgets/profile_details/identity/identity_type_option.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IdentityTypeOption<T> extends StatelessWidget {
  final T value;
  final T group;
  final String label;
  final ValueChanged<T> onChanged;

  const IdentityTypeOption({
    super.key,
    required this.value,
    required this.group,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == group;
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? cs.primary : cs.outlineVariant,
                  width: selected ? 6 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}