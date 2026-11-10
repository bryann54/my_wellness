import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/notifiers/locale_provider.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/step_progress.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_state_listener.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_bottom_bar.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_header.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/language_selector.dart';
import 'package:my_wellness/features/geography/domain/entities/constituency.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/domain/entities/ward.dart';
import 'package:my_wellness/features/geography/presentation/bloc/geography_bloc.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_credentials.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_identity.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_location.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_submit.dart';

extension _IdentityDraftDebug on IdentityDraft {
  String toDebugString() =>
      'IdentityDraft('
      'firstName: $firstName, '
      'surname: $surname, '
      'idNumber: $idNumber, '
      'verificationId: $verificationId, '
      'idType: $idType, '
      'acceptedTerms: $acceptedTerms, '
      'gender: $gender, '
      'dateOfBirth: $dateOfBirth'
      ')';
}

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _totalSteps = 4;

  final _pageController = PageController();
  int _step = 0;

  IdentityDraft? _identity;
  String? _email;
  String? _phone;
  String? _password;
  String? _inviteToken;
  County? _county;
  SubCounty? _subCounty;
  Constituency? _constituency;
  Ward? _ward;

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

  void _submit() {
    debugPrint('🔵 [RegisterScreen] _submit() called.');

    final identity = _identity;
    if (identity == null) {
      debugPrint(
        '🔴 [RegisterScreen] ERROR: _identity is null. Aborting submission.',
      );
      return;
    }

    debugPrint('🔵 [RegisterScreen] Building SignupRequestModel with data:');
    debugPrint('    identity.firstName: ${identity.firstName}');
    debugPrint('    identity.surname: ${identity.surname}');
    debugPrint('    identity.gender: ${identity.gender}');
    debugPrint('    identity.dateOfBirth: ${identity.dateOfBirth}');
    debugPrint('    identity.idNumber: ${identity.idNumber}');
    debugPrint('    identity.verificationId: ${identity.verificationId}');
    debugPrint('    identity.acceptedTerms: ${identity.acceptedTerms}');
    debugPrint('    _email: $_email');
    debugPrint('    _phone: $_phone');
    debugPrint('    _password: ${_password != null ? '***' : 'NULL'}');

   final request = SignupRequestModel(
      email: (_email ?? '').trim().isEmpty ? null : _email!.trim(),
      phone: (_phone ?? '').trim().isEmpty ? null : _phone!.trim(),
      password: _password ?? '',
      firstName: identity.firstName,
      surname: identity.surname,
      gender: identity.gender,
      dateOfBirth: identity.dateOfBirth == null
          ? null
          : _toIsoDate(identity.dateOfBirth!),
      nationalIdNumber: identity.idNumber,
      idType: identity.idType,
      identityVerificationId: identity.verificationId,
      county: _county?.name,
      inviteToken: (_inviteToken ?? '').trim().isEmpty
          ? null
          : _inviteToken!.trim(),
      acceptedTerms: identity.acceptedTerms,
      subCountyId: _subCounty?.id,
      constituencyId: _constituency?.id,
      wardId: _ward?.id,
    );

    debugPrint(
      '🟢 [RegisterScreen] SignupRequestModel Payload to send: ${request.toJson()}',
    );

    context.read<AuthBloc>().add(SignUpEvent(request));
    debugPrint('🟢 [RegisterScreen] Dispatched SignUpEvent to AuthBloc.');
  }

  void _handleAccountState(BuildContext context, AccountState state) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (state.currentLang != localeProvider.locale.languageCode) {
      localeProvider.setLocale(Locale(state.currentLang));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthBloc, bool>(
      (b) => b.state.status == AuthStatus.loading,
    );

    return Scaffold(
      body: BlocListener<AccountBloc, AccountState>(
        listenWhen: (prev, curr) => prev.currentLang != curr.currentLang,
        listener: _handleAccountState,
        child: AuthStateListener(
          isRegistration: true,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    0,
                  ),
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
                      const LanguageSelector(),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    0,
                  ),
                  child: AuthHeader(
                    title: AppLocalizations.getString(
                      context,
                      'auth.createAccount',
                    ),
                    subtitle: AppLocalizations.getString(
                      context,
                      'auth.setupAccount',
                    ),
                    heroTag: HeroTags.authLogo,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: StepProgress(
                    currentStep: _step + 1,
                    totalSteps: _totalSteps,
                    label:
                        AppLocalizations.getString(context, 'auth.stepProgress')
                            .replaceFirst('{current}', '${_step + 1}')
                            .replaceFirst('{total}', '$_totalSteps'),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      RegisterStepIdentity(
                        initial: _identity,
                        onContinue: (draft) {
                          debugPrint(
                            '🟢 [RegisterScreen] Identity step completed. '
                            'Draft: ${draft.toDebugString()}',
                          );
                          setState(() => _identity = draft);
                          _next();
                        },
                      ),
                      RegisterStepCredentials(
                        initialEmail: _email,
                        initialPhone: _identity?.verifiedPhone ?? _phone,
                        phoneIsVerified: _identity?.phoneLocked ?? false,
                        onContinue:
                            ({
                              required email,
                              required phone,
                              required password,
                              required inviteToken,
                            }) {
                              debugPrint(
                                '🟢 [RegisterScreen] Credentials step completed. '
                                'Email: $email, Phone: $phone',
                              );
                              setState(() {
                                _email = email;
                                _phone = phone;
                                _password = password;
                                _inviteToken = inviteToken;
                              });
                              _next();
                            },
                      ),
                      RegisterStepLocation(
                        initialCounty: _county,
                        initialSubCounty: _subCounty,
                        initialConstituency: _constituency,
                        initialWard: _ward,
                        seedCountyId: _identity?.countyId,
                        seedSubCountyId: _identity?.subCountyId,
                        seedConstituencyId: _identity?.constituencyId,
                        seedWardId: _identity?.wardId,
                        onContinue:
                            ({
                              required county,
                              required subCounty,
                              required constituency,
                              required ward,
                            }) {
                              debugPrint(
                                '🟢 [RegisterScreen] Location step completed. '
                                'County: ${county.name}',
                              );
                              setState(() {
                                _county = county;
                                _subCounty = subCounty;
                                _constituency = constituency;
                                _ward = ward;
                              });
                              _next();
                            },
                      ),
                      RegisterStepSubmit(
                        summary: SubmitSummary(
                          email: _email,
                          phone: _phone,
                          firstName: _identity?.firstName ?? '',
                          surname: _identity?.surname ?? '',
                          gender: _identity?.gender,
                          dateOfBirth: _identity?.dateOfBirth,
                          county: _county,
                          subCounty: _subCounty,
                          constituency: _constituency,
                          ward: _ward,
                        ),
                        isLoading: isLoading,
                        onSubmit: _submit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AuthBottomBar(
        promptText: AppLocalizations.getString(
          context,
          'auth.alreadyHaveAccount',
        ),
        actionText: AppLocalizations.getString(context, 'auth.signInLink'),
        heroTag: HeroTags.authToggle,
        onActionPressed: () => context.router.replace(const LoginRoute()),
      ),
    );
  }
}
String _toIsoDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
