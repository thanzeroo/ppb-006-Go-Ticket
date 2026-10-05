// =============================================================================
// FILE: lib/models/review_model.dart
// RESPONSIBILITY: Model data untuk Review / Ulasan tamu setelah checkout.
// Review hanya bisa diberikan oleh Customer yang sudah selesai checkout
// (BookingStatus.checkedOut) dan belum pernah memberikan review untuk
// booking tersebut.
// Mencakup:
// - Rating bintang (1-5) per kategori (kebersihan, fasilitas, lokasi, dll.)
// - Teks ulasan
// - Foto ulasan (opsional)
// - Response dari pihak hotel (opsional)
// =============================================================================

/// Model data review / ulasan hotel dari tamu Go Ticket.
class ReviewModel {
  /// ID unik review dari database
  final String id;

  /// ID Booking yang direview (foreign key)
  final String bookingId;

  /// ID Hotel yang direview
  final String hotelId;

  /// ID Customer yang menulis review
  final String customerId;

  /// Nama Customer (untuk tampilan)
  final String customerName;

  /// URL avatar Customer
  final String? customerAvatarUrl;

  /// Rating keseluruhan (1.0 - 5.0)
  final double overallRating;

  /// Rating kebersihan kamar (1-5)
  final int? cleanlinessRating;

  /// Rating fasilitas hotel (1-5)
  final int? facilityRating;

  /// Rating lokasi hotel (1-5)
  final int? locationRating;

  /// Rating pelayanan staff (1-5)
  final int? serviceRating;

  /// Rating nilai / value for money (1-5)
  final int? valueRating;

  /// Teks ulasan / komentar dari tamu
  final String? reviewText;

  /// Daftar URL foto yang dilampirkan tamu (opsional)
  final List<String> photoUrls;

  /// Tanggal review ditulis
  final DateTime createdAt;

  /// Balasan dari pihak hotel (opsional)
  final String? hotelResponse;

  /// Tanggal hotel membalas review
  final DateTime? hotelResponseAt;

  /// Tipe kamar yang diinap (untuk konteks review)
  final String? roomTypeName;

  /// Tanggal check-in yang direview
  final DateTime? checkInDate;

  /// Tanggal check-out yang direview
  final DateTime? checkOutDate;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.hotelId,
    required this.customerId,
    required this.customerName,
    required this.overallRating,
    required this.createdAt,
    this.customerAvatarUrl,
    this.cleanlinessRating,
    this.facilityRating,
    this.locationRating,
    this.serviceRating,
    this.valueRating,
    this.reviewText,
    this.photoUrls = const [],
    this.hotelResponse,
    this.hotelResponseAt,
    this.roomTypeName,
    this.checkInDate,
    this.checkOutDate,
  });

  // ---------------------------------------------------------------------------
  // CONVENIENCE GETTERS
  // ---------------------------------------------------------------------------

  /// Inisial nama Customer untuk avatar placeholder
  String get customerInitials {
    final parts = customerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return customerName.isNotEmpty ? customerName[0].toUpperCase() : '?';
  }

  /// Mendapatkan kategori rating sebagai string (Luar Biasa, Sangat Baik, dll.)
  String get ratingLabel {
    if (overallRating >= 4.5) return 'Luar Biasa';
    if (overallRating >= 4.0) return 'Sangat Baik';
    if (overallRating >= 3.0) return 'Baik';
    if (overallRating >= 2.0) return 'Cukup';
    return 'Kurang';
  }

  // ---------------------------------------------------------------------------
  // SERIALIZATION
  // ---------------------------------------------------------------------------

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      hotelId: json['hotel_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? 'Anonim',
      customerAvatarUrl: json['customer_avatar_url'],
      overallRating: (json['overall_rating'] as num?)?.toDouble() ?? 0.0,
      cleanlinessRating: json['cleanliness_rating'],
      facilityRating: json['facility_rating'],
      locationRating: json['location_rating'],
      serviceRating: json['service_rating'],
      valueRating: json['value_rating'],
      reviewText: json['review_text'] ?? json['comment'],
      photoUrls: (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      hotelResponse: json['hotel_response'],
      hotelResponseAt: json['hotel_response_at'] != null
          ? DateTime.tryParse(json['hotel_response_at'])
          : null,
      roomTypeName: json['room_type_name'],
      checkInDate: json['check_in_date'] != null
          ? DateTime.tryParse(json['check_in_date'])
          : null,
      checkOutDate: json['check_out_date'] != null
          ? DateTime.tryParse(json['check_out_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'hotel_id': hotelId,
      'customer_id': customerId,
      'overall_rating': overallRating,
      'cleanliness_rating': cleanlinessRating,
      'facility_rating': facilityRating,
      'location_rating': locationRating,
      'service_rating': serviceRating,
      'value_rating': valueRating,
      'review_text': reviewText,
      'photo_urls': photoUrls,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'ReviewModel(id: $id, hotel: $hotelId, rating: $overallRating)';
}
