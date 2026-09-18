// lib/features/auth/presentation/widgets/conversation/conversation_input_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/auth/presentation/widgets/conversation/conversation_models.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_button.dart';

class ConversationInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FieldType fieldType;
  final bool isPasswordVisible;
  final VoidCallback onVisibilityToggle;
  final VoidCallback? onSend;
  final String? errorText;
  final bool isLoading;
  final bool isDone;
  final VoidCallback? onSubmit;

  const ConversationInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.fieldType,
    required this.isPasswordVisible,
    required this.onVisibilityToggle,
    required this.onSend,
    required this.errorText,
    required this.isLoading,
    required this.isDone,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4),
              child: Text(
                errorText!,
                style: GoogleFonts.inter(fontSize: 12, color: cs.error),
              ),
            ),
          if (isDone)
            AuthButton(
              color: Colors.orange,
              heroTag: 'register_button',
              isEnabled: true,
              onPressed: onSubmit ?? () {},
              isLoading: isLoading,
              text: AppLocalizations.getString(context, 'auth.createAccount'),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    obscureText:
                        fieldType == FieldType.password && !isPasswordVisible,
                    keyboardType: _keyboardType,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend?.call(),
                    style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.getString(
                        context,
                        'auth.inputHint',
                      ),
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: cs.onSurface.withValues(alpha: 0.4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: fieldType == FieldType.password
                          ? IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: cs.onSurface.withValues(alpha: 0.4),
                              ),
                              onPressed: onVisibilityToggle,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onSend,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: onSend != null
                          ? Colors.orange
                          : cs.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: onSend != null
                                ? Colors.white
                                : cs.onSurface.withValues(alpha: 0.3),
                          ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  TextInputType get _keyboardType => switch (fieldType) {
    FieldType.email => TextInputType.emailAddress,
    FieldType.phone => TextInputType.phone,
    FieldType.password => TextInputType.visiblePassword,
    FieldType.text => TextInputType.text,
    // gender/date steps are handled by the parent screen and should
    // never reach this widget, but fall back to text just in case.
    FieldType.gender => TextInputType.text,
    FieldType.date => TextInputType.text,
  };
}
