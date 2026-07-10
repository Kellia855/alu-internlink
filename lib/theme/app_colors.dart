import 'package:flutter/material.dart';

/// InternLink brand color palette.
/// Keep every color in the app sourced from here so the palette
/// stays consistent across screens.
class AppColors {
  AppColors._();

  static const Color maroon = Color(0xFF8F0F07); // primary brand / CTAs
  static const Color navy = Color(0xFF000767); // deep accents, headers
  static const Color rust = Color(0xFFB22B1D); // secondary accent, alerts
  static const Color white = Color(0xFFFFFFFF);
  static const Color blue = Color(0xFF27308A); // links, info, student theme
  static const Color charcoal = Color(0xFF1B1C1C); // primary text
  static const Color grey = Color(0xFFA8A6A6); // secondary text, borders
  static const Color lightGrey = Color(0xFFC8C6C6); // backgrounds, dividers

  // Semantic aliases
  static const Color primary = maroon;
  static const Color secondary = blue;
  static const Color accent = rust;
  static const Color background = white;
  static const Color surface = white;
  static const Color textPrimary = charcoal;
  static const Color textSecondary = grey;
  static const Color divider = lightGrey;

  static const Color success = Color(0xFF2E7D32);
  static const Color pending = Color(0xFFB8860B);
  static const Color rejected = rust;

  static const LinearGradient headerGradient = LinearGradient(
    colors: [navy, blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// The "hero card" gradient — used for the Recommended opportunity card,
  /// standing in for the purple/pink gradient in the reference design.
  static const LinearGradient heroGradient = LinearGradient(
    colors: [maroon, rust],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
        return success;
      case 'rejected':
      case 'declined':
        return rejected;
      case 'pending':
      default:
        return pending;
    }
  }
}
