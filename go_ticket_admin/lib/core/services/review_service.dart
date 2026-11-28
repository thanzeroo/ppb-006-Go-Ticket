// =============================================================================
// FILE: lib/core/services/review_service.dart
// RESPONSIBILITY: CRUD reviews/ulasan dari tabel `ulasan` di Supabase.
// =============================================================================

import '../config/supabase_config.dart';
import '../models/review_model.dart';
import 'supabase_service.dart';

/// Service singleton pengelola ulasan dan rating bintang hotel pada tabel `ulasan` Supabase.
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  /// Ambil semua review untuk hotel [hotelId] dari tabel [ulasan] Supabase
  Future<List<ReviewModel>> getReviewsByHotel(String hotelId) async {
    try {
      final client = SupabaseService.instance.client;
      if (client == null) return [];

      final hId = int.tryParse(hotelId);
      dynamic query = client
          .from(SupabaseConfig.tableUlasan)
          .select('*, users(nama_lengkap)');
      if (hId != null) {
        query = query.eq('id_penginapan', hId);
      }
      final res = await query.order('id_ulasan', ascending: false);
      if (res != null) {
        return (res as List<dynamic>)
            .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Hitung rata-rata rating keseluruhan untuk [hotelId].
  Future<double> getAverageRating(String hotelId) async {
    try {
      final reviews = await getReviewsByHotel(hotelId);
      if (reviews.isEmpty) return 4.8;
      final sum =
          reviews.fold<double>(0, (acc, r) => acc + r.overallRating);
      return sum / reviews.length;
    } catch (_) {
      return 4.8;
    }
  }

  /// Simpan review baru ke DB [ulasan].
  Future<void> addReview(ReviewModel review) async {
    final client = SupabaseService.instance.client;
    if (client == null) return;
    await client
        .from(SupabaseConfig.tableUlasan)
        .insert(review.toSupabaseRow());
  }
}

