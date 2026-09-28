import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/notifiers/locale_provider.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/step_progress.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/common/widgets/language_selector_row.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_state_listener.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_bottom_bar.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_header.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/presentation/bloc/geography_bloc.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_credentials.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_identity.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_location.dart';
import 'package:my_wellness/features/geography/presentation/pages/steps/register_step_submit.dart';
import 'package:provider/provider.dart';

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
  String? _email;
  String? _phone;
  String? _password;
  IdentityDraft? _identity;
  County? _county;
  SubCounty? _subCounty;

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
    final identity = _identity;
    if (identity == null) return;

    final request = SignupRequestModel(
      email: (_email ?? '').trim().isEmpty ? null : _email!.trim(),
      phone: (_phone ?? '').trim().isEmpty ? null : _phone!.trim(),
      password: _password ?? '',
      firstName: identity.firstName,
      surname: identity.surname,
      gender: identity.gender,
      dateOfBirth: identity.dateOfBirth == null
          ? null
          : _isoDate(identity.dateOfBirth!),
      nationalIdNumber: identity.idNumber,
      idType: identity.idType,
      identityVerificationId: identity.verificationId,
      countyId: _county?.id,
      subCountyId: _subCounty?.id,
    );

    context.read<AuthBloc>().add(SignUpEvent(request));
  }

  void _handleAccountState(BuildContext context, AccountState state) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (state.currentLang != localeProvider.locale.languageCode) {
      localeProvider.setLocale(Locale(state.currentLang));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLoading = context.select<AuthBloc, bool>(
      (b) => b.state.status == AuthStatus.loading,
    );

    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocListener<AccountBloc, AccountState>(
        listenWhen: (prev, curr) => prev.currentLang != curr.currentLang,
        listener: _handleAccountState,
        child: AuthStateListener(
          isRegistration: true,
          child: SafeArea(
            child: Column(
              children: [
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
                      const LanguageSelectorCompact(),
                    ],
                  ),
                ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: StepProgress(
                    currentStep: _step + 1,
                    totalSteps: _totalSteps,
                    label:
                        AppLocalizations.getString(context, 'auth.stepProgress')
                            .replaceFirst('{current}', '${_step + 1}')
                            .replaceFirst('{total}', '$_totalSteps'),
                  ),
                ),

                const SizedBox(height: 20),
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
                        initial: _identity,
                        onContinue: (draft) {
                          setState(() => _identity = draft);
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
        onActionPressed: () {
          context.router.replace(const LoginRoute());
        },
        heroTag: 'auth_toggle_button',
      ),
    );
  }
}
