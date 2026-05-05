import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

/// Widget filter chip divisi yang REUSABLE.
/// Cukup provide daftar divisi, nilai terpilih, dan callback onSelected.
///
/// Contoh pemakaian:
/// ```dart
/// DivisionFilterBar(
///   divisions: ['Semua', 'Musik', 'Tari', 'DKV', 'Kreatif Event'],
///   selected: controller.selectedDivision,
///   onSelected: controller.filterByDivision,
/// )
/// ```
class DivisionFilterBar extends StatelessWidget {
  final List<String> divisions;
  final RxString selected;
  final void Function(String) onSelected;

  const DivisionFilterBar({
    super.key,
    required this.divisions,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: divisions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final division = divisions[index];
          return Obx(() {
            final isSelected = selected.value == division;
            final color = _colorFor(division, context);

            return FilterChip(
              label: Text(division),
              selected: isSelected,
              onSelected: (_) => onSelected(division),
              backgroundColor: color.withOpacity(0.06),
              selectedColor: color.withOpacity(0.15),
              checkmarkColor: color,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: isSelected
                    ? color.withOpacity(0.4)
                    : Colors.transparent,
              ),
              labelStyle: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            );
          });
        },
      ),
    );
  }

  Color _colorFor(String division, BuildContext context) {
    if (division == 'Semua') {
      return AppColors.secondary;
    }
    return AppColors.getDivisionColor(division);
  }
}
