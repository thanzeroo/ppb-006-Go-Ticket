// =============================================================================
// FILE: lib/apps/customer/screens/ticket/post_checkout_review_screen.dart
// RESPONSIBILITY: Halaman rating dan ulasan yang muncul setelah Customer
// melakukan check-out. Customer dapat memberikan:
// - Rating bintang keseluruhan (1-5)
// - Rating per kategori: kebersihan, fasilitas, lokasi, pelayanan
// - Teks ulasan / komentar
// - Foto ulasan (opsional)
// Review hanya bisa diberikan sekali per booking.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
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

    // TODO: Integrasikan dengan ReviewRepository.submitReview()
    await Future.delayed(const Duration(seconds: 2));

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
          Center(child: Text(_getRatingLabel(), style: AppTextStyles.headlineSmall
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
            hint: 'Bagikan pengalaman menginap Anda untuk membantu tamu lainnya...',
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
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHotelHeader() {
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
                Text('Grand Hotel Example', style: AppTextStyles.titleMedium),
                Text('Jakarta Pusat', style: AppTextStyles.bodySmall),
                Text('Checkout: 08 Oktober 2026',
                    style: AppTextStyles.caption),
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
              index < _overallRating ? Icons.star_rounded : Icons.star_outline_rounded,
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
            child: Text(label, style: AppTextStyles.labelMedium),
          ),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onChanged(index + 1),
                child: Icon(
                  index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 24,
                  color: AppColors.warning,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto (Opsional)', style: AppTextStyles.titleMedium),
        const SizedBox(height: 10),
        Row(
          children: [
            // Tombol tambah foto
            GestureDetector(
              onTap: () {
                // TODO: Implementasi image picker
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey300, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        size: 24, color: AppColors.grey400),
                    SizedBox(height: 4),
                    Text('Tambah', style: TextStyle(fontSize: 10, color: AppColors.grey400)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getRatingLabel() {
    switch (_overallRating) {
      case 1: return 'Sangat Kurang';
      case 2: return 'Kurang';
      case 3: return 'Cukup';
      case 4: return 'Bagus';
      case 5: return 'Luar Biasa!';
      default: return 'Pilih Rating';
    }
  }

  Widget _buildSuccessView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  size: 56, color: AppColors.success),
            ),
            const SizedBox(height: 24),
            Text('Ulasan Terkirim!', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Terima kasih atas ulasan Anda.\nUlasan Anda membantu tamu lain memilih hotel terbaik!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GoTicketButton(
              label: 'Kembali ke Beranda',
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              width: 220,
              icon: Icons.home_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
