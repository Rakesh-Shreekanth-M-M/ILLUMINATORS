import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ── Display ──────────────────────────────────────
  static TextStyle display = GoogleFonts.rajdhani(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 2.0,
  );

  static TextStyle displaySmall = GoogleFonts.rajdhani(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1.5,
  );

  // ── Headlines ─────────────────────────────────────
  static TextStyle h1 = GoogleFonts.rajdhani(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1.0,
  );

  static TextStyle h2 = GoogleFonts.rajdhani(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.8,
  );

  static TextStyle h3 = GoogleFonts.rajdhani(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  // ── Body ──────────────────────────────────────────
  static TextStyle body = GoogleFonts.rajdhani(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static TextStyle bodySmall = GoogleFonts.rajdhani(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecond,
    letterSpacing: 0.2,
  );

  // ── Labels & Badges ───────────────────────────────
  static TextStyle label = GoogleFonts.rajdhani(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecond,
    letterSpacing: 1.5,
  );

  static TextStyle badge = GoogleFonts.rajdhani(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 2.0,
  );

  static TextStyle button = GoogleFonts.rajdhani(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: 2.0,
  );

  static TextStyle caption = GoogleFonts.rajdhani(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textDim,
    letterSpacing: 0.5,
  );

  static TextStyle mono = GoogleFonts.sourceCodePro(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
    letterSpacing: 1.5,
  );
}
