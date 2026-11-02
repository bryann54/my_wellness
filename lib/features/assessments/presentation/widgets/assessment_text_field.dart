import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';

class AssessmentTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final ValueChanged<String>? onChanged;

  const AssessmentTextField({
    super.key,
    required this.controller,
    this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SoftInput(
      controller: controller,
      hint: hint,
      keyboardType: TextInputType.text,
      onChanged: onChanged,
    );
  }
}
