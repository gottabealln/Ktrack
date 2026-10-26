import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Gradient stops
  static const g1 = Color(0xFF6A11CB);
  static const g2 = Color(0xFF2575FC);
  static const g3 = Color(0xFFFF6B9D);
  static const g4 = Color(0xFFFFB86C);
  static const g5 = Color(0xFF00C9A7);

  // Base background
  static const bg = Color(0xFF0B0F1E);
  static const bg2 = Color(0xFF141A33);

  // Surfaces (translucent glass)
  static const surface = Color(0x33FFFFFF);
  static const surfaceStrong = Color(0x55FFFFFF);
  static const border = Color(0x44FFFFFF);

  // Text
  static const text = Color(0xFFF5F7FF);
  static const textDim = Color(0xFFB8C0E0);

  // Status
  static const success = Color(0xFF4ADE80);
  static const warn = Color(0xFFFACC15);
  static const danger = Color(0xFFFF4D6D);
  static const accent = Color(0xFFFF6B9D);
}

class AppGradients {
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.g1, AppColors.g2],
  );

  static const warm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.g3, AppColors.g4],
  );

  static const calm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.g2, AppColors.g5],
  );

  static const danger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4D6D), Color(0xFFFF6B9D)],
  );

  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B0F1E), Color(0xFF1B1442), Color(0xFF0B0F1E)],
  );
}

class AppText {
  static TextStyle h1 = GoogleFonts.poppins(
    color: AppColors.text,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    color: AppColors.text,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static TextStyle h3 = GoogleFonts.poppins(
    color: AppColors.text,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle body = GoogleFonts.poppins(
    color: AppColors.text,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle small = GoogleFonts.poppins(
    color: AppColors.textDim,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle button = GoogleFonts.poppins(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}

class AppDecorations {
  static BoxDecoration glassCard({
    Gradient? gradient,
    double radius = 22,
    double opacity = 0.08,
  }) {
    return BoxDecoration(
      gradient: gradient,
      color: gradient == null ? Colors.white.withOpacity(opacity) : null,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}