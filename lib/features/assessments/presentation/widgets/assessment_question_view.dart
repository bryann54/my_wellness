import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_question.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_choice_tile.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_number_field.dart';

class AssessmentQuestionView extends StatefulWidget {
  final AssessmentQuestion question;
  final String? initialValue;
  final ValueChanged<String> onChanged;
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
    text: widget.initialValue ?? '',
  );
  String? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.question.type == AssessmentQuestionType.radio &&
        widget.initialValue != null) {
      _selected = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    super.dispose();
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

      case AssessmentQuestionType.number:
        return AssessmentNumberField(
          controller: _numberCtrl,
          min: widget.question.min,
          max: widget.question.max,
          onChanged: widget.onChanged,
        );

      case AssessmentQuestionType.text:
        return AssessmentNumberField(
          controller: _numberCtrl,
          onChanged: widget.onChanged,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        );

      case AssessmentQuestionType.multiSelect:
        return const SizedBox.shrink(); // extend when API ships this

      case AssessmentQuestionType.bmi:
      case AssessmentQuestionType.unknown:
        return const SizedBox.shrink();
    }
  }
}
