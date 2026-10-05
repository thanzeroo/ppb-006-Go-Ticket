// =============================================================================
// FILE: lib/core/utils/currency_formatter.dart
// RESPONSIBILITY: Kumpulan helper function untuk format angka sebagai
// mata uang Rupiah (IDR) yang digunakan di seluruh aplikasi Go Ticket.
// Mencakup:
// - Format Rupiah lengkap: 'Rp 500.000'
// - Format compact: 'Rp 500rb', 'Rp 1,5jt'
// - Format untuk input field (hapus non-digit)
// - Parse string kembali ke angka
// =============================================================================

import 'package:intl/intl.dart';

/// Helper class untuk formatting mata uang Rupiah (IDR) di aplikasi Go Ticket.
///
/// Semua method bersifat static:
/// ```dart
/// String harga = CurrencyFormatter.toRupiah(500000);
/// // Output: 'Rp 500.000'
/// ```
class CurrencyFormatter {
  CurrencyFormatter._();

  // ---------------------------------------------------------------------------
  // FORMAT DASAR
  // ---------------------------------------------------------------------------

  /// NumberFormat standar untuk Rupiah
  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// NumberFormat dengan 2 desimal (untuk kalkulasi)
  static final NumberFormat _rupiahDecimalFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );

  /// Format angka menjadi string Rupiah standar.
  ///
  /// Contoh: 500000 → 'Rp 500.000'
  static String toRupiah(num amount) {
    return _rupiahFormat.format(amount);
  }

  /// Format angka menjadi string Rupiah dengan desimal.
  ///
  /// Contoh: 500000.50 → 'Rp 500.000,50'
  static String toRupiahDecimal(num amount) {
    return _rupiahDecimalFormat.format(amount);
  }

  /// Format angka tanpa simbol 'Rp', hanya angka dengan titik pemisah ribuan.
  ///
  /// Contoh: 500000 → '500.000'
  static String toNumber(num amount) {
    return NumberFormat('#,###', 'id_ID').format(amount);
  }

  // ---------------------------------------------------------------------------
  // FORMAT COMPACT / SINGKAT
  // ---------------------------------------------------------------------------

  /// Format compact untuk tampilan ringkas di card / badge.
  ///
  /// Contoh:
  /// - 500000    → 'Rp 500rb'
  /// - 1500000   → 'Rp 1,5jt'
  /// - 10000000  → 'Rp 10jt'
  /// - 1000000000 → 'Rp 1M'
  static String toCompact(num amount) {
    if (amount >= 1000000000) {
      final value = amount / 1000000000;
      final formatted = value % 1 == 0
          ? value.toInt().toString()
          : value.toStringAsFixed(1);
      return 'Rp ${formatted}M';
    } else if (amount >= 1000000) {
      final value = amount / 1000000;
      final formatted = value % 1 == 0
          ? value.toInt().toString()
          : value.toStringAsFixed(1);
      return 'Rp ${formatted}jt';
    } else if (amount >= 1000) {
      final value = amount / 1000;
      final formatted = value % 1 == 0
          ? value.toInt().toString()
          : value.toStringAsFixed(1);
      return 'Rp ${formatted}rb';
    }
    return toRupiah(amount);
  }

  /// Format untuk range harga: 'Rp 300.000 – Rp 500.000'
  static String toRangeRupiah(num minAmount, num maxAmount) {
    return '${toRupiah(minAmount)} – ${toRupiah(maxAmount)}';
  }

  /// Format harga per malam: 'Rp 500.000 / malam'
  static String toPerNight(num amount) {
    return '${toRupiah(amount)} / malam';
  }

  /// Format dengan label 'mulai dari': 'Mulai Rp 300.000'
  static String toStartingFrom(num amount) {
    return 'Mulai ${toRupiah(amount)}';
  }

  // ---------------------------------------------------------------------------
  // UNTUK INPUT FIELD
  // ---------------------------------------------------------------------------

  /// Menghapus semua karakter non-digit dari string input field.
  /// Berguna untuk mengambil nilai dari TextField yang sudah diformat.
  ///
  /// Contoh: 'Rp 500.000' → '500000'
  static String stripFormatting(String formattedValue) {
    return formattedValue.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Parse string yang sudah diformat kembali menjadi integer.
  ///
  /// Contoh: 'Rp 500.000' → 500000
  /// Mengembalikan 0 jika parsing gagal.
  static int parseToInt(String formattedValue) {
    final stripped = stripFormatting(formattedValue);
    return int.tryParse(stripped) ?? 0;
  }

  /// Parse string yang sudah diformat kembali menjadi double.
  ///
  /// Mengembalikan 0.0 jika parsing gagal.
  static double parseToDouble(String formattedValue) {
    final stripped = stripFormatting(formattedValue);
    return double.tryParse(stripped) ?? 0.0;
  }

  // ---------------------------------------------------------------------------
  // KALKULASI BISNIS
  // ---------------------------------------------------------------------------

  /// Menghitung total harga booking (harga kamar × jumlah malam)
  static int calculateTotal(int pricePerNight, int nights) {
    return pricePerNight * nights;
  }

  /// Menghitung jumlah komisi platform Go Ticket
  ///
  /// [amount] — total transaksi
  /// [commissionPercent] — persentase komisi (default: 10%)
  static int calculateCommission(int amount, {double commissionPercent = 10.0}) {
    return (amount * commissionPercent / 100).round();
  }

  /// Menghitung jumlah yang diterima mitra hotel setelah dipotong komisi
  static int calculateMitraRevenue(int amount,
      {double commissionPercent = 10.0}) {
    return amount - calculateCommission(amount, commissionPercent: commissionPercent);
  }

  /// Menghitung harga setelah diskon
  ///
  /// [originalPrice] — harga asli
  /// [discountPercent] — persen diskon (0-100)
  static int calculateDiscountedPrice(int originalPrice, int discountPercent) {
    if (discountPercent <= 0) return originalPrice;
    if (discountPercent >= 100) return 0;
    return (originalPrice * (100 - discountPercent) / 100).round();
  }

  /// Menghitung penghematan dari diskon (selisih harga asli dan setelah diskon)
  static int calculateSavings(int originalPrice, int discountPercent) {
    return originalPrice - calculateDiscountedPrice(originalPrice, discountPercent);
  }

  /// Format string penghematan: 'Hemat Rp 100.000'
  static String toSavingsLabel(int savings) {
    return 'Hemat ${toRupiah(savings)}';
  }
}
