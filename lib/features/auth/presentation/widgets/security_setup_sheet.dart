import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/core/services/biometric_service.dart';
import 'package:my_wellness/core/services/pin_service.dart';

enum _SetupStep { biometrics, createPin, confirmPin }

class SecuritySetupSheet extends StatefulWidget {
  const SecuritySetupSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const SecuritySetupSheet(),
    );
  }

  @override
  State<SecuritySetupSheet> createState() => _SecuritySetupSheetState();
}

class _SecuritySetupSheetState extends State<SecuritySetupSheet> {
  _SetupStep _step = _SetupStep.biometrics;
  String _pin = '';
  bool _biometricsAvailable = false;
  bool _biometricsEnrolled = false;
  bool _enrollingBiometrics = false;
  String? _error;

  // PIN controllers
  final _createController = TextEditingController();
  final _confirmController = TextEditingController();
  final _createFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  void dispose() {
    _createController.dispose();
    _confirmController.dispose();
    _createFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    final available = await BiometricService().isBiometricAvailable();
    if (mounted) {
      setState(() => _biometricsAvailable = available);
    }
  }

  Future<void> _enrollBiometrics() async {
    setState(() {
      _enrollingBiometrics = true;
      _error = null;
    });
    final success = await BiometricService().authenticate(
      reason: 'Register your biometrics for quick and secure access',
    );
    if (mounted) {
      setState(() => _enrollingBiometrics = false);
      if (success) {
        await BiometricService().setEnabled(true);
        setState(() => _biometricsEnrolled = true);
      } else {
        setState(
          () => _error =
              'Biometric registration failed. You can skip and use PIN only.',
        );
      }
    }
  }

