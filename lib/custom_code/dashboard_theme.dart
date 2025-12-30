import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardTheme {
  // Color Palette
  static const Color primary = Color(0xFF18651C);
  static const Color secondary = Color(0xFF6B7280);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  // Typography
  static TextStyle get pageTitle => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      );

  static TextStyle get sectionHeader => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get bodyText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.4,
      );

  static TextStyle get inputText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.5,
      );

  // Shadows
  static List<BoxShadow> get mainShadow => [
        BoxShadow(
          color: const Color(0x0A000000),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0x0A000000),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get inputShadow => [
        BoxShadow(
          color: const Color(0x0A000000),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  // Decorations
  static BoxDecoration get mainContainerDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: mainShadow,
      );

  static BoxDecoration get headerDecoration => BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: mainShadow,
      );

  static BoxDecoration get searchBarDecoration => BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 2),
        boxShadow: cardShadow,
      );

  static BoxDecoration get datePickerDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
        boxShadow: inputShadow,
      );

  static BoxDecoration get clearButtonDecoration => BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      );

  static BoxDecoration get actionButtonDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // Spacing
  static const double containerPadding = 32.0;
  static const double sectionSpacing = 24.0;
  static const double elementSpacing = 16.0;
  static const double inputPadding = 20.0;

  // Border Radius
  static const double mainRadius = 24.0;
  static const double cardRadius = 16.0;
  static const double inputRadius = 12.0;
}

