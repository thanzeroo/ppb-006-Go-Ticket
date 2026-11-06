// =============================================================================
// FILE: lib/core/services/review_service.dart
// RESPONSIBILITY: CRUD reviews/ulasan dari tabel `reviews` di Supabase.
// =============================================================================

import '../models/review_model.dart';
import 'supabase_service.dart';

class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  /// Ambil semua review untuk hotel [hotelId].
  /// Return list kosong kalau tabel masih kosong.
  Future<List<ReviewModel>> getReviewsByHotel(String hotelId) async {
    try {
      final client = SupabaseService.instance.client;
      if (client == null) return [];
      final res = await client
          .from('reviews')
          .select()
          .eq('hotel_id', hotelId)
          .order('created_at', ascending: false);
      return (res as List<dynamic>)
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Hitung rata-rata rating keseluruhan untuk [hotelId].
  Future<double> getAverageRating(String hotelId) async {
    try {
      final reviews = await getReviewsByHotel(hotelId);
      if (reviews.isEmpty) return 0;
      final sum =
          reviews.fold<double>(0, (acc, r) => acc + r.overallRating);
      return sum / reviews.length;
    } catch (_) {
      return 0;
    }
  }

  /// Simpan review baru ke DB.
  Future<void> addReview(ReviewModel review) async {
    final client = SupabaseService.instance.client;
    if (client == null) return;
    await client.from('reviews').insert(review.toJson());
  }
}

