import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/strings.dart';

class DropDownWidget extends StatelessWidget {
  final String label;
  final dynamic selectedItem;
  final List<DropdownMenuItem<dynamic>> items;
  final Function(dynamic) onChanged;
  const DropDownWidget(
      {super.key,
      required this.label,
      required this.items,
      required this.onChanged,
      this.selectedItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 17,
              color: customBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: customGrey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButtonFormField<dynamic>(
              initialValue: selectedItem,
              hint: Text('$select $label'),
              isExpanded: true,
              decoration: const InputDecoration(border: InputBorder.none),
              validator: (value) {
                if (value == null) {
                  return 'Please select a $label';
                }
                return null;
              },
              items: items.toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
