import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberTheme {
  // Primary Palette
  static const Color navy = Color(0xFF0B1E3D);
  static const Color navyMid = Color(0xFF0D2347);
  static const Color navyDark = Color(0xFF061329);
  static const Color navyLight = Color(0xFF132F5C);
  
  // Accents
  static const Color cyan = Color(0xFF00C8FF);
  static const Color cyanDim = Color(0xFF0891B2);
  static const Color cyanGlow = Color(0x3300C8FF);
  
  // Status Colors
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color purple = Color(0xFF7C3AED);
  static const Color teal = Color(0xFF0D9488);
  
  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color slate = Color(0xFF334155);
  static const Color slateLight = Color(0xFF64748B);
  static const Color grayBorder = Color(0xFF1E293B);
  static const Color grayLt = Color(0xFFCBD5E1);
  static const Color offWhite = Color(0xFFF0F4F8);
  static const Color cardDark = Color(0xFF0E2448);
  static const Color cardBorder = Color(0x2400C8FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cyan, Color(0xFF0099FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF0D2347), Color(0xFF091A36)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: navyDark,
      primaryColor: cyan,
      canvasColor: navyMid,
      cardColor: cardDark,
      dividerColor: grayBorder,
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: cyanDim,
        surface: navyMid,
        error: danger,
        onPrimary: navyDark,
        onSurface: white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: white,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: white,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: grayLt,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: slateLight,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: navy.withOpacity(0.95),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: navyLight.withOpacity(0.5),
        hintStyle: GoogleFonts.inter(color: slateLight, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: cyan, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: navyDark,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
    );
  }
}
