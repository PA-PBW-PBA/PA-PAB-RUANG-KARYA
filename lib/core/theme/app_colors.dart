import 'package:flutter/material.dart';

class AppColors {
  // === BRAND COLORS ===
  static const Color primary = Color(0xFF1E293B); 
  static const Color primaryLight = Color(0xFF334155);
  static const Color primaryDark = Color(0xFF0F172A);

  static const Color secondary = Color(0xFF00BFFF); 
  static const Color secondaryLight = Color(0xFF70E1FF);
  static const Color secondaryDark = Color(0xFF0091C2);

  // === VIBRANT ACCENTS (Youthful & Creative) ===
  static const Color accentYellow = Color(0xFFFFD700); 
  static const Color accentPink = Color(0xFFFF2D55); 
  static const Color accentPurple = Color(0xFF8B5CF6); 
  static const Color accentOrange = Color(0xFFF97316); 
  static const Color accentNeonBlue = Color(0xFF00F2FF); 
  static const Color accentGreen = Color.fromARGB(255, 10, 227, 29); 
  static const Color accentRed = Color.fromARGB(255, 227, 10, 10); 
  
  // === BACKGROUND & SURFACE ===
  static const Color background = Color(0xFFFFFFFF); 
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceNavy = Color(0xFF1E293B); 

  // === TEKS ===
  static const Color textPrimary = Color(0xFF0F172A); 
  static const Color textSecondary = Color(0xFF64748B); 
  static const Color textWhite = Color(0xFFFFFFFF);

  // === STATUS ===
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // === DIVIDER ===
  static const Color divider = Color(0xFFF1F5F9);

  // === WARNA DIVISI (Creative Palette) ===
  static const Color divisionMusik = Color(0xFF8B5CF6); 
  static const Color divisionTari = Color(0xFFFF2D55); 
  static const Color divisionDKV = Color(0xFF00BFFF); 
  static const Color divisionKreatifEvent = Color(0xFFFFD700); 

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
    final color = getDivisionColor(division);
    return color.withOpacity(0.1);
  }
}
