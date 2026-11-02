import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/pricing/domain/usecases/get_pricing_packages.dart';

@RoutePage()
class ReceiptsAndInvoicesScreen extends StatelessWidget {
  const ReceiptsAndInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => _BillingBloc(
      getReceipts: getIt<GetReceiptsUseCase>(),
      getInvoices: getIt<GetInvoicesUseCase>(),
      downloadReceipt: getIt<DownloadReceiptPdfUseCase>(),
      downloadInvoice: getIt<DownloadInvoicePdfUseCase>(),
    )..add(_LoadBillingEvent()),
    child: const _BillingBody(),
  );
}

abstract class _BillingEvent {}

class _LoadBillingEvent extends _BillingEvent {
  _LoadBillingEvent();
}

class _DownloadReceiptEvent extends _BillingEvent {
  final String id;
  _DownloadReceiptEvent(this.id);
}

class _DownloadInvoiceEvent extends _BillingEvent {
  final String id;
  _DownloadInvoiceEvent(this.id);
}

class _BillingState {
  final bool loading;
  final String? errorMessage;
  final List<Map<String, dynamic>> receipts;
  final List<Map<String, dynamic>> invoices;
  final Uint8List? lastPdf;

  const _BillingState({
    this.loading = false,
    this.errorMessage,
    this.receipts = const [],
    this.invoices = const [],
    this.lastPdf,
  });

  _BillingState copyWith({
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    List<Map<String, dynamic>>? receipts,
    List<Map<String, dynamic>>? invoices,
    Uint8List? lastPdf,
  }) => _BillingState(
    loading: loading ?? this.loading,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    receipts: receipts ?? this.receipts,
    invoices: invoices ?? this.invoices,
    lastPdf: lastPdf ?? this.lastPdf,
  );
}

class _BillingBloc extends Bloc<_BillingEvent, _BillingState> {
  final GetReceiptsUseCase _getReceipts;
  final GetInvoicesUseCase _getInvoices;
  final DownloadReceiptPdfUseCase _downloadReceipt;
  final DownloadInvoicePdfUseCase _downloadInvoice;

  _BillingBloc({
    required GetReceiptsUseCase getReceipts,
    required GetInvoicesUseCase getInvoices,
    required DownloadReceiptPdfUseCase downloadReceipt,
    required DownloadInvoicePdfUseCase downloadInvoice,
  }) : _getReceipts = getReceipts,
       _getInvoices = getInvoices,
       _downloadReceipt = downloadReceipt,
       _downloadInvoice = downloadInvoice,
       super(const _BillingState()) {
    on<_LoadBillingEvent>(_onLoad);
    on<_DownloadReceiptEvent>(_onDownloadReceipt);
    on<_DownloadInvoiceEvent>(_onDownloadInvoice);
  }

  Future<void> _onLoad(
    _LoadBillingEvent event,
    Emitter<_BillingState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    final receiptsRes = await _getReceipts();
    final invoicesRes = await _getInvoices();
    final receipts = receiptsRes.fold((failure) {
      emit(state.copyWith(errorMessage: failure.toString()));
      return const <Map<String, dynamic>>[];
    }, (list) => list);
    final invoices = invoicesRes.fold(
      (_) => const <Map<String, dynamic>>[],
      (list) => list,
    );
    emit(
      state.copyWith(loading: false, receipts: receipts, invoices: invoices),
    );
  }

  Future<void> _onDownloadReceipt(
    _DownloadReceiptEvent event,
    Emitter<_BillingState> emit,
  ) async {
    final res = await _downloadReceipt(event.id);
    res.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.toString())),
      (bytes) => emit(state.copyWith(lastPdf: bytes)),
    );
  }

  Future<void> _onDownloadInvoice(
    _DownloadInvoiceEvent event,
    Emitter<_BillingState> emit,
  ) async {
    final res = await _downloadInvoice(event.id);
    res.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.toString())),
      (bytes) => emit(state.copyWith(lastPdf: bytes)),
    );
  }
}

class _BillingBody extends StatelessWidget {
  const _BillingBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(
            title: AppLocalizations.getString(context, 'pricing.billing.title'),
            isHome: false,
          ),
        ],
        body: BlocBuilder<_BillingBloc, _BillingState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (state.receipts.isEmpty && state.invoices.isEmpty) {
              return _EmptyState(message: state.errorMessage);
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                if (state.receipts.isNotEmpty) ...[
                  _SectionHeader(
                    label: AppLocalizations.getString(
                      context,
                      'pricing.billing.receipts',
                    ),
                  ),
                  for (final r in state.receipts)
                    _ReceiptTile(
                      data: r,
                      onDownload: () => context.read<_BillingBloc>().add(
                        _DownloadReceiptEvent(r['id'].toString()),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (state.invoices.isNotEmpty) ...[
                  _SectionHeader(
                    label: AppLocalizations.getString(
                      context,
                      'pricing.billing.invoices',
                    ),
                  ),
                  for (final i in state.invoices)
                    _InvoiceTile(
                      data: i,
                      onDownload: () => context.read<_BillingBloc>().add(
                        _DownloadInvoiceEvent(i['id'].toString()),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.md),
    child: Text(label, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _ReceiptTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onDownload;
  const _ReceiptTile({required this.data, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final number = data['receipt_number']?.toString() ?? '';
    final amount = data['amount_kes'];
    final paidAt = data['paid_at']?.toString();
    final label = data['service_label']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.receipt_long_outlined, color: cs.primary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.isEmpty ? 'Receipt $number' : label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (paidAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    friendlyDateTime(paidAt),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                if (amount is num) ...[
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(amount),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onDownload;
  const _InvoiceTile({required this.data, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final number = data['invoice_number']?.toString() ?? '';
    final total = data['total_kes'];
    final status = data['status']?.toString() ?? '';
    final issuedAt = data['issued_at']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.description_outlined, color: cs.primary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number.isEmpty ? 'Invoice' : 'Invoice $number',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (issuedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    friendlyDateTime(issuedAt),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                if (total is num) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${formatPrice(total)} · ${status.toUpperCase()}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: status == 'paid' ? cs.primary : cs.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? message;
  const _EmptyState({this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message ??
                  AppLocalizations.getString(context, 'pricing.billing.empty'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
