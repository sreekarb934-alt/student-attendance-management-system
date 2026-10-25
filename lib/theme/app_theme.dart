import 'package:flutter/material.dart';

/// Central theme configuration for the Student Attendance application.
/// Provides a clean, modern blue-and-white aesthetic conforming to Material 3.
class AppTheme {
  // Primary brand palette
  static const Color primaryBlue = Color(0xFF1565C0); // Classic Blue 800
  static const Color primaryDarkBlue = Color(0xFF0D47A1); // Deep Navy Blue
  static const Color primaryLightBlue = Color(0xFFE3F2FD); // Subtle Soft Blue Tint
  static const Color secondaryBlue = Color(0xFF1976D2); // Vibrant Blue 700

  // Background and surface colors
  static const Color scaffoldBackground = Color(0xFFF8FAFC); // Modern crisp off-white (Slate 50)
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Card & panel surface
  static const Color borderLight = Color(0xFFE2E8F0); // Subtle divider & border

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Status indicator colors
  static const Color statusPresentText = Color(0xFF1B5E20); // Dark Forest Green
  static const Color statusPresentBg = Color(0xFFE8F5E9); // Light Green Tint
  static const Color statusPresentBorder = Color(0xFFA5D6A7); // Soft Green Border

  static const Color statusAbsentText = Color(0xFFB71C1C); // Deep Red
  static const Color statusAbsentBg = Color(0xFFFFEBEE); // Light Red Tint
  static const Color statusAbsentBorder = Color(0xFFEF9A9A); // Soft Red Border

  /// Returns the configured light ThemeData for the application.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      primary: primaryBlue,
      onPrimary: Colors.white,
      secondary: secondaryBlue,
      onSecondary: Colors.white,
      surface: surfaceWhite,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,

      // AppBar Theme - Polished professional blue with white text
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Card Theme - Rounded, clean border, subtle shadow
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),

      // Material 3 NavigationBar Theme (for mobile screens)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceWhite,
        indicatorColor: primaryLightBlue,
        elevation: 3,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryBlue,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBlue, size: 24);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
      ),

      // NavigationRail Theme (for desktop / wide screens)
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: surfaceWhite,
        indicatorColor: primaryLightBlue,
        selectedIconTheme: IconThemeData(color: primaryBlue),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedLabelTextStyle: TextStyle(
          color: primaryBlue,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
