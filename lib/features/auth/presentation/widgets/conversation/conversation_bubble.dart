// lib/features/auth/presentation/widgets/conversation/conversation_bubble.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/features/auth/presentation/widgets/conversation/conversation_models.dart';

class ConversationBubble extends StatelessWidget {
  final ConversationMessage message;
  final int index;

  const ConversationBubble({
    super.key,
    required this.message,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAi = message.isAi;

    return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: isAi
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isAi) ...[
                CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.secondary.withValues(alpha: 0.04),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.shield_rounded, size: 22, color: cs.primary),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isAi ? cs.surfaceContainerLow : cs.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isAi ? 4 : 16),
                      bottomRight: Radius.circular(isAi ? 16 : 4),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isAi ? cs.onSurface : Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, curve: Curves.easeOut);
  }
}
