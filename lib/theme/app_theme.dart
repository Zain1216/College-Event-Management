import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Brand Palette: Sapphire Blue & Deep Tech Navy (STRICTLY NO PURPLE)
  static const Color primary = Color(0xFF2563EB); // Sapphire Blue
  static const Color primaryDark = Color(0xFF1D4ED8); // Deep Sapphire
  static const Color primaryLight = Color(0xFF60A5FA); // Sky Accent
  static const Color primaryContainer = Color(0xFFDBEAFE); // Soft Ice Blue
  static const Color deepNavy = Color(0xFF0F172A); // Midnight Tech Navy

  // Secondary / Fiesta Accent: Electric Cyan & Aqua Teal
  static const Color secondary = Color(0xFF06B6D4); // Electric Cyan
  static const Color secondaryDark = Color(0xFF0891B2); // Deep Cyan
  static const Color secondaryLight = Color(0xFF67E8F9); // Light Aqua
  static const Color secondaryContainer = Color(0xFFCFFAFE); // Ice Cyan

  // Highlight / Medal / Achievement: Amber Gold & Sunset Orange
  static const Color accentGold = Color(0xFFF59E0B); // Amber Gold
  static const Color accentOrange = Color(0xFFF97316); // Sunburst Orange

  // Real-time Status Colors
  static const Color statusLive = Color(0xFF10B981); // Emerald Green
  static const Color statusUpcoming = Color(0xFF0284C7); // Cerulean Sky
  static const Color statusPending = Color(0xFFF59E0B); // Amber Warning
  static const Color statusCompleted = Color(0xFF64748B); // Slate Gray
  static const Color statusCancelled = Color(0xFFEF4444); // Crimson Red
  static const Color error = Color(0xFFDC2626); // Alert Red

  // Neutral Canvas & Surfaces - Light Mode
  static const Color backgroundLight = Color(0xFFF1F5F9); // Sleek subtle frosted backdrop
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A); // Midnight Slate
  static const Color textSecondaryLight = Color(0xFF475569); // Slate Muted
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Neutral Canvas & Surfaces - Dark Mode
  static const Color backgroundDark = Color(0xFF070D1E); // Midnight Navy Space
  static const Color surfaceDark = Color(0xFF0F172A); // Navy Slate
  static const Color cardDark = Color(0xFF1E293B); // Deep Card Surface
  static const Color borderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textMutedDark = Color(0xFF64748B);

  // --- GLASSMORPHISM PALETTE & AMBIENT GLOWS ---
  static final Color glassFillLight = Colors.white.withOpacity(0.68);
  static final Color glassFillLightSubtle = Colors.white.withOpacity(0.45);
  static final Color glassFillLightStrong = Colors.white.withOpacity(0.85);

  static final Color glassFillDark = const Color(0xFF0F172A).withOpacity(0.65);
  static final Color glassFillDarkSubtle = const Color(0xFF1E293B).withOpacity(0.40);
  static final Color glassFillDarkStrong = const Color(0xFF1E293B).withOpacity(0.85);

  static final Color glassBorderLight = Colors.white.withOpacity(0.65);
  static final Color glassBorderLightSubtle = Colors.white.withOpacity(0.35);
  static final Color glassBorderDark = Colors.white.withOpacity(0.16);

  // Glowing Ambient Accents
  static final Color glowCyan = const Color(0xFF06B6D4).withOpacity(0.35);
  static final Color glowBlue = const Color(0xFF2563EB).withOpacity(0.35);
  static final Color glowGold = const Color(0xFFF59E0B).withOpacity(0.35);
  static final Color glowEmerald = const Color(0xFF10B981).withOpacity(0.35);

  // Gradients (Blue -> Cyan / Emerald)
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1D4ED8), Color(0xFF0284C7), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient electricCyanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient liveGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Specular Shimmer Gradient
  static final LinearGradient glassShimmerGradient = LinearGradient(
    colors: [
      Colors.white.withOpacity(0.35),
      Colors.white.withOpacity(0.10),
      Colors.white.withOpacity(0.02),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient glassBorderGradientLight = LinearGradient(
    colors: [
      Colors.white.withOpacity(0.85),
      Colors.white.withOpacity(0.30),
      const Color(0xFF06B6D4).withOpacity(0.40),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryContainer,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight),
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
        headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
        titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFCBD5E1),
          disabledForegroundColor: const Color(0xFF94A3B8),
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.35),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimaryLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(color: AppColors.textMutedLight, fontSize: 13),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.7),
        selectedColor: AppColors.primaryContainer,
        side: BorderSide(color: Colors.white.withOpacity(0.8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseDark = ThemeData.dark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.backgroundDark,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(baseDark.textTheme).apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark),
        headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.backgroundDark,
          disabledBackgroundColor: const Color(0xFF334155),
          disabledForegroundColor: const Color(0xFF64748B),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.backgroundDark,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.backgroundDark,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
