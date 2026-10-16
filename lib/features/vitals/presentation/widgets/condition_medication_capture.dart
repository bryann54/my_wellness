import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:my_wellness/features/vitals/domain/entities/medication.dart';
import 'package:my_wellness/features/vitals/domain/usecases/vitals_usecases.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/medication_tile.dart';

class ConditionMedicationCapture extends StatefulWidget {
  const ConditionMedicationCapture({super.key, required this.condition});

  final String condition;

  @override
  State<ConditionMedicationCapture> createState() =>
      _ConditionMedicationCaptureState();
}

class _ConditionMedicationCaptureState
    extends State<ConditionMedicationCapture> {
  List<Medication>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final useCase = context.read<GetMedicationsByConditionUseCase>();
    final result = await useCase(widget.condition);
    if (!mounted) return;
    result.fold(
      (f) => setState(() => _error = mapFailure(f)),
      (items) => setState(() => _items = items),
    );
  }

  Future<void> _delete(Medication m) async {
    final useCase = context.read<DeleteMedicationUseCase>();
    await useCase(m.id);
    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.error),
            ),
            TextButton(
              onPressed: _load,
              child: Text(
                AppLocalizations.getString(context, 'common.retry'),
              ),
            ),
          ],
        ),
      );
    }

    if (_items == null) {
      return const Column(children: [ShimmerListTile(), ShimmerListTile()]);
    }

    if (_items!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          AppLocalizations.getString(context, 'medications.emptyCondition'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return Column(
      children: [
        ..._items!.map(
          (m) => MedicationTile(medication: m, onDelete: () => _delete(m)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => context.router.push(AddMedicationRoute()),
            icon: const Icon(Icons.add, size: 18),
            label: Text(AppLocalizations.getString(context, 'medications.add')),
          ),
        ),
      ],
    );
  }
}