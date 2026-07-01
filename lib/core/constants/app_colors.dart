import 'package:flutter/material.dart';

class AppColors {
  // Dark theme base
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color card = Color(0xFF1C1C1C);
  static const Color cardElevated = Color(0xFF252525);
  static const Color inputFill = Color(0xFF151515);

  // Accents
  static const Color accentPeach = Color(0xFFF8A491);
  static const Color accentPeachDark = Color(0xFFE8927C);
  static const Color accentPurple = Color(0xFF5E5678);
  static const Color accentPurpleMuted = Color(0xFF4A4560);
  static const Color verifiedPurple = Color(0xFF6B6585);

  // Legacy aliases used across screens
  static const Color maroon = accentPeach;
  static const Color maroonDark = Color(0xFF8B0000);
  static const Color maroonLight = accentPeachDark;

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textMuted = Color(0xFF707070);
  static const Color textOnPeach = Color(0xFF2A0808);

  // UI elements
  static const Color cardGrey = Color(0xFF2A2A2A);
  static const Color border = Color(0xFF333333);
  static const Color borderLight = Color(0xFF2A2A2A);
  static const Color chatIncoming = Color(0xFF2C2C2C);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF1B3D1F);
  static const Color impactRed = Color(0xFFE53935);
  static const Color error = Color(0xFFEF5350);

  // Deprecated light-mode aliases (mapped to dark equivalents)
  static const Color accentBlue = accentPurple;
  static const Color accentBlueLight = accentPurpleMuted;
  static const Color accentLavender = accentPurpleMuted;
  static const Color verifiedBlue = verifiedPurple;
  static const Color profileHeaderBg = Color(0xFF2A2020);
  static const Color warning = Color(0xFFF59E0B);
}
