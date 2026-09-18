// lib/features/auth/presentation/widgets/us_state_dropdown.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wellness/common/constants/us_states.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';

class UsStateDropdown extends StatelessWidget {
  final UsState? selectedState;
  final ValueChanged<UsState?> onChanged;
  final bool isEnabled;
  final String? errorText;

  const UsStateDropdown({
    super.key,
    required this.selectedState,
    required this.onChanged,
    this.isEnabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final items = UsStates.all.map((state) {
      return DropdownMenuItem<UsState>(
        value: state,
        child: Text('${state.name} (${state.code})'),
      );
    }).toList();

    return DropDownWidget<UsState>(
      label: AppLocalizations.getString(context, 'auth.state'),
      selectedItem: selectedState,
      items: items,
      onChanged: isEnabled ? onChanged : null,
      errorText: errorText,
      isRequired: true,
      isDense: true,
      borderColor: Colors.grey[300],
      padding: EdgeInsets.zero,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FaIcon(
          FontAwesomeIcons.locationDot,
          size: 16,
          color: Colors.grey[500],
        ),
      ),
      validator: (value) {
        if (value == null) {
          return AppLocalizations.getString(context, 'validation.required');
        }
        return null;
      },
    );
  }
}
