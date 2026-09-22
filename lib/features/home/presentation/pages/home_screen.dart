// ignore_for_file: unused_local_variable

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/section_header.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountState = context.read<AccountBloc>().state;
      final userId = accountState.profile?..memberCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AccountBloc, AccountState>(
          listenWhen: (prev, curr) =>
              prev.profile == null && curr.profile != null,
          listener: (context, state) {
            final userId = state.profile?.memberCode;
          },
        ),
      ],
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const CustomAppBar(isHome: true, expandedHeight: 220),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              sliver: SliverList.list(
                children: [
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // // ── Quick actions list ──────────────────────────────────
                  SectionHeader(
                    label: AppLocalizations.getString(
                      context,
                      'common.resources',
                    ),
                  ),

                  // const SizedBox(height: 12),
                  // MenuCard(
                  //   icon: FontAwesomeIcons.shieldHalved.data,
                  //   title: AppLocalizations.getString(
                  //     context,
                  //     'common.witnessMode',
                  //   ),
                  //   subtitle: AppLocalizations.getString(
                  //     context,
                  //     'alerts.subtitle',
                  //   ),
                  //   cardColor: const Color(0xFFE3F2FD),
                  //   onTap: () => context.router.push(const AccountRoute()),
                  // ),
                  // const SizedBox(height: 12),
                  // MenuCard(
                  //   icon: FontAwesomeIcons.comments.data,
                  //   title: AppLocalizations.getString(
                  //     context,
                  //     'chatbot.chatWithAi',
                  //   ),
                  //   subtitle: AppLocalizations.getString(
                  //     context,
                  //     'chatbot.chatWithAiSub',
                  //   ),
                  //   cardColor: const Color(0xFFE8F5E9),
                  //   onTap: () => context.router.navigate(const AccountRoute()),
                  // ),
                  // const SizedBox(height: 12),
                  // MenuCard(
                  //   icon: FontAwesomeIcons.fileContract.data,
                  //   title: AppLocalizations.getString(
                  //     context,
                  //     'documents.store',
                  //   ),
                  //   subtitle: AppLocalizations.getString(
                  //     context,
                  //     'documents.storeSubtitle',
                  //   ),
                  //   cardColor: const Color(0xFFFFF3E0),
                  //   onTap: () => context.router.navigate(const AccountRoute()),
                  // ),
                  // const SizedBox(height: 12),
                  // MenuCard(
                  //   icon: Icons.wifi_tethering,
                  //   title: AppLocalizations.getString(
                  //     context,
                  //     'incidents.title',
                  //   ),
                  //   subtitle: AppLocalizations.getString(
                  //     context,
                  //     'incidents.subtitle',
                  //   ),
                  //   cardColor: const Color(0xFFFFEBEE),
                  //   onTap: () => context.router.push(const AccountRoute()),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
