import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary
  static const Color primary = Color(0xFF00B5C8);
  static const Color primaryDark = Color(0xFF00CDE3);
  static const Color secondary = Color(0xFFF5C500);
  static const Color secondaryDark = Color(0xFFFFD600);

  // Accent
  static const Color accentRed = Color(0xFFD91E4A);
  static const Color accentRedDark = Color(0xFFF24E72);
  static const Color accentGreen = Color(0xFF8DB800);
  static const Color accentGreenDark = Color(0xFFA3D400);

  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0A1A1C);

  // Surface
  static const Color surface = Color(0xFFF0FAFB);
  static const Color surfaceDark = Color(0xFF0F2628);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Divider
  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF1E3A3D);

  // Division colors (static, never change)
  static const Color divisionMusik = Color(0xFF3B82F6);
  static const Color divisionTari = Color(0xFFEC4899);
  static const Color divisionDKV = Color(0xFF10B981);
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
