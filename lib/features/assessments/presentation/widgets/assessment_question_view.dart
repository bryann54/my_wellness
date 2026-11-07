import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_question.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_choice_tile.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_multi_choice_tile.dart';
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
  final TextEditingController _textCtrl = TextEditingController();
  String? _selected;
  final Set<String> _selectedMulti = {};

  @override
  void initState() {
    super.initState();

    switch (widget.question.type) {
      case AssessmentQuestionType.radio:
      case AssessmentQuestionType.select:
        _selected = widget.initialValue;
      case AssessmentQuestionType.checkbox:
        if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
          _selectedMulti.addAll(
            widget.initialValue!
                .split(',')
                .map((v) => v.trim())
                .where((v) => v.isNotEmpty),
          );
        }
      case AssessmentQuestionType.text:
      case AssessmentQuestionType.date:
        if (widget.initialValue != null) {
          _textCtrl.text = widget.initialValue!;
        }
      default:
        break;
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _toggleMulti(String value) {
    final q = widget.question;
    final exclusive = q.exclusiveValue;
    setState(() {
      if (_selectedMulti.contains(value)) {
        _selectedMulti.remove(value);
      } else {
        if (exclusive != null && value == exclusive) {
          _selectedMulti
            ..clear()
            ..add(value);
        } else {
          if (exclusive != null) _selectedMulti.remove(exclusive);
          _selectedMulti.add(value);
        }
      }
    });
    final ordered = q.options
        .map((o) => o.value)
        .where(_selectedMulti.contains)
        .join(',');
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
            AppLocalizations.getString(context, 'assessment.answerRequired'),
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

      case AssessmentQuestionType.select:
        return DropdownButtonFormField<String>(
          initialValue: _selected,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.getString(
              context,
              'assessment.selectOption',
            ),
          ),
          items: [
            for (final o in widget.question.options)
              DropdownMenuItem(value: o.value, child: Text(o.label)),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _selected = v);
            widget.onChanged(v);
          },
        );

      case AssessmentQuestionType.checkbox:
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
        return Column(
          children: [
            AssessmentNumberField(
              controller: _numberCtrl,
              min: widget.question.min,
              max: widget.question.max,
              onChanged: widget.onChanged,
            ),
            if (widget.question.options.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final o in widget.question.options) ...[
                AssessmentChoiceTile(
                  option: o,
                  selected: _selected == o.value,
                  onTap: () {
                    setState(() {
                      _selected = o.value;
                      _numberCtrl.clear();
                    });
                    widget.onChanged(o.value);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        );

      case AssessmentQuestionType.text:
      case AssessmentQuestionType.date:
        return AssessmentNumberField(
          controller: _textCtrl,
          onChanged: widget.onChanged,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        );

      case AssessmentQuestionType.bmi:
        return const SizedBox.shrink();

      case AssessmentQuestionType.info:
        return Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => widget.onChanged('acknowledged'),
            child: Text(AppLocalizations.getString(context, 'common.continue')),
          ),
        );

      case AssessmentQuestionType.unknown:
        return const SizedBox.shrink();
    }
  }
}
