// lib/features/auth/presentation/widgets/profile_type_dropdown.dart

import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';

enum ProfileType {
  client,
  communityAlly;

  String get displayName {
    switch (this) {
      case ProfileType.client:
        return 'Client';
      case ProfileType.communityAlly:
        return 'Community Ally';
    }
  }

  String get apiValue {
    switch (this) {
      case ProfileType.client:
        return 'client';
      case ProfileType.communityAlly:
        return 'community_ally';
    }
  }

  static ProfileType fromApiValue(String value) {
    switch (value) {
      case 'client':
        return ProfileType.client;
      case 'community_ally':
        return ProfileType.communityAlly;
      default:
        throw ArgumentError('Invalid profile type: $value');
    }
  }
}

/// Dropdown for selecting profile type
class ProfileTypeDropdown extends StatelessWidget {
  final ProfileType? selectedType;
  final ValueChanged<ProfileType?> onChanged;
  final bool isEnabled;
  final String? errorText;

  const ProfileTypeDropdown({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.isEnabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final items = ProfileType.values.map((type) {
      return DropdownMenuItem<ProfileType>(
        value: type,
        child: Text(type.displayName),
      );
    }).toList();

    return DropDownWidget<ProfileType>(
      label: AppLocalizations.getString(context, 'auth.profileType'),
      selectedItem: selectedType,
      items: items,
      onChanged: isEnabled ? onChanged : null,
      errorText: errorText,
      isRequired: true,
      prefixIcon: const Icon(Icons.badge_outlined),
      validator: (value) {
        if (value == null) {
          return AppLocalizations.getString(context, 'validation.required');
        }
        return null;
      },
    );
  }
}
