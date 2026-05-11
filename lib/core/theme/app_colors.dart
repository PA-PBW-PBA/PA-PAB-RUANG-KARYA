import 'package:flutter/material.dart';

class AppColors {
  // === PRIMARY — Violet/Purple (tetap sebagai brand utama) ===
  static const Color primary = Color(0xFF7C3AED);       // Vivid violet
  static const Color primaryLight = Color(0xFFA78BFA);  // Soft violet
  static const Color primaryDark = Color(0xFF5B21B6);   // Deep violet

  // === SECONDARY — Coral/Pink cerah ===
  static const Color secondary = Color(0xFFEC4899);     // Hot pink
  static const Color secondaryLight = Color(0xFFF9A8D4); // Soft pink
  static const Color secondaryDark = Color(0xFFBE185D);  // Deep pink

  // === ACCENT WARNA-WARNI ===
  static const Color accentPink = Color(0xFFEC4899);     // Pink
  static const Color accentLavender = Color(0xFFA78BFA); // Lavender
  static const Color accentPurple = Color(0xFF7C3AED);   // Purple
  static const Color accentOrange = Color(0xFFF97316);   // Orange
  static const Color accentCoral = Color(0xFFFF6B6B);    // Coral
  static const Color accentTeal = Color(0xFF14B8A6);     // Teal/Mint
  static const Color accentBlue = Color(0xFF3B82F6);     // Blue
  static const Color accentYellow = Color(0xFFFFD700);   // Yellow
  static const Color accentGreen = Color(0xFF22C55E);    // Green
  static const Color accentRed = Color(0xFFEF4444);      // Red
  static const Color accentNeonBlue = Color(0xFF06B6D4); // Cyan

  // === BACKGROUND — Putih bersih, blob yang warna-warni ===
  static const Color background = Color(0xFFFFFBFF);    // Near white, hint warm
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceNavy = Color(0xFF1E1B4B);

  // === BLOB DECORATIONS — Colorful pastel blobs ===
  static const Color bgBlob1 = Color(0xFFC4B5FD);   // Lavender violet
  static const Color bgBlob2 = Color(0xFFFDA4AF);   // Soft coral/rose
  static const Color bgBlob3 = Color(0xFF6EE7B7);   // Mint green
  static const Color bgBlob4 = Color(0xFF93C5FD);   // Sky blue
  static const Color bgBlob5 = Color(0xFFFDE68A);   // Soft yellow

  // === TEXT ===
  static const Color textPrimary = Color(0xFF1E1B2E);   // Deep dark
  static const Color textSecondary = Color(0xFF6B7280); // Grey
  static const Color textWhite = Color(0xFFFFFFFF);

  // === STATUS ===
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // === DIVIDER ===
  static const Color divider = Color(0xFFF3F4F6);

  // === WARNA DIVISI — colorful ===
  static const Color divisionMusik = Color(0xFF7C3AED);   // Violet
  static const Color divisionTari = Color(0xFFEC4899);    // Pink
  static const Color divisionDKV = Color(0xFF3B82F6);     // Blue
  static const Color divisionKreatifEvent = Color(0xFFF97316); // Orange

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
        return primary;
    }
  }

  static Color getDivisionSurface(String division) {
    final color = getDivisionColor(division);
    return color.withOpacity(0.1);
  }
}
