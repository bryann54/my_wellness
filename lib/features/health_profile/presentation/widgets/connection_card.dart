import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/core/errors/exceptions.dart';

/// Lives at the top of My Medical History.
/// Behaviour is fixed by the DHA SHR contract — polling cadence, status
/// fields, toasts and the 9s backstop are all preserved. Only the visual
/// treatment changed.
class ConnectionCard extends StatefulWidget {
  const ConnectionCard({super.key, required this.onHistoryRefresh});

  /// Called whenever the backend reports records finished fetching
  /// (`records_fetching: true → false`), or after a resync POST + 9s.
  final Future<void> Function() onHistoryRefresh;

  @override
  State<ConnectionCard> createState() => _ConnectionCardState();
}

class _ConnectionCardState extends State<ConnectionCard> {
  final _client = getIt<ApiClient>();
  Timer? _timer;
  Map<String, dynamic>? _status;
  bool _sending = false;
  bool _openedConsent = false;
  bool _wasFetching = false;
  String? _lastNotice;

  bool get _hasOpenVisit => _status?['has_open_visit'] == true;
  bool get _canResync => _status?['can_resync'] == true;
  bool get _recordsFetching => _status?['records_fetching'] == true;
  bool get _dhaPhoneMissing => _status?['dha_phone_missing'] == true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await _client.get<Map<String, dynamic>>(
        url: ApiEndpoints.shrResyncStatus,
        options: ApiClient.protected,
      );
      if (!mounted) return;
      final fetching = status['records_fetching'] == true;
      if (_wasFetching && !fetching) widget.onHistoryRefresh();
      _wasFetching = fetching;
      setState(() => _status = status);

      final consentStatus = status['consent_request_status']?.toString();
      if (consentStatus == 'requested' && !_openedConsent) {
        _openedConsent = true;
        await context.router.push(const ShrConsentRoute());
        if (!mounted) return;
        _openedConsent = false;
        await _loadStatus();
        return;
      }
      if (consentStatus == 'no_dha_phone') {
        _showOnce(_t(context, 'healthHistory.dhaPhoneMissingNotice'));
      } else if (consentStatus == 'not_possible') {
        _showOnce(_t(context, 'healthHistory.dhaRecordUnavailable'));
      }
      _schedule(fetching || consentStatus == 'pending' ? 3 : 15);
    } on Exception {
      _schedule(15);
    }
  }

  void _showOnce(String message) {
    if (_lastNotice == message) return;
    _lastNotice = message;
    AppSnackbar.info(context, message);
  }

  void _schedule(int seconds) {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: seconds), _loadStatus);
  }

  Future<void> _act() async {
    setState(() => _sending = true);
    try {
      if (_hasOpenVisit) {
        await _client.post<Map<String, dynamic>>(
          url: ApiEndpoints.shrResync,
          options: ApiClient.protected,
        );
        if (!mounted) return;
        AppSnackbar.success(
          context,
          _t(context, 'healthHistory.refreshRequested'),
        );
        await widget.onHistoryRefresh();
        Timer(const Duration(seconds: 9), () {
          if (mounted) widget.onHistoryRefresh();
        });
      } else {
        await _client.post<Map<String, dynamic>>(
          url: ApiEndpoints.shrRequestConsent,
          options: ApiClient.protected,
        );
      }
      await _loadStatus();
    } on ValidationException {
      if (mounted) {
        AppSnackbar.error(context, _t(context, 'healthHistory.dhaError'));
      }
    } on Exception {
      if (mounted) {
        AppSnackbar.error(context, _t(context, 'healthHistory.dhaError'));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    if (status == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final connected = _hasOpenVisit;
    final accent = connected ? cs.secondary : cs.tertiary;

    final nextEligible = status['next_eligible_at']?.toString();
    final onCooldown = !_canResync && nextEligible != null;
    final enabled = _canResync && !_recordsFetching && !_sending;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status row ─────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: connected ? accent : cs.onSurfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _t(context, 'healthHistory.connectionTitle'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusChip(connected: connected),
              ],
            ),
            const SizedBox(height: 12),

            // ── Fixed body paragraph (contract requirement) ────────────
            Text(
              _t(context, 'healthHistory.connectionBody'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),

            if (_recordsFetching) ...[
              const SizedBox(height: 14),
              const _FetchingBanner(),
            ],

            if (_dhaPhoneMissing && !_hasOpenVisit) ...[
              const SizedBox(height: 12),
              _InfoBanner(
                icon: Icons.phone_disabled_outlined,
                text: _t(context, 'healthHistory.dhaPhoneMissingInline'),
              ),
            ],

            const SizedBox(height: 14),

            // ── Connection status / cooldown line ──────────────────────
            Text(
              onCooldown
                  ? AppLocalizations.t(context, 'healthHistory.cooldown', {
                      'date': _formatDateTime(context, nextEligible),
                    })
                  : AppLocalizations.t(
                      context,
                      'healthHistory.connectionStatus',
                      {
                        'status': _t(
                          context,
                          connected
                              ? 'healthHistory.active'
                              : 'healthHistory.awaitingVerification',
                        ),
                      },
                    ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),

            const SizedBox(height: 12),
            AppPrimaryButton(
              onPressed: enabled ? _act : null,
              label: _sending
                  ? _t(
                      context,
                      _hasOpenVisit
                          ? 'healthHistory.refreshing'
                          : 'healthHistory.requesting',
                    )
                  : (_hasOpenVisit
                        ? _t(context, 'healthHistory.refreshFromDha')
                        : _t(context, 'healthHistory.requestDhaConsent')),
              isLoading: _sending,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.connected});
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: connected ? cs.secondaryContainer : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _t(
          context,
          connected
              ? 'healthHistory.consentConfirmed'
              : 'healthHistory.consentNotConfirmed',
        ),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: connected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FetchingBanner extends StatelessWidget {
  const _FetchingBanner();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _t(context, 'healthHistory.fetchingRecords'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(BuildContext context, String raw) {
  final value = DateTime.tryParse(raw);
  return value == null
      ? _t(context, 'healthHistory.dateUnavailable')
      : DateFormat.yMMMd(
          Localizations.localeOf(context).toLanguageTag(),
        ).add_Hm().format(value.toLocal());
}

String _t(BuildContext context, String key) =>
    AppLocalizations.getString(context, key);
