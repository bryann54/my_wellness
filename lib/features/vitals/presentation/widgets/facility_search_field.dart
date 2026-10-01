import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/debouncer.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';
import 'package:my_wellness/features/vitals/domain/usecases/vitals_usecases.dart';

class FacilitySearchField extends StatefulWidget {
  final void Function(String? clinicName, String? facilityId) onChanged;

  final String? initialClinicName;
  final String? initialFacilityId;

  const FacilitySearchField({
    super.key,
    required this.onChanged,
    this.initialClinicName,
    this.initialFacilityId,
  });

  @override
  State<FacilitySearchField> createState() => _FacilitySearchFieldState();
}

class _FacilitySearchFieldState extends State<FacilitySearchField> {
  final _controller = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);
  final _focusNode = FocusNode();

  Facility? _picked;
  List<Facility> _results = const [];
  bool _loading = false;
  bool _hasSearched = false;
  String? _lastQuery;

  @override
  void initState() {
    super.initState();
    if (widget.initialClinicName != null && widget.initialFacilityId != null) {
      _controller.text = widget.initialClinicName!;
    }
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    final query = q.trim();
    if (_picked != null) {
      setState(() => _picked = null);
    }
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _hasSearched = false;
        _loading = false;
      });
      widget.onChanged(null, null);
      return;
    }

    widget.onChanged(query, null);
    if (query == _lastQuery) return;

    _debouncer.run(() => _search(query));
  }

  Future<void> _search(String query) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _hasSearched = true;
    });

    final useCase = getIt<SearchFacilitiesUseCase>();
    final result = await useCase(query);

    if (!mounted) return;

    result.fold(
      (_) => setState(() {
        _loading = false;
        _results = const [];
      }),
      (facilities) => setState(() {
        _loading = false;
        _lastQuery = query;
        _results = facilities;
      }),
    );
  }

  void _pick(Facility f) {
    setState(() {
      _picked = f;
      _results = const [];
      _hasSearched = false;
      _lastQuery = null;
      _controller.text = f.name;
    });
    _focusNode.unfocus();
    widget.onChanged(f.name, f.id);
  }

  void _clear() {
    setState(() {
      _picked = null;
      _controller.clear();
      _results = const [];
      _hasSearched = false;
      _lastQuery = null;
    });
    widget.onChanged(null, null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_picked != null) {
      return _SelectedFacilityCard(facility: _picked!, onClear: _clear);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoftInput(
          controller: _controller,
          focusNode: _focusNode,
          label: AppLocalizations.getString(
            context,
            'appointments.facilityLabel',
          ),
          hint: AppLocalizations.getString(
            context,
            'appointments.facilityHint',
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
        ),
        if (_loading || _hasSearched) ...[
          const SizedBox(height: 8),
          _ResultsPanel(
            loading: _loading,
            results: _results,
            hasQuery: _controller.text.trim().isNotEmpty,
            onPick: _pick,
            cs: cs,
          ),
        ],
      ],
    );
  }
}

class _SelectedFacilityCard extends StatelessWidget {
  final Facility facility;
  final VoidCallback onClear;

  const _SelectedFacilityCard({required this.facility, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.local_hospital_outlined,
              size: 18,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facility.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: cs.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (facility.locality.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    facility.locality,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: cs.onSurface.withValues(alpha: 0.5),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  final bool loading;
  final List<Facility> results;
  final bool hasQuery;
  final void Function(Facility) onPick;
  final ColorScheme cs;

  const _ResultsPanel({
    required this.loading,
    required this.results,
    required this.hasQuery,
    required this.onPick,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
        ),
      );
    }

    if (results.isEmpty) {
      if (!hasQuery) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(
          AppLocalizations.getString(context, 'appointments.facilityNoMatch'),
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: cs.onSurface.withValues(alpha: 0.55),
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: results.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 12,
          endIndent: 12,
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
        itemBuilder: (context, i) {
          final f = results[i];
          return InkWell(
            onTap: () => onPick(f),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.name,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: cs.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (f.locality.isNotEmpty || f.kephLevel != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (f.locality.isNotEmpty) f.locality,
                        if (f.kephLevel != null) 'KEPH ${f.kephLevel}',
                        if (f.coversSha) 'SHA',
                      ].join(' · '),
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
