import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_card.dart';

class CategoryHeaderIcon extends StatelessWidget {
  final CategoryStyle style;
  final double size;

  const CategoryHeaderIcon({super.key, required this.style, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return FaIcon(
      style.icon,
      size: size,
      color: style.color.withValues(alpha: 0.5),
    );
  }
}
