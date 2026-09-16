// common/widgets/app_button.dart
import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 50,
        width: fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: onTap != null ? colorPrimary : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: onTap != null ? Colors.white : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
