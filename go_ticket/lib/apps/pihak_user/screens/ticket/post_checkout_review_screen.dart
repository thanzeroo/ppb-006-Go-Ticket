// =============================================================================
// FILE: lib/apps/customer/screens/ticket/post_checkout_review_screen.dart
// RESPONSIBILITY: Halaman rating dan ulasan yang muncul setelah Customer
// melakukan check-out. Review dinamis dari database (BookingModel).
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

/// Halaman review & rating pasca checkout.
class PostCheckoutReviewScreen extends StatefulWidget {
  final dynamic arguments;

  const PostCheckoutReviewScreen({super.key, this.arguments});

  @override
  State<PostCheckoutReviewScreen> createState() =>
      _PostCheckoutReviewScreenState();
}

class _PostCheckoutReviewScreenState extends State<PostCheckoutReviewScreen> {
  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  /// Rating keseluruhan (1-5)
  int _overallRating = 0;

  /// Rating per kategori
  int _cleanlinessRating = 0;
  int _facilityRating = 0;
  int _locationRating = 0;
  int _serviceRating = 0;

  final _reviewController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;

  BookingModel? get booking =>
      widget.arguments is BookingModel ? (widget.arguments as BookingModel) : null;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_overallRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berikan rating bintang terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSubmitted = true;
    });
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Beri Ulasan'),
        automaticallyImplyLeading: !_isSubmitted,
      ),
      body: _isSubmitted ? _buildSuccessView(context) : _buildReviewForm(),
    );
  }

  Widget _buildReviewForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header hotel info
          _buildHotelHeader(),
          const SizedBox(height: 24),

          // Rating keseluruhan — bintang besar
          Text('Bagaimana kesan Anda?', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          _buildOverallStars(),
          const SizedBox(height: 8),
          Center(
              child: Text(_getRatingLabel(),
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: AppColors.warning))),
          const SizedBox(height: 24),

          // Rating per kategori
          Text('Rating per Kategori', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          _buildCategoryRating('Kebersihan', Icons.cleaning_services_outlined,
              _cleanlinessRating, (v) => setState(() => _cleanlinessRating = v)),
          _buildCategoryRating('Fasilitas', Icons.pool_outlined,
              _facilityRating, (v) => setState(() => _facilityRating = v)),
          _buildCategoryRating('Lokasi', Icons.location_on_outlined,
              _locationRating, (v) => setState(() => _locationRating = v)),
          _buildCategoryRating('Pelayanan', Icons.support_agent_outlined,
              _serviceRating, (v) => setState(() => _serviceRating = v)),
          const SizedBox(height: 24),

          // Teks ulasan
          Text('Ceritakan pengalaman Anda', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          GoTicketTextField(
            hint:
                'Bagikan pengalaman menginap Anda untuk membantu tamu lainnya...',
            controller: _reviewController,
            maxLines: 5,
          ),
          const SizedBox(height: 16),

          // Tambah foto
          _buildPhotoUpload(),
          const SizedBox(height: 32),

          // Tombol submit
          GoTicketButton(
            label: 'Kirim Ulasan',
            onPressed: _isLoading ? null : _submitReview,
            isLoading: _isLoading,
            icon: Icons.send_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildHotelHeader() {
    final name = booking?.hotelName ?? 'Hotel';
    final address = booking?.hotelAddress ?? 'Indonesia';
    final checkOut = booking != null
        ? 'Checkout: ${booking!.checkOutDate.day}/${booking!.checkOutDate.month}/${booking!.checkOutDate.year}'
        : 'Checkout Selesai';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 60,
              color: AppColors.grey200,
              child: const Icon(Icons.hotel_rounded,
                  size: 30, color: AppColors.grey400),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleMedium),
                Text(address, style: AppTextStyles.bodySmall),
                Text(checkOut, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => setState(() => _overallRating = index + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              index < _overallRating
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              size: 44,
              color: AppColors.warning,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategoryRating(
      String label, IconData icon, int rating, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.grey500),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.grey700))),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onChanged(index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    index < rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 26,
                    color: AppColors.warning,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur unggah foto segera hadir'))),
        child: Column(
          children: [
            const Icon(Icons.add_photo_alternate_outlined,
                size: 36, color: AppColors.grey400),
            const SizedBox(height: 6),
            Text('Tambah Foto (Opsional)',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.grey600)),
            Text('Maks. 5 foto (JPG, PNG)',
                style: AppTextStyles.caption.copyWith(color: AppColors.grey400)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 44, color: AppColors.statusConfirmed),
            ),
            const SizedBox(height: 20),
            Text('Terima Kasih atas Ulasan Anda!',
                textAlign: TextAlign.center, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 10),
            Text(
              'Ulasan Anda sangat berharga untuk membantu tamu lain memilih akomodasi terbaik di Go Ticket.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 32),
            GoTicketButton(
              label: 'Kembali ke Pesanan',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel() {
    switch (_overallRating) {
      case 1:
        return 'Sangat Buruk';
      case 2:
        return 'Kurang Memuaskan';
      case 3:
        return 'Cukup Baik';
      case 4:
        return 'Sangat Bagus';
      case 5:
        return 'Luar Biasa!';
      default:
        return 'Pilih Rating';
    }
  }
}
