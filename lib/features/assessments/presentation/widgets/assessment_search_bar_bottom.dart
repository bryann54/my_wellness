import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/app_search_bar.dart';

class AssessmentSearchBarBottom extends StatelessWidget
    implements PreferredSizeWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const AssessmentSearchBarBottom({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: AppSearchBar(
        controller: controller,
        hintText: hintText,
        onChanged: onChanged,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
