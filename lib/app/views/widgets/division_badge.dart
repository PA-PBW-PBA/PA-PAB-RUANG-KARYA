import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Badge divisi normal — tetap dipakai di profil, detail, dll.
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.24),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
      ),
      child: Text(
        division.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Chip kompak huruf singkatan — dipakai di kartu anggota & event card
/// agar tidak overflow saat ada banyak divisi.
class DivisionChipRow extends StatelessWidget {
  final List<String> divisions;

  /// Maks chip yang ditampilkan sebelum "+N" muncul
  final int maxVisible;

  /// Ukuran chip (diameter)
  final double size;

  const DivisionChipRow({
    super.key,
    required this.divisions,
    this.maxVisible = 3,
    this.size = 24,
  });

  /// Ambil singkatan 1 huruf dari nama divisi
  static String _abbrev(String division) {
    final words = division.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return words.map((w) => w[0].toUpperCase()).take(2).join();
    }
    return division[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (divisions.isEmpty) return const SizedBox.shrink();

    final visible = divisions.take(maxVisible).toList();
    final overflow = divisions.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...visible.map((d) {
          final color = AppColors.getDivisionColor(d);
          return Tooltip(
            message: d,
            child: Container(
              width: size,
              height: size,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                _abbrev(d),
                style: TextStyle(
                  color: color,
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        }),
        if (overflow > 0)
          Tooltip(
            message: divisions.skip(maxVisible).join(', '),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.1), width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                '+$overflow',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: size * 0.34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

