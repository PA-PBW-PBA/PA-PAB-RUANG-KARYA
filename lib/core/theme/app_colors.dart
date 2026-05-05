import 'package:flutter/material.dart';

class AppColors {
  // === WARNA PRIMER — dari logo, versi pastel soft ===
  static const Color primary = Color(0xFFE8C840); // Butter Yellow (logo kuning)
  static const Color primaryLight = Color(0xFFF2D96A);
  static const Color primaryDark = Color(0xFFC8A820);

  // === WARNA SEKUNDER — Teal/Cyan dari logo ===
  static const Color secondary = Color(0xFF72C8C8); // Soft Teal (logo cyan)
  static const Color secondaryLight = Color(0xFF96D8D8);
  static const Color secondaryDark = Color(0xFF4AABAB);

  // === AKSEN — dari logo lainnya ===
  static const Color accentMagenta =
      Color(0xFFE87090); // Soft Magenta-Pink (logo merah)
  static const Color accentLime =
      Color(0xFFB0CC50); // Soft Lime Green (logo hijau)
  static const Color accentYellow = Color(0xFFEDD870); // Light Butter
  static const Color accentTeal = Color(0xFF80D0D0); // Light Teal

  // === ALIAS KOMPATIBILITAS — nama lama tetap bisa dipakai ===
  static const Color accentGreen = Color(0xFF80CC80); // alias → success
  static const Color accentRed = Color(0xFFE87090); // alias → danger
  static const Color accentBlue = Color(0xFF72C8C8); // alias → secondary
  static const Color accentPurple = Color(0xFFE87090); // alias → accentMagenta
  static const Color accentOrange = Color(0xFFEDD870); // alias → accentYellow

  // === BACKGROUND ===
  static const Color background = Color(0xFFF8F7F2); // Warm Cream White
  static const Color surface = Color(0xFFFFFFFF);

  // === SURFACE TINT ===
  static const Color surfaceYellow = Color(0xFFFFFAE0);
  static const Color surfaceTeal = Color(0xFFE8F8F8);
  static const Color surfaceMagenta = Color(0xFFFFEEF2);
  static const Color surfaceLime = Color(0xFFF4FADC);

  // === TEKS ===
  static const Color textPrimary = Color(0xFF222218);
  static const Color textSecondary = Color(0xFF8A8870);

  // === STATUS ===
  static const Color success = Color(0xFF80CC80);
  static const Color warning = Color(0xFFE8C840);
  static const Color danger = Color(0xFFE87090);
  static const Color info = Color(0xFF72C8C8);

  // === DIVIDER ===
  static const Color divider = Color(0xFFEAE8DC);

  // === WARNA DIVISI ===
  static const Color divisionMusik = Color(0xFF72C8C8);
  static const Color divisionTari = Color(0xFFE87090);
  static const Color divisionDKV = Color(0xFFB0CC50);
  static const Color divisionKreatifEvent = Color(0xFFE8C840);

  static Color getDivisionColor(String division) {
    switch (division) {
      case 'Musik':
        return divisionMusik;
      case 'Tari':
        return divisionTari;
      case 'DKV':
        return divisionDKV;
      case 'Kreatif Event':
        return divisionKreatifEvent;
      default:
        return secondary;
    }
  }

  static Color getDivisionSurface(String division) {
    switch (division) {
      case 'Musik':
        return surfaceTeal;
      case 'Tari':
        return surfaceMagenta;
      case 'DKV':
        return surfaceLime;
      case 'Kreatif Event':
        return surfaceYellow;
      default:
        return surfaceTeal;
    }
  }
}
