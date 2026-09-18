// lib/common/widgets/input_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_wellness/common/res/l10n.dart';

class InputBar extends StatelessWidget {
  const InputBar({
    super.key,
    required this.controller,
    required this.hasText,
    required this.enabled,
    required this.onSend,
    this.hintText,
  });

  final TextEditingController controller;
  final bool hasText;
  final bool enabled;
  final VoidCallback onSend;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canSend = hasText && enabled;

    final resolvedHint = hintText ??
        (enabled
            ? AppLocalizations.getString(context, 'chatbot.placeholder')
            : AppLocalizations.getString(context, 'attorneys.connecting'));

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: 5,
                    minLines: 1,
                    enabled: enabled,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: resolvedHint,
                      hintStyle: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedScale(
                scale: canSend ? 1.0 : 0.85,
                duration: 200.ms,
                curve: Curves.easeOutBack,
                child: AnimatedContainer(
                  duration: 200.ms,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: canSend ? cs.primary : cs.surfaceContainerHighest,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: canSend
                          ? cs.onPrimary
                          : cs.onSurface.withValues(alpha: 0.3),
                    ),
                    onPressed: canSend ? onSend : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
