// =============================================================================
// FILE: lib/core/constants/app_colors.dart
// RESPONSIBILITY: Mendefinisikan semua konstanta warna utama yang digunakan
// di seluruh aplikasi Go Ticket. Warna dibagi berdasarkan konteks:
// - Brand colors (warna utama Go Ticket)
// - Semantic colors (success, error, warning, info)
// - Neutral colors (teks, background, border)
// - Warna per-aplikasi (Customer, Hotel Partner, Super Admin)
// =============================================================================

import 'package:flutter/material.dart';

class AppColors {
  // ---------------------------------------------------------------------------
  // PRIVATE CONSTRUCTOR — Kelas ini tidak boleh diinstansiasi
  // ---------------------------------------------------------------------------
  AppColors._();

  // ---------------------------------------------------------------------------
  // BRAND COLORS — Warna utama Go Ticket
  // ---------------------------------------------------------------------------

  /// Warna primer utama Go Ticket (biru indigo elegan)
  static const Color primary = Color(0xFF3D5AF1);

  /// Warna primer yang lebih gelap untuk hover/pressed state
  static const Color primaryDark = Color(0xFF2A3FBF);

  /// Warna primer yang lebih terang untuk accent/highlight
  static const Color primaryLight = Color(0xFF7B8FF7);

  /// Warna sekunder Go Ticket (oranye hangat)
  static const Color secondary = Color(0xFFFF6B35);

  /// Warna sekunder lebih gelap
  static const Color secondaryDark = Color(0xFFCC4F1F);

  /// Warna sekunder lebih terang
  static const Color secondaryLight = Color(0xFFFF9A72);

  /// Warna aksen emas (untuk badge premium/VIP)
  static const Color accent = Color(0xFFFFD700);

  // ---------------------------------------------------------------------------
  // SEMANTIC COLORS — Warna untuk status dan pesan
  // ---------------------------------------------------------------------------

  /// Warna sukses / berhasil
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);

  /// Warna error / gagal
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  /// Warna peringatan / warning
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  /// Warna informasi
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEFF6FF);

  // ---------------------------------------------------------------------------
  // NEUTRAL COLORS — Warna abu-abu dan teks
  // ---------------------------------------------------------------------------

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ---------------------------------------------------------------------------
  // BACKGROUND COLORS
  // ---------------------------------------------------------------------------

  /// Background utama mode terang
  static const Color backgroundLight = Color(0xFFF9FAFB);

  /// Background utama mode gelap
  static const Color backgroundDark = Color(0xFF0F172A);

  /// Background card mode terang
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Background card mode gelap
  static const Color cardDark = Color(0xFF1E293B);

  /// Background surface sekunder mode gelap
  static const Color surfaceDark = Color(0xFF334155);

  // ---------------------------------------------------------------------------
  // TEXT COLORS
  // ---------------------------------------------------------------------------

  /// Teks utama mode terang
  static const Color textPrimaryLight = Color(0xFF111827);

  /// Teks sekunder mode terang
  static const Color textSecondaryLight = Color(0xFF6B7280);

  /// Teks utama mode gelap
  static const Color textPrimaryDark = Color(0xFFF1F5F9);

  /// Teks sekunder mode gelap
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  /// Teks placeholder / hint
  static const Color textHint = Color(0xFF9CA3AF);

  // ---------------------------------------------------------------------------
  // BOOKING STATUS COLORS — Warna untuk status pemesanan
  // ---------------------------------------------------------------------------

  /// Status: Menunggu pembayaran
  static const Color statusPending = Color(0xFFF59E0B);

  /// Status: Terkonfirmasi / Lunas
  static const Color statusConfirmed = Color(0xFF22C55E);

  /// Status: Checked-in / Kamar terisi
  static const Color statusOccupied = Color(0xFF3B82F6);

  /// Status: Check-out / Selesai
  static const Color statusCheckedOut = Color(0xFF6B7280);

  /// Status: Dibatalkan
  static const Color statusCancelled = Color(0xFFEF4444);

  // ---------------------------------------------------------------------------
  // ROOM STATUS COLORS — Warna untuk status kamar (Hotel Partner)
  // ---------------------------------------------------------------------------

  /// Kamar siap / available
  static const Color roomAvailable = Color(0xFF22C55E);

  /// Kamar terisi / occupied
  static const Color roomOccupied = Color(0xFF3B82F6);

  /// Kamar kotor / perlu dibersihkan
  static const Color roomDirty = Color(0xFFEF4444);

  /// Kamar sedang dibersihkan
  static const Color roomCleaning = Color(0xFFF59E0B);

  /// Kamar dalam maintenance
  static const Color roomMaintenance = Color(0xFF8B5CF6);

  // ---------------------------------------------------------------------------
  // GRADIENT DEFINITIONS — Untuk header dan decorative elements
  // ---------------------------------------------------------------------------

  /// Gradient utama Go Ticket
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D5AF1), Color(0xFF7B8FF7)],
  );

  /// Gradient sekunder (oranye hangat)
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF9A72)],
  );

  /// Gradient dark (untuk mode gelap)
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  /// Gradient untuk Super Admin (merah elegan)
  static const LinearGradient superAdminGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
  );
}
