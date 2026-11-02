import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_question.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_choice_tile.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_multi_choice_tile.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_number_field.dart';

class AssessmentQuestionView extends StatefulWidget {
  final AssessmentQuestion question;

  final Object? initialValue;

  final ValueChanged<Object> onChanged;

  final bool showError;
  final bool hidePrompt;

  const AssessmentQuestionView({
    super.key,
    required this.question,
    required this.onChanged,
    this.initialValue,
    this.showError = false,
    this.hidePrompt = false,
  });

  @override
  State<AssessmentQuestionView> createState() => _AssessmentQuestionViewState();
}

class _AssessmentQuestionViewState extends State<AssessmentQuestionView> {
  late final TextEditingController _numberCtrl = TextEditingController(
    text: _stringOf(widget.initialValue),
  );
  String? _selected;
  final Set<String> _selectedMulti = {};

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;

    if (widget.question.type == AssessmentQuestionType.radio &&
        initial is String) {
      _selected = initial;
    }

    if (widget.question.type == AssessmentQuestionType.multiSelect) {
      if (initial is List) {
        _selectedMulti.addAll(initial.map((e) => e.toString()));
      } else if (initial is String && initial.isNotEmpty) {
        _selectedMulti.addAll(
          initial.split(',').map((v) => v.trim()).where((v) => v.isNotEmpty),
        );
      }
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    super.dispose();
  }

  static String? _stringOf(Object? v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  void _toggleMulti(String value) {
    final exclusive = widget.question.exclusiveValue;
    setState(() {
      if (exclusive != null && value == exclusive) {
        _selectedMulti
          ..clear()
          ..add(exclusive);
      } else {
        if (exclusive != null) _selectedMulti.remove(exclusive);
        if (_selectedMulti.contains(value)) {
          _selectedMulti.remove(value);
        } else {
          _selectedMulti.add(value);
        }
      }
    });

    final ordered = widget.question.options
        .map((o) => o.value)
        .where(_selectedMulti.contains)
        .toList(growable: false);

    widget.onChanged(ordered);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final q = widget.question;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.hidePrompt)
          Text(
            q.prompt,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: cs.onSurface,
            ),
          ),
        if (q.description != null && q.description!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            q.description!,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        if (q.insight != null && q.insight!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    q.insight!,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.45,
                      color: cs.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        _buildInput(),
        if (widget.showError) ...[
          const SizedBox(height: 8),
          Text(
            'Please answer this question to continue.',
            style: GoogleFonts.inter(fontSize: 12.5, color: cs.error),
          ),
        ],
      ],
    );
  }

  Widget _buildInput() {
    switch (widget.question.type) {
      case AssessmentQuestionType.radio:
        return Column(
          children: [
            for (final o in widget.question.options) ...[
              AssessmentChoiceTile(
                option: o,
                selected: _selected == o.value,
                onTap: () {
                  setState(() => _selected = o.value);
                  widget.onChanged(o.value);
                },
              ),
              const SizedBox(height: 10),
            ],
          ],
        );

      case AssessmentQuestionType.multiSelect:
        return Column(
          children: [
            for (final o in widget.question.options) ...[
              AssessmentMultiChoiceTile(
                option: o,
                selected: _selectedMulti.contains(o.value),
                onTap: () => _toggleMulti(o.value),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );

      case AssessmentQuestionType.number:
        return AssessmentNumberField(
          controller: _numberCtrl,
          min: widget.question.min,
          max: widget.question.max,
          onChanged: (v) {
            final n = int.tryParse(v.trim());
            if (n != null) widget.onChanged(n);
          },
        );

      case AssessmentQuestionType.text:
        return AssessmentNumberField(
          controller: _numberCtrl,
          onChanged: (v) => widget.onChanged(v),
          validator: widget.question.optional
              ? (v) => null
              : (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        );

      case AssessmentQuestionType.bmi:
      case AssessmentQuestionType.unknown:
        return const SizedBox.shrink();
    }
  }
}