  void _skipBiometrics() {
    HapticFeedback.lightImpact();
    setState(() {
      _step = _SetupStep.createPin;
      _error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _createFocus.requestFocus(),
    );
  }

  void _proceedFromBiometrics() {
    HapticFeedback.lightImpact();
    setState(() {
      _step = _SetupStep.createPin;
      _error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _createFocus.requestFocus(),
    );
  }

  void _submitCreatePin() {
    if (_createController.text.length < 4) {
      setState(() => _error = 'PIN must be at least 4 digits');
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _pin = _createController.text;
      _step = _SetupStep.confirmPin;
      _error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _confirmFocus.requestFocus(),
    );
  }

  Future<void> _submitConfirmPin() async {
    if (_confirmController.text != _pin) {
      HapticFeedback.mediumImpact();
      setState(() => _error = 'PINs don\'t match. Please try again.');
      _confirmController.clear();
      return;
    }
    HapticFeedback.heavyImpact();
    await PinService().setPin(_pin);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Step indicator
          _StepIndicator(
            current: _step == _SetupStep.biometrics
                ? 0
                : _step == _SetupStep.createPin
                ? 1
                : 2,
            total: _biometricsAvailable ? 3 : 2,
          ),
          const SizedBox(height: 28),

          // Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: switch (_step) {
              _SetupStep.biometrics => _BiometricsStep(
                key: const ValueKey('biometrics'),
                available: _biometricsAvailable,
                enrolled: _biometricsEnrolled,
                enrolling: _enrollingBiometrics,
                error: _error,
                onEnroll: _enrollBiometrics,
                onSkip: _skipBiometrics,
                onContinue: _proceedFromBiometrics,
              ),
              _SetupStep.createPin => _PinStep(
                key: const ValueKey('create'),
                title: 'Create Your PIN',
                subtitle:
                    'Choose a PIN you\'ll remember.\nThis is your backup when biometrics fail.',
                controller: _createController,
                focusNode: _createFocus,
                error: _error,
                onSubmit: _submitCreatePin,
              ),
              _SetupStep.confirmPin => _PinStep(
                key: const ValueKey('confirm'),
                title: 'Confirm Your PIN',
                subtitle:
                    'Enter your PIN one more time\nto make sure it\'s correct.',
                controller: _confirmController,
                focusNode: _confirmFocus,
                error: _error,
                onSubmit: _submitConfirmPin,
              ),
            },
          ),
        ],
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        final done = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: done || active
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Biometrics step ───────────────────────────────────────────────────────────

class _BiometricsStep extends StatelessWidget {
  final bool available;
  final bool enrolled;
  final bool enrolling;
  final String? error;
  final VoidCallback onEnroll;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  const _BiometricsStep({
    super.key,
    required this.available,
    required this.enrolled,
    required this.enrolling,
    this.error,
    required this.onEnroll,
    required this.onSkip,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: enrolled ? cs.primaryContainer : cs.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: enrolling
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                  )
                : FaIcon(
                    enrolled
                        ? FontAwesomeIcons.solidCircleCheck
                        : FontAwesomeIcons.fingerprint,
                    size: 30,
                    color: enrolled
                        ? cs.onPrimaryContainer
                        : cs.onSurface.withValues(alpha: 0.5),
                  ),
          ),
        ).animate().scale(duration: 350.ms, curve: Curves.elasticOut),
        const SizedBox(height: 20),
        Text(
          enrolled ? 'Biometrics Registered!' : 'Set Up Biometrics',
          style: GoogleFonts.syne(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          enrolled
              ? 'You\'re all set. Tap continue to set up your PIN backup.'
              : available
              ? 'Register your fingerprint or Face ID for quick access.\nYou can skip this and use PIN only.'
              : 'Biometrics are not available on this device.\nYou\'ll use a PIN to unlock the app.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: cs.onSurface.withValues(alpha: 0.55),
            height: 1.5,
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onErrorContainer,
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        if (enrolled || !available)
          _PrimaryBtn(label: 'Continue', onPressed: onContinue)
        else ...[
          _PrimaryBtn(
            label: enrolling ? 'Registering...' : 'Register Biometrics',
            icon: FontAwesomeIcons.fingerprint.data,
            onPressed: enrolling ? null : onEnroll,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip, use PIN only',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── PIN step (reused for create + confirm) ────────────────────────────────────

class _PinStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? error;
  final VoidCallback onSubmit;

  const _PinStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.focusNode,
    this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.lock,
              size: 28,
              color: cs.onPrimaryContainer,
            ),
          ),
        ).animate().scale(duration: 350.ms, curve: Curves.elasticOut),
        const SizedBox(height: 20),

        Text(
          title,
          style: GoogleFonts.syne(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: cs.onSurface.withValues(alpha: 0.55),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // PIN field
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.inter(fontSize: 28, letterSpacing: 12),
          decoration: InputDecoration(
            counterText: '',
            hintText: '• • • •',
            hintStyle: GoogleFonts.inter(
              fontSize: 20,
              letterSpacing: 8,
              color: cs.onSurface.withValues(alpha: 0.2),
            ),
            filled: true,
            fillColor: cs.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            errorText: error,
            errorStyle: GoogleFonts.inter(fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 20),

        _PrimaryBtn(label: 'Continue', onPressed: onSubmit),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Shared primary button ─────────────────────────────────────────────────────
class _PrimaryBtn extends StatelessWidget {
  final String label;
  final Object? icon;
  final VoidCallback? onPressed;

  const _PrimaryBtn({required this.label, this.icon, this.onPressed});

  /// Renders Material and Font Awesome icons uniformly.
  Widget? _buildIcon(Color color, {double size = 20}) {
    final icon = this.icon;
    if (icon == null) return null;

    if (icon is FaIconData) {
      return FaIcon(icon, size: size, color: color);
    }
    if (icon is IconData) {
      return Icon(icon, size: size, color: color);
    }
    assert(false, 'Unsupported icon type: ${icon.runtimeType}');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final iconWidget = _buildIcon(Colors.white, size: 15);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: iconWidget ?? const SizedBox.shrink(),
        label: Text(
          label,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
