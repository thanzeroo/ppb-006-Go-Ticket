// =============================================================================
// FILE: lib/core/widgets/empty_state_widget.dart
// RESPONSIBILITY: Widget yang ditampilkan ketika halaman tidak memiliki data
// untuk ditampilkan (empty state). Digunakan di:
// - Riwayat booking kosong
// - Hasil pencarian hotel tidak ditemukan
// - Daftar karyawan kosong
// - List maintenance ticket kosong
// dll.
// Mendukung ikon, judul, deskripsi, dan tombol aksi opsional.
// =============================================================================

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';
import 'custom_button.dart';

/// Widget empty state yang fleksibel dan dapat dikonfigurasi.
///
/// ```dart
/// GoTicketEmptyState(
///   icon: Icons.hotel_outlined,
///   title: 'Belum Ada Booking',
///   description: 'Pesan hotel pertama Anda sekarang!',
///   actionLabel: 'Cari Hotel',
///   onAction: () => navigateToDashboard(),
/// )
/// ```
class GoTicketEmptyState extends StatelessWidget {
  /// Ikon yang ditampilkan di atas teks
  final IconData icon;

  /// Judul utama empty state
  final String title;

  /// Deskripsi detail / sub-teks
  final String? description;

  /// Label tombol aksi (opsional)
  final String? actionLabel;

  /// Callback tombol aksi (opsional)
  final VoidCallback? onAction;

  /// Warna ikon (default: AppColors.grey400)
  final Color? iconColor;

  /// Ukuran ikon (default: 64)
  final double iconSize;

  const GoTicketEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container ikon dengan background lingkaran
            Container(
              width: iconSize + 32,
              height: iconSize + 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),

            // Judul
            Text(
              title,
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),

            // Deskripsi
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],

            // Tombol aksi
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              GoTicketButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 200,
                height: 48,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PRESET EMPTY STATES — Varian yang sudah dikonfigurasi untuk konteks tertentu
// =============================================================================

/// Empty state untuk riwayat booking kosong
class EmptyBookingHistory extends StatelessWidget {
  final VoidCallback? onSearch;

  const EmptyBookingHistory({super.key, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return GoTicketEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'Belum Ada Booking',
      description: 'Riwayat pemesanan hotel Anda akan\nmuncul di sini setelah checkout.',
      actionLabel: onSearch != null ? 'Cari Hotel Sekarang' : null,
      onAction: onSearch,
    );
  }
}

/// Empty state untuk hasil pencarian hotel kosong
class EmptySearchResult extends StatelessWidget {
  final String? keyword;
  final VoidCallback? onReset;

  const EmptySearchResult({super.key, this.keyword, this.onReset});

  @override
  Widget build(BuildContext context) {
    return GoTicketEmptyState(
      icon: Icons.search_off_rounded,
      title: 'Hotel Tidak Ditemukan',
      description: keyword != null
          ? 'Tidak ada hotel yang cocok untuk\n"$keyword". Coba kata kunci lain.'
          : 'Tidak ada hotel yang sesuai filter.\nCoba ubah kriteria pencarian.',
      actionLabel: 'Reset Pencarian',
      onAction: onReset,
    );
  }
}

/// Empty state untuk daftar kamar yang perlu dibersihkan (Maintenance)
class EmptyCleaningList extends StatelessWidget {
  const EmptyCleaningList({super.key});

  @override
  Widget build(BuildContext context) {
    return const GoTicketEmptyState(
      icon: Icons.hotel_outlined,
      title: 'Semua Kamar Bersih!',
      description: 'Tidak ada kamar yang memerlukan\npembersihan saat ini. Good job! 🎉',
      iconColor: AppColors.success,
    );
  }
}

/// Empty state untuk tidak ada koneksi internet
class NoInternetState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GoTicketEmptyState(
      icon: Icons.wifi_off_rounded,
      title: 'Tidak Ada Koneksi',
      description: 'Periksa koneksi internet Anda\ndan coba lagi.',
      actionLabel: 'Coba Lagi',
      onAction: onRetry,
      iconColor: AppColors.warning,
    );
  }
}

/// Empty state untuk terjadi error saat memuat data
class ErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorState({super.key, this.errorMessage, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GoTicketEmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Terjadi Kesalahan',
      description: errorMessage ?? 'Gagal memuat data. Coba lagi nanti.',
      actionLabel: 'Coba Lagi',
      onAction: onRetry,
      iconColor: AppColors.error,
    );
  }
}
