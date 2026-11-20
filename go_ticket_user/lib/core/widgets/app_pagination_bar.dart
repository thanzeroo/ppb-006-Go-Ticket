// =============================================================================
// FILE: lib/core/widgets/app_pagination_bar.dart
// RESPONSIBILITY: Komponen pagination universal untuk semua tab/list di aplikasi
// Membatasi tampilan 10 item per halaman dengan navigasi halaman ke samping kanan.
// =============================================================================

import 'package:flutter/material.dart';

/// Helper fungsi untuk memotong list sesuai halaman aktif (10 item per page)
List<T> paginateList<T>(List<T> items, int currentPage, {int pageSize = 10}) {
  if (items.isEmpty) return <T>[];
  final safePage = currentPage < 1 ? 1 : currentPage;
  final start = (safePage - 1) * pageSize;
  if (start >= items.length) return <T>[];
  final end = (start + pageSize) > items.length ? items.length : (start + pageSize);
  return items.sublist(start, end);
}

/// Widget bar navigasi pagination yang elegan dan interaktif
class AppPaginationBar extends StatelessWidget {
  /// Halaman aktif saat ini (1-based index)
  final int currentPage;

  /// Total jumlah item dari data keseluruhan
  final int totalItems;

  /// Jumlah item per halaman (default 10)
  final int pageSize;

  /// Callback saat user menekan nomor halaman atau tombol navigasi
  final ValueChanged<int> onPageChanged;

  /// Warna aksen utama untuk tombol aktif (menyesuaikan tema modul)
  final Color primaryColor;

  /// Label nama data (opsional, contoh: 'hotel', 'pesanan', 'tamu')
  final String itemLabel;

  const AppPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalItems,
    this.pageSize = 10,
    required this.onPageChanged,
    this.primaryColor = const Color(0xFF00758F),
    this.itemLabel = 'data',
  });

  @override
  Widget build(BuildContext context) {
    if (totalItems <= 0) return const SizedBox.shrink();

    final totalPages = (totalItems / pageSize).ceil();
    final safeCurrentPage = currentPage.clamp(1, totalPages > 0 ? totalPages : 1);

    final startItem = (safeCurrentPage - 1) * pageSize + 1;
    final endItem = (safeCurrentPage * pageSize) > totalItems
        ? totalItems
        : (safeCurrentPage * pageSize);

    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info baris
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Menampilkan $startItem–$endItem dari $totalItems $itemLabel',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Hal $safeCurrentPage dari $totalPages',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),

          if (totalPages > 1) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Horizontal Page Selector scrolling ke samping kanan
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tombol Sebelumnya
                  _buildNavButton(
                    icon: Icons.chevron_left_rounded,
                    label: 'Sebelumnya',
                    enabled: safeCurrentPage > 1,
                    onTap: () => onPageChanged(safeCurrentPage - 1),
                  ),
                  const SizedBox(width: 6),

                  // Nomor-nomor halaman (1, 2, 3...) disusun ke samping kanan
                  for (int p = 1; p <= totalPages; p++) ...[
                    _buildPageNumberButton(p, p == safeCurrentPage),
                    const SizedBox(width: 4),
                  ],

                  const SizedBox(width: 2),

                  // Tombol Berikutnya (di samping kanan)
                  _buildNavButton(
                    icon: Icons.chevron_right_rounded,
                    label: 'Berikutnya',
                    isRight: true,
                    enabled: safeCurrentPage < totalPages,
                    onTap: () => onPageChanged(safeCurrentPage + 1),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPageNumberButton(int page, bool isActive) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isActive ? null : () => onPageChanged(page),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? primaryColor : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? primaryColor : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            '$page',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool isRight = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: enabled
                ? (isRight ? primaryColor.withValues(alpha: 0.08) : const Color(0xFFF8FAFC))
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled
                  ? (isRight ? primaryColor.withValues(alpha: 0.3) : const Color(0xFFE2E8F0))
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isRight) ...[
                Icon(
                  icon,
                  size: 16,
                  color: enabled ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: enabled
                      ? (isRight ? primaryColor : const Color(0xFF334155))
                      : const Color(0xFF94A3B8),
                ),
              ),
              if (isRight) ...[
                const SizedBox(width: 4),
                Icon(
                  icon,
                  size: 16,
                  color: enabled ? primaryColor : const Color(0xFF94A3B8),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

