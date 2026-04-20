import 'package:flutter/material.dart';

class AppColors {
  // warna primer dan skunder
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  static const Color secondary = Color(0xFFF59E0B); // Amber
  static const Color secondaryLight = Color(0xFFFBBF24);
  static const Color secondaryDark = Color(0xFFD97706);

  // warna aksen
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);

  // warna background
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);

  // warna teks
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // warna status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Divider
  static const Color divider = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);

  // warna divisi
  static const Color divisionMusik = Color(0xFF6366F1);
  static const Color divisionTari = Color(0xFFEC4899);
  static const Color divisionDKV = Color(0xFF14B8A6);
  static const Color divisionKreatifEvent = Color(0xFFF97316);

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
}
