// lib/features/auth/presentation/pages/conversational_register_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/constants/us_states.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_state_listener.dart';
import 'package:my_wellness/features/auth/presentation/widgets/conversation/conversation_bubble.dart';
import 'package:my_wellness/features/auth/presentation/widgets/conversation/conversation_input_bar.dart';
import 'package:my_wellness/features/auth/presentation/widgets/conversation/conversation_models.dart';
import 'package:my_wellness/features/auth/presentation/widgets/conversation/conversation_state_picker.dart';

@RoutePage()
class ConversationalRegisterScreen extends StatefulWidget {
  const ConversationalRegisterScreen({super.key});

  @override
  State<ConversationalRegisterScreen> createState() =>
      _ConversationalRegisterScreenState();
}

class _ConversationalRegisterScreenState
    extends State<ConversationalRegisterScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();
  late final FlutterTts _tts;

  final List<ConversationMessage> _messages = [];
  final Map<String, String> _answers = {};
  final _steps = conversationSteps;

  int _stepIndex = 0;
  bool _isPasswordVisible = false;
  String? _errorText;

  bool get _isDone => _stepIndex >= _steps.length;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _askCurrentStep());
  }

  @override
  void dispose() {
    _tts.stop();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _askCurrentStep() {
    if (_isDone) return;
    final question = AppLocalizations.getString(
      context,
      _steps[_stepIndex].questionKey,
    );
    setState(() {
      _messages.add(ConversationMessage(text: question, isAi: true));
      _errorText = null;
    });
    _scrollToBottom();
    _focusNode.requestFocus();
    _tts.speak(question);
  }

  void _onSend() {
    final input = _inputCtrl.text.trim();
    final error = _steps[_stepIndex].validate?.call(input);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    HapticFeedback.lightImpact();
    _answers[_steps[_stepIndex].questionKey] = input;

    setState(() {
      _messages.add(
        ConversationMessage(
          text: _steps[_stepIndex].type == FieldType.password
              ? '•' * input.length
              : input,
          isAi: false,
        ),
      );
      _errorText = null;
    });
    _inputCtrl.clear();
    _scrollToBottom();
    _advance();
  }

  void _onStatePicked(UsState state) {
    HapticFeedback.lightImpact();
    _answers[_steps[_stepIndex].questionKey] = state.code;
    setState(() {
      _messages.add(ConversationMessage(text: state.name, isAi: false));
      _errorText = null;
    });
    _scrollToBottom();
    _advance();
  }

  void _advance() {
    _stepIndex++;
    if (!_isDone) {
      Future.delayed(const Duration(milliseconds: 600), _askCurrentStep);
    } else {
      setState(() {});
    }
  }

void _submit() {
    String q(String key) => _answers[key] ?? '';

    final email = q('auth.askEmail').trim();
    final phone = q('auth.askPhone').trim();
    if (email.isEmpty && phone.isEmpty) {
      setState(() => _errorText = 'Email or phone required');
      return;
    }

    final request = SignupRequestModel(
      email: email.isEmpty ? null : email,
      phone: phone.isEmpty ? null : phone,
      password: q('auth.askPassword'),
      firstName: q('auth.askFirstName').trim(),
      surname: q('auth.askSurname').trim(),
      gender: q('auth.askGender').isEmpty ? null : q('auth.askGender'),
      dateOfBirth: q('auth.askDob').isEmpty ? null : q('auth.askDob'),
      nationalIdNumber: null, // not collected in conversational flow
    );

    context.read<AuthBloc>().add(SignUpEvent(request));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          AppLocalizations.getString(context, 'auth.createAccount'),
          style: GoogleFonts.syne(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: AuthStateListener(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 48,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.shield_rounded, size: 48, color: cs.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.getString(context, 'auth.title'),
                    style: GoogleFonts.syne(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.getString(context, 'auth.subtitle'),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _messages.length,
                itemBuilder: (_, i) =>
                    ConversationBubble(message: _messages[i], index: i),
              ),
            ),

            // ── Input / Submit ────────────────────────────────────────────
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state.status == AuthStatus.loading;
                return ConversationInputBar(
                  controller: _inputCtrl,
                  focusNode: _focusNode,
                  fieldType: _isDone ? FieldType.text : _steps[_stepIndex].type,
                  isPasswordVisible: _isPasswordVisible,
                  onVisibilityToggle: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  onSend: isLoading ? null : _onSend,
                
                  errorText: _errorText,
                  isLoading: isLoading,
                  isDone: _isDone,
                  onSubmit: isLoading ? null : _submit,
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
              child: GestureDetector(
                onTap: () => context.router.replace(RegisterRoute()),
                child: Text(
                  AppLocalizations.getString(context, 'auth.preferForm'),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: cs.onSurface.withValues(alpha: 0.4),
                    decoration: TextDecoration.underline,
                    decorationColor: cs.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
