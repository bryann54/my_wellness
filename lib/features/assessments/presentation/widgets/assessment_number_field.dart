import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';

class AssessmentNumberField extends StatelessWidget {
  final TextEditingController controller;
  final int? min;
  final int? max;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const AssessmentNumberField({
    super.key,
    required this.controller,
    this.min,
    this.max,
    this.hint,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SoftInput(
      controller: controller,
      hint: hint,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      // onChanged: onChanged,
      validator:
          validator ??
          (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            final n = int.tryParse(v.trim());
            if (n == null) return 'Numbers only';
            if (min != null && n < min!) return 'Minimum $min';
            if (max != null && n > max!) return 'Maximum $max';
            return null;
          },
    );
  }
}
