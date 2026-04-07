import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DivisionBadge extends StatelessWidget {
  final String division;
  final double fontSize;

  const DivisionBadge({
    super.key,
    required this.division,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getDivisionColor(division);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        division,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
