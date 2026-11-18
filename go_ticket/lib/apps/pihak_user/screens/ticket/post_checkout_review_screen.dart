// =============================================================================
// FILE: lib/apps/customer/screens/ticket/post_checkout_review_screen.dart
// RESPONSIBILITY: Halaman rating dan ulasan yang muncul setelah Customer
// melakukan check-out. Review dinamis dari database (BookingModel).
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/models/review_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/review_service.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../services/user_booking_storage.dart';

/// Halaman review & rating pasca checkout dengan proses verifikasi sederhana.
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
  int _overallRating = 5;

  /// Rating per kategori
  int _cleanlinessRating = 5;
  int _facilityRating = 5;
  int _locationRating = 5;
  int _serviceRating = 5;

  final _reviewController = TextEditingController();
  bool _isVerifiedChecked = true;
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
        const SnackBar(content: Text('Silakan pilih rating bintang terlebih dahulu.')),
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tuliskan cerita pengalaman menginap Anda.')),
      );
      return;
    }

    if (!_isVerifiedChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Centang pernyataan verifikasi menginap terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = AuthService.instance.currentUser;
      final b = booking;
      final hotelId = b?.hotelId.isNotEmpty == true ? b!.hotelId : '1';

      final rev = ReviewModel(
        id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
        bookingId: b?.id.isNotEmpty == true ? b!.id : (b?.bookingCode ?? ''),
        hotelId: hotelId,
        customerId: user?.id ?? '1',
        customerName: user?.fullName ?? b?.customerName ?? 'Tamu Go Ticket',
        overallRating: _overallRating.toDouble(),
        cleanlinessRating: _cleanlinessRating > 0 ? _cleanlinessRating : _overallRating,
        facilityRating: _facilityRating > 0 ? _facilityRating : _overallRating,
        locationRating: _locationRating > 0 ? _locationRating : _overallRating,
        serviceRating: _serviceRating > 0 ? _serviceRating : _overallRating,
        reviewText: _reviewController.text.trim(),
        createdAt: DateTime.now(),
        roomTypeName: b?.roomTypeName,
      );

      // 1. Simpan ke Supabase DB
      try {
        await ReviewService.instance.addReview(rev);
      } catch (_) {}

      // 2. Simpan ke local storage agar ulasan pasti langsung muncul di Property Detail
      await UserBookingStorage.instance.saveReview(rev);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim ulasan: $e')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Beri Ulasan Terverifikasi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
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
          // Header hotel info & status selesai
          _buildHotelHeader(),
          const SizedBox(height: 20),

          // Rating keseluruhan — bintang besar
          Text('Bagaimana kesan menginap Anda?', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          _buildOverallStars(),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _getRatingLabel(),
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Rating per kategori
          Text('Penilaian Aspek Menginap', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          _buildCategoryRating('Kebersihan Kamar', Icons.cleaning_services_outlined,
              _cleanlinessRating, (v) => setState(() => _cleanlinessRating = v)),
          _buildCategoryRating('Fasilitas Hotel', Icons.pool_outlined,
              _facilityRating, (v) => setState(() => _facilityRating = v)),
          _buildCategoryRating('Lokasi & Akses', Icons.location_on_outlined,
              _locationRating, (v) => setState(() => _locationRating = v)),
          _buildCategoryRating('Pelayanan Staf', Icons.support_agent_outlined,
              _serviceRating, (v) => setState(() => _serviceRating = v)),
          const SizedBox(height: 24),

          // Teks ulasan (tanpa input foto sesuai instruksi)
          Text('Ceritakan Pengalaman Anda', style: AppTextStyles.titleMedium),
          const SizedBox(height: 6),
          const Text(
            'Ulasan Anda akan diverifikasi dan ditampilkan langsung di halaman Property Detail hotel.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          GoTicketTextField(
            hint:
                'Bagikan kesan Anda tentang kebersihan kamar, pelayanan resepsionis, fasilitas, atau sarapan hotel...',
            controller: _reviewController,
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          // Box Verifikasi Menginap Sederhana
          _buildVerificationBox(),
          const SizedBox(height: 24),

          // Tombol submit
          GoTicketButton(
            label: 'Verifikasi & Kirim Ulasan',
            onPressed: _isLoading ? null : _submitReview,
            isLoading: _isLoading,
            icon: Icons.verified_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildHotelHeader() {
    final name = booking?.hotelName ?? 'Hotel';
    final address = booking?.hotelAddress ?? 'Indonesia';
    final roomName = booking?.roomTypeName ?? 'Standard Room';
    final roomNum = booking?.roomNumber ?? '003';
    final checkOut = booking != null
        ? 'Checkout Selesai: ${booking!.checkOutDate.day}/${booking!.checkOutDate.month}/${booking!.checkOutDate.year}'
        : 'Status: Checkout Selesai';

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
              color: const Color(0xFFDCFCE7),
              child: const Icon(Icons.hotel_rounded,
                  size: 30, color: Color(0xFF16A34A)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('STATUS: SELESAI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                    ),
                    const SizedBox(width: 6),
                    Text('Kamar $roomNum', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(name, style: AppTextStyles.titleMedium),
                Text('$roomName • $address', style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(checkOut, style: AppTextStyles.caption.copyWith(color: const Color(0xFF16A34A), fontWeight: FontWeight.w600)),
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

  Widget _buildVerificationBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 18),
              SizedBox(width: 6),
              Text(
                'Verifikasi Menginap Go Ticket',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Booking ID: ${booking?.bookingCode ?? "GT-RESERVASI"} • Terverifikasi Check-out',
            style: const TextStyle(fontSize: 11, color: Color(0xFF374151), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _isVerifiedChecked,
                  activeColor: const Color(0xFF16A34A),
                  onChanged: (val) => setState(() => _isVerifiedChecked = val ?? true),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Saya menyatakan dengan jujur bahwa saya telah menyelesaikan masa menginap di hotel ini, dan ulasan ini adalah pengalaman nyata saya.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF4B5563), height: 1.3),
                ),
              ),
            ],
          ),
        ],
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
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 44, color: Color(0xFF16A34A)),
            ),
            const SizedBox(height: 20),
            Text('Ulasan Terverifikasi Berhasil Dikirim!',
                textAlign: TextAlign.center, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 10),
            Text(
              'Ulasan Anda telah berhasil diverifikasi dan sekarang aktif di halaman Property Detail ${booking?.hotelName ?? "hotel"}.',
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
