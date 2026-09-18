// lib/features/auth/presentation/widgets/conversation/conversation_state_picker.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/constants/us_states.dart';

class ConversationStatePicker extends StatelessWidget {
  final ValueChanged<UsState> onPicked;

  const ConversationStatePicker({super.key, required this.onPicked});

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<UsState> onPicked,
  }) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => ConversationStatePicker(onPicked: onPicked),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'Select your state',
              style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: UsStates.all.length,
              itemBuilder: (_, i) {
                final state = UsStates.all[i];
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        state.code,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    state.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onPicked(state);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
