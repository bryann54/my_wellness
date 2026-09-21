// lib/features/auth/presentation/pages/register_stepper_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/step_progress.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_state_listener.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_bottom_bar.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_header.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/presentation/bloc/geography_bloc.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_consent.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_credentials.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_identity.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_location.dart';

@RoutePage()
class RegisterStepperScreen extends StatefulWidget {
  const RegisterStepperScreen({super.key});

  @override
  State<RegisterStepperScreen> createState() => _RegisterStepperScreenState();
}

class _RegisterStepperScreenState extends State<RegisterStepperScreen> {
  static const _totalSteps = 4;

  final _pageController = PageController();
  int _step = 0;

  // Accumulating draft
  String? _email;
  String? _phone;
  String? _password;
  String? _firstName;
  String? _surname;
  String? _gender;
  DateTime? _dateOfBirth;
  String? _nationalIdNumber;
  County? _county;
  SubCounty? _subCounty;
  bool _consentGiven = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GeographyBloc>().add(const LoadAllGeographyEvent());
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _next() {
    if (_step < _totalSteps - 1) _goTo(_step + 1);
  }

  void _back() {
    if (_step > 0) {
      _goTo(_step - 1);
    } else {
      context.router.maybePop();
    }
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  void _submit() {
    if (!_consentGiven) return;

    final request = SignupRequestModel(
      email: (_email ?? '').trim().isEmpty ? null : _email!.trim(),
      phone: (_phone ?? '').trim().isEmpty ? null : _phone!.trim(),
      password: _password ?? '',
      firstName: (_firstName ?? '').trim(),
      surname: (_surname ?? '').trim(),
      gender: _gender,
      dateOfBirth: _dateOfBirth == null ? null : _isoDate(_dateOfBirth!),
      nationalIdNumber: (_nationalIdNumber ?? '').trim().isEmpty
          ? null
          : _nationalIdNumber!.trim(),
      countyId: _county?.id,
      subCountyId: _subCounty?.id,
    );

    context.read<AuthBloc>().add(SignUpEvent(request));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: AuthStateListener(
        isRegistration: true,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar: back + chat link ─────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  children: [
                    if (_step > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: _back,
                        tooltip: AppLocalizations.getString(
                          context,
                          'common.back',
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => context.router.push(
                        const ConversationalRegisterRoute(),
                      ),
                      icon: const Icon(Icons.forum_outlined, size: 18),
                      label: Text(
                        AppLocalizations.getString(context, 'auth.preferChat'),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: cs.primary,
                        textStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                child: AuthHeader(
                  title: AppLocalizations.getString(
                    context,
                    'auth.createAccount',
                  ),
                  subtitle: AppLocalizations.getString(
                    context,
                    'auth.setupAccount',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Full-width progress ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StepProgress(
                  currentStep: _step + 1,
                  totalSteps: _totalSteps,
                  label: 'Step ${_step + 1} of $_totalSteps',
                ),
              ),

              const SizedBox(height: 20),

              // ── Step content ─────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    RegisterStepCredentials(
                      initialEmail: _email,
                      initialPhone: _phone,
                      onContinue:
                          ({
                            required email,
                            required phone,
                            required password,
                          }) {
                            setState(() {
                              _email = email;
                              _phone = phone;
                              _password = password;
                            });
                            _next();
                          },
                    ),
                    RegisterStepIdentity(
                      initial: IdentityDraft(
                        firstName: _firstName,
                        surname: _surname,
                        gender: _gender,
                        dateOfBirth: _dateOfBirth,
                        nationalIdNumber: _nationalIdNumber,
                      ),
                      onContinue: (draft) {
                        setState(() {
                          _firstName = draft.firstName;
                          _surname = draft.surname;
                          _gender = draft.gender;
                          _dateOfBirth = draft.dateOfBirth;
                          _nationalIdNumber = draft.nationalIdNumber;
                        });
                        _next();
                      },
                    ),
                    RegisterStepLocation(
                      initialCounty: _county,
                      initialSubCounty: _subCounty,
                      onContinue: ({required county, required subCounty}) {
                        setState(() {
                          _county = county;
                          _subCounty = subCounty;
                        });
                        _next();
                      },
                    ),
                    RegisterStepConsent(
                      initialConsent: _consentGiven,
                      onSubmit: (consent) {
                        setState(() => _consentGiven = consent);
                        _submit();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AuthBottomBar(
        promptText: AppLocalizations.getString(
          context,
          'auth.alreadyHaveAccount',
        ),
        actionText: AppLocalizations.getString(context, 'auth.signInLink'),
        onActionPressed: () {
          context.router.replace(const LoginRoute());
        },
        heroTag: 'auth_toggle_button',
      ),
    );
  }
}
