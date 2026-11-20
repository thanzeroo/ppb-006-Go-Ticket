// =============================================================================
// FILE: lib/core/widgets/loading_indicator.dart
// RESPONSIBILITY: Widget loading indicator yang konsisten di seluruh aplikasi
// Go Ticket. Menyediakan beberapa varian sesuai konteks:
// - GoTicketLoadingIndicator: Spinner fullscreen (untuk proses async page)
// - GoTicketInlineLoader: Spinner kecil inline (untuk list item / card)
// - GoTicketShimmer: Placeholder shimmer saat data sedang dimuat
// =============================================================================

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

// =============================================================================
// FULLSCREEN LOADING INDICATOR
// =============================================================================

/// Loading indicator fullscreen dengan overlay semi-transparan.
/// Digunakan saat halaman sedang memuat data dari API.
///
/// ```dart
/// if (isLoading) const GoTicketLoadingIndicator()
/// ```
class GoTicketLoadingIndicator extends StatelessWidget {
  /// Teks opsional yang muncul di bawah spinner
  final String? message;

  /// Apakah menampilkan overlay gelap di belakang spinner
  final bool withOverlay;

  const GoTicketLoadingIndicator({
    super.key,
    this.message,
    this.withOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (withOverlay) {
      return Container(
        color: Colors.black54,
        child: Center(child: indicator),
      );
    }

    return Center(child: indicator);
  }
}

// =============================================================================
// INLINE LOADING INDICATOR — Kecil untuk inside card / list
// =============================================================================

/// Loading indicator kecil untuk digunakan di dalam widget lain.
/// Contoh: di dalam tombol atau di bawah list saat load-more.
class GoTicketInlineLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const GoTicketInlineLoader({
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color ?? AppColors.primary,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

// =============================================================================
// SHIMMER LOADING — Placeholder saat data sedang dimuat
// =============================================================================

/// Widget shimmer placeholder untuk simulasi konten yang sedang dimuat.
/// Menggunakan animasi gradient geser untuk efek shimmer.
class GoTicketShimmer extends StatefulWidget {
  /// Lebar placeholder
  final double width;

  /// Tinggi placeholder
  final double height;

  /// Border radius placeholder (default: 8)
  final double borderRadius;

  const GoTicketShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<GoTicketShimmer> createState() => _GoTicketShimmerState();
}

class _GoTicketShimmerState extends State<GoTicketShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                AppColors.grey200,
                AppColors.grey100,
                AppColors.grey200,
              ],
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// HOTEL CARD SHIMMER — Skeleton loader untuk hotel card
// =============================================================================

/// Skeleton loading card untuk placeholder hotel saat data sedang dimuat.
class HotelCardShimmer extends StatelessWidget {
  const HotelCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar hotel placeholder
          const GoTicketShimmer(height: 160, borderRadius: 16),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GoTicketShimmer(width: 180, height: 16),
                const SizedBox(height: 8),
                const GoTicketShimmer(width: 120, height: 12),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    GoTicketShimmer(width: 90, height: 20),
                    GoTicketShimmer(width: 60, height: 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
