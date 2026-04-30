import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color dividerColor = Color(0xFFE5E7EB);
  static const Color surfaceColor = Color(0xFFF3F4F6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: cardColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -1,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          height: 1.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:
              BorderSide(color: dividerColor.withValues(alpha: 0.5), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return primaryColor.withValues(alpha: 0.5);
              }
              return primaryColor;
            },
          ),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevation: WidgetStateProperty.resolveWith<double>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return 0;
              }
              if (states.contains(WidgetState.hovered)) {
                return 4;
              }
              return 2;
            },
          ),
          shadowColor: WidgetStateProperty.all(
            primaryColor.withValues(alpha: 0.3),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
              color: primaryColor.withValues(alpha: 0.3), width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerColor.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerColor.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary.withValues(alpha: 0.6),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  static Color getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'urgentă':
      case 'high':
        return errorColor;
      case 'medie':
      case 'medium':
        return warningColor;
      case 'normală':
      case 'scăzută':
      case 'low':
        return secondaryColor;
      default:
        return textSecondary;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'deschisă':
      case 'open':
        return primaryColor;
      case 'acceptată':
      case 'accepted':
        return warningColor;
      case 'în desfășurare':
      case 'in progress':
      case 'inprogress':
        return const Color(0xFF9B59B6);
      case 'finalizată':
      case 'completed':
        return secondaryColor;
      case 'anulată':
      case 'cancelled':
        return textSecondary;
      default:
        return textSecondary;
    }
  }
}
