import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/notifiers/locale_provider.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_content.dart';
import 'package:provider/provider.dart';

@RoutePage()
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  void _handleAccountState(BuildContext context, AccountState state) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (state.currentLang != localeProvider.locale.languageCode) {
      localeProvider.setLocale(Locale(state.currentLang));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listenWhen: (prev, curr) => prev.currentLang != curr.currentLang,
      listener: _handleAccountState,
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: AuthContent(),
      ),
    );
  }
}
