// =============================================================================
// FILE: lib/core/utils/date_formatter.dart
// RESPONSIBILITY: Kumpulan helper function untuk format dan manipulasi tanggal
// yang digunakan di seluruh aplikasi Go Ticket. Mencakup:
// - Format tampilan tanggal (Indonesia & Inggris)
// - Format untuk API request
// - Kalkulasi durasi menginap (check-in ke check-out)
// - Helper untuk kalender / date picker
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Helper class untuk formatting dan manipulasi tanggal di aplikasi Go Ticket.
///
/// Semua method bersifat static sehingga dapat langsung dipanggil:
/// ```dart
/// String label = DateFormatter.toDisplayDate(DateTime.now());
/// // Output: '05 Okt 2026'
/// ```
class DateFormatter {
  DateFormatter._();

  // ---------------------------------------------------------------------------
  // FORMAT UNTUK TAMPILAN (UI Display)
  // ---------------------------------------------------------------------------

  /// Format tanggal standar: '05 Okt 2026'
  static String toDisplayDate(DateTime date) {
    return DateFormat(AppConstants.dateDisplayFormat, 'id').format(date);
  }

  /// Format tanggal lengkap dengan hari: 'Senin, 05 Oktober 2026'
  static String toFullDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id').format(date);
  }

  /// Format tanggal pendek: '05/10/2026'
  static String toShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format hanya hari dan bulan: '05 Oktober'
  static String toDayMonth(DateTime date) {
    return DateFormat('dd MMMM', 'id').format(date);
  }

  /// Format hanya bulan dan tahun: 'Oktober 2026'
  static String toMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id').format(date);
  }

  /// Format waktu: '14:30'
  static String toTime(DateTime date) {
    return DateFormat(AppConstants.timeFormat).format(date);
  }

  /// Format tanggal + waktu: '05 Okt 2026, 14:30'
  static String toDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id').format(date);
  }

  /// Format tanggal relatif: 'Hari ini', 'Besok', 'Kemarin', atau tanggal normal
  static String toRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';
    if (diff == -1) return 'Kemarin';
    if (diff > 1 && diff <= 7) return '$diff hari lagi';
    return toDisplayDate(date);
  }

  // ---------------------------------------------------------------------------
  // FORMAT UNTUK API REQUEST
  // ---------------------------------------------------------------------------

  /// Format tanggal untuk dikirim ke API: '2026-10-05'
  static String toApiDate(DateTime date) {
    return DateFormat(AppConstants.dateApiFormat).format(date);
  }

  /// Format DateTime lengkap untuk API (ISO 8601): '2026-10-05T14:30:00.000Z'
  static String toApiDateTime(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  // ---------------------------------------------------------------------------
  // PARSING — String ke DateTime
  // ---------------------------------------------------------------------------

  /// Parse string tanggal dari API ('2026-10-05') menjadi DateTime
  static DateTime? fromApiDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat(AppConstants.dateApiFormat).parse(dateString);
    } catch (_) {
      return null;
    }
  }

  /// Parse ISO 8601 string dari API menjadi DateTime lokal
  static DateTime? fromApiDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      return DateTime.parse(dateTimeString).toLocal();
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // BOOKING CALCULATIONS — Kalkulasi untuk fitur booking
  // ---------------------------------------------------------------------------

  /// Menghitung jumlah malam dari check-in ke check-out
  static int calculateNights(DateTime checkIn, DateTime checkOut) {
    final difference = checkOut.difference(checkIn);
    return difference.inDays;
  }

  /// Membuat label ringkas untuk rentang tanggal booking:
  /// '05 - 08 Okt 2026 (3 malam)'
  static String toDateRangeLabel(DateTime checkIn, DateTime checkOut) {
    final nights = calculateNights(checkIn, checkOut);
    final nightLabel = nights == 1 ? '1 malam' : '$nights malam';

    // Jika bulan sama
    if (checkIn.month == checkOut.month && checkIn.year == checkOut.year) {
      final startDay = DateFormat('dd').format(checkIn);
      final endDay = DateFormat('dd').format(checkOut);
      final monthYear = DateFormat('MMM yyyy', 'id').format(checkIn);
      return '$startDay - $endDay $monthYear ($nightLabel)';
    }

    // Beda bulan
    final startLabel = DateFormat('dd MMM', 'id').format(checkIn);
    final endLabel = DateFormat('dd MMM yyyy', 'id').format(checkOut);
    return '$startLabel - $endLabel ($nightLabel)';
  }

  /// Format ringkas untuk header kalender: '05 Okt – 08 Okt'
  static String toCalendarHeader(DateTime checkIn, DateTime checkOut) {
    final start = DateFormat('dd MMM', 'id').format(checkIn);
    final end = DateFormat('dd MMM', 'id').format(checkOut);
    return '$start – $end';
  }

  /// Mengecek apakah tanggal check-in valid (tidak di masa lalu)
  static bool isValidCheckIn(DateTime checkIn) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return !checkIn.isBefore(todayDate);
  }

  /// Mengecek apakah rentang tanggal booking valid
  static bool isValidDateRange(DateTime checkIn, DateTime checkOut) {
    return checkOut.isAfter(checkIn) &&
        calculateNights(checkIn, checkOut) >= AppConstants.minNightsStay &&
        calculateNights(checkIn, checkOut) <= AppConstants.maxNightsStay;
  }

  /// Mendapatkan DateTimeRange dari checkIn + jumlah malam
  static DateTimeRange getDateRange(DateTime checkIn, int nights) {
    final checkOut = checkIn.add(Duration(days: nights));
    return DateTimeRange(start: checkIn, end: checkOut);
  }

  // ---------------------------------------------------------------------------
  // DISPLAY HELPERS — Untuk UI calendar dan booking
  // ---------------------------------------------------------------------------

  /// Mendapatkan nama hari dalam Bahasa Indonesia (singkat): 'Sen', 'Sel', dst
  static String toShortDayName(DateTime date) {
    return DateFormat('EEE', 'id').format(date);
  }

  /// Mendapatkan nama hari dalam Bahasa Indonesia (lengkap): 'Senin', dst
  static String toFullDayName(DateTime date) {
    return DateFormat('EEEE', 'id').format(date);
  }

  /// Mengecek apakah tanggal tertentu adalah hari ini
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Mengecek apakah tanggal tertentu adalah akhir pekan (Sabtu/Minggu)
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// Format timestamp berapa lama yang lalu: 'Baru saja', '5 mnt lalu', dst
  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} mnt lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    if (difference.inDays < 7) return '${difference.inDays} hari lalu';
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} minggu lalu';
    }
    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    }
    return '${(difference.inDays / 365).floor()} tahun lalu';
  }
}
