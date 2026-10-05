// =============================================================================
// FILE: lib/core/theme/text_styles.dart
// RESPONSIBILITY: Mendefinisikan semua TextStyle yang digunakan secara
// konsisten di seluruh aplikasi Go Ticket. Menggunakan Google Fonts Inter
// sebagai font utama. TextStyle diorganisir berdasarkan:
// - Display: Heading sangat besar (splash, hero section)
// - Headline: Heading halaman / section utama
// - Title: Judul card / list item
// - Body: Konten teks utama
// - Label: Label, tombol, badge, tag
// - Caption: Teks kecil / footnote
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Koleksi TextStyle yang dapat digunakan kembali (reusable) di seluruh app.
///
/// Contoh penggunaan:
/// ```dart
/// Text('Go Ticket', style: AppTextStyles.displayLarge)
/// Text('Pilih Kamar', style: AppTextStyles.headlineMedium)
/// ```
class AppTextStyles {
  AppTextStyles._();

  // ---------------------------------------------------------------------------
  // DISPLAY — Sangat besar, untuk splash screen atau hero section
  // ---------------------------------------------------------------------------

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        color: AppColors.textPrimaryLight,
        height: 1.1,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimaryLight,
        height: 1.2,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
        height: 1.2,
      );

  // ---------------------------------------------------------------------------
  // HEADLINE — Heading halaman atau section utama
  // ---------------------------------------------------------------------------

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
        height: 1.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
        height: 1.3,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
        height: 1.4,
      );

  // ---------------------------------------------------------------------------
  // TITLE — Judul card, list item, dialog
  // ---------------------------------------------------------------------------

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
        height: 1.4,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
        height: 1.4,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
        height: 1.4,
      );

  // ---------------------------------------------------------------------------
  // BODY — Konten teks utama
  // ---------------------------------------------------------------------------

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryLight,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryLight,
        height: 1.6,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondaryLight,
        height: 1.5,
      );

  // ---------------------------------------------------------------------------
  // LABEL — Tombol, badge, tag, form label
  // ---------------------------------------------------------------------------

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textSecondaryLight,
      );

  // ---------------------------------------------------------------------------
  // CAPTION — Teks kecil, footnote, timestamp
  // ---------------------------------------------------------------------------

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondaryLight,
        height: 1.4,
      );

  static TextStyle get captionBold => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryLight,
      );

  // ---------------------------------------------------------------------------
  // PRICE / CURRENCY — Untuk menampilkan harga (bold + warna accent)
  // ---------------------------------------------------------------------------

  static TextStyle get priceLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        height: 1.2,
      );

  static TextStyle get priceMedium => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get priceSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get priceStrikethrough => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
        decoration: TextDecoration.lineThrough,
      );

  // ---------------------------------------------------------------------------
  // HELPER METHODS — Modifikasi style
  // ---------------------------------------------------------------------------

  /// Mengubah warna TextStyle
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Menambahkan warna putih pada style (mode gelap)
  static TextStyle forDark(TextStyle style) {
    return style.copyWith(color: AppColors.textPrimaryDark);
  }

  /// TextStyle untuk secondary text (mode terang)
  static TextStyle secondary(TextStyle style) {
    return style.copyWith(color: AppColors.textSecondaryLight);
  }
}
