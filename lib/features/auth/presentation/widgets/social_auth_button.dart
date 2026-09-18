// lib/features/auth/presentation/widgets/social_auth_button.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';

enum SocialAuthProvider { google, apple }

class SocialAuthButton extends StatelessWidget {
  final SocialAuthProvider provider;
  final bool isLoading;
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.provider,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isGoogle = provider == SocialAuthProvider.google;

    final bg = isGoogle ? const Color(0xFFE8F5E9) : const Color(0xFFF2F2F2);
    final textColor = isGoogle ? const Color(0xFF34A853) : Colors.black87;
    final label = isGoogle
        ? AppLocalizations.getString(context, 'auth.signInWithGoogle')
        : AppLocalizations.getString(context, 'auth.signInWithApple');

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                // Icon bubble
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                textColor,
                              ),
                            ),
                          )
                        : _ProviderIcon(provider: provider),
                  ),
                ),

                // Label — centered in remaining space
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),

                // Balance the icon width so text is truly centered
                const SizedBox(width: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderIcon extends StatelessWidget {
  final SocialAuthProvider provider;
  const _ProviderIcon({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider == SocialAuthProvider.google) {
      return Image.asset(
        'assets/images/google.png',
        width: 22,
        height: 22,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.g_mobiledata, size: 18, color: Color(0xFF4285F4)),
      );
    }
    return const Icon(Icons.apple, size: 30, color: Colors.black87);
  }
}
