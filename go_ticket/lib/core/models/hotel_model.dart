// =============================================================================
// FILE: lib/models/hotel_model.dart
// RESPONSIBILITY: Model data untuk Hotel Mitra di platform Go Ticket.
// Mencakup:
// - Informasi dasar hotel (nama, alamat, kota, deskripsi, foto)
// - Fasilitas / amenities hotel
// - Status hotel (pending approval, active, suspended)
// - Informasi kontak dan koordinat lokasi
// - Rating dan jumlah review
// =============================================================================

/// Enum status hotel di platform Go Ticket
enum HotelStatus {
  /// Hotel baru mendaftar, menunggu persetujuan Super Admin
  pending,

  /// Hotel aktif dan bisa dipesan oleh Customer
  active,

  /// Hotel ditangguhkan oleh Super Admin (sementara tidak bisa dipesan)
  suspended,

  /// Hotel ditolak oleh Super Admin
  rejected,
}

/// Extension untuk HotelStatus
extension HotelStatusExtension on HotelStatus {
  String get apiValue {
    switch (this) {
      case HotelStatus.pending:
        return 'pending';
      case HotelStatus.active:
        return 'active';
      case HotelStatus.suspended:
        return 'suspended';
      case HotelStatus.rejected:
        return 'rejected';
    }
  }

  static HotelStatus fromString(String value) {
    switch (value) {
      case 'active':
        return HotelStatus.active;
      case 'suspended':
        return HotelStatus.suspended;
      case 'rejected':
        return HotelStatus.rejected;
      default:
        return HotelStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case HotelStatus.pending:
        return 'Menunggu Persetujuan';
      case HotelStatus.active:
        return 'Aktif';
      case HotelStatus.suspended:
        return 'Ditangguhkan';
      case HotelStatus.rejected:
        return 'Ditolak';
    }
  }
}

// =============================================================================
// HOTEL MODEL
// =============================================================================

/// Model data lengkap untuk Hotel Mitra Go Ticket.
class HotelModel {
  /// ID unik hotel dari database
  final String id;

  /// Nama hotel
  final String name;

  /// Deskripsi singkat hotel (untuk tampilan list)
  final String? shortDescription;

  /// Deskripsi lengkap hotel (untuk halaman detail)
  final String? fullDescription;

  /// Alamat lengkap hotel
  final String address;

  /// Kota lokasi hotel
  final String city;

  /// Provinsi lokasi hotel
  final String province;

  /// Kode pos hotel
  final String? postalCode;

  /// Latitude koordinat GPS hotel
  final double? latitude;

  /// Longitude koordinat GPS hotel
  final double? longitude;

  /// Nomor telepon hotel
  final String? phoneNumber;

  /// Email hotel
  final String? email;

  /// Website hotel (opsional)
  final String? website;

  /// URL foto utama hotel (thumbnail)
  final String? mainImageUrl;

  /// Daftar URL foto hotel (galeri)
  final List<String> imageUrls;

  /// Daftar fasilitas hotel (misalnya: 'WiFi', 'Kolam Renang', 'Parkir')
  final List<String> amenities;

  /// Rating rata-rata hotel (1.0 - 5.0)
  final double rating;

  /// Total jumlah review
  final int reviewCount;

  /// Status hotel di platform
  final HotelStatus status;

  /// ID Admin Hotel (owner) yang mengelola hotel ini
  final String? adminUserId;

  /// Harga kamar termurah (untuk display 'Mulai dari...')
  final int? startingPrice;

  /// Total jumlah kamar
  final int? totalRooms;

  /// Tanggal hotel didaftarkan di platform
  final DateTime? registeredAt;

  /// Tanggal disetujui oleh Super Admin
  final DateTime? approvedAt;

  const HotelModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.province,
    this.shortDescription,
    this.fullDescription,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.email,
    this.website,
    this.mainImageUrl,
    this.imageUrls = const [],
    this.amenities = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.status = HotelStatus.pending,
    this.adminUserId,
    this.startingPrice,
    this.totalRooms,
    this.registeredAt,
    this.approvedAt,
  });

  // ---------------------------------------------------------------------------
  // CONVENIENCE GETTERS
  // ---------------------------------------------------------------------------

  /// Mengembalikan lokasi ringkas: 'Kota, Provinsi'
  String get location => '$city, $province';

  /// Mengecek apakah hotel bisa dipesan (status active)
  bool get isBookable => status == HotelStatus.active;

  /// Mendapatkan gambar utama atau placeholder
  String get displayImage =>
      mainImageUrl ?? 'https://via.placeholder.com/400x300?text=${Uri.encodeComponent(name)}';

  // ---------------------------------------------------------------------------
  // SERIALIZATION
  // ---------------------------------------------------------------------------

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      shortDescription: json['short_description'],
      fullDescription: json['full_description'] ?? json['description'],
      postalCode: json['postal_code'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phoneNumber: json['phone_number'] ?? json['phone'],
      email: json['email'],
      website: json['website'],
      mainImageUrl: json['main_image_url'] ?? json['image'],
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      status: HotelStatusExtension.fromString(json['status'] ?? 'pending'),
      adminUserId: json['admin_user_id']?.toString(),
      startingPrice: json['starting_price'],
      totalRooms: json['total_rooms'],
      registeredAt: json['registered_at'] != null
          ? DateTime.tryParse(json['registered_at'])
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'province': province,
      'short_description': shortDescription,
      'full_description': fullDescription,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'email': email,
      'website': website,
      'main_image_url': mainImageUrl,
      'image_urls': imageUrls,
      'amenities': amenities,
      'rating': rating,
      'review_count': reviewCount,
      'status': status.apiValue,
      'admin_user_id': adminUserId,
      'starting_price': startingPrice,
      'total_rooms': totalRooms,
    };
  }

  HotelModel copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? province,
    String? shortDescription,
    String? fullDescription,
    double? rating,
    int? reviewCount,
    HotelStatus? status,
    int? startingPrice,
  }) {
    return HotelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      shortDescription: shortDescription ?? this.shortDescription,
      fullDescription: fullDescription ?? this.fullDescription,
      postalCode: postalCode,
      latitude: latitude,
      longitude: longitude,
      phoneNumber: phoneNumber,
      email: email,
      website: website,
      mainImageUrl: mainImageUrl,
      imageUrls: imageUrls,
      amenities: amenities,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      status: status ?? this.status,
      adminUserId: adminUserId,
      startingPrice: startingPrice ?? this.startingPrice,
      totalRooms: totalRooms,
    );
  }

  @override
  String toString() => 'HotelModel(id: $id, name: $name, city: $city)';
}
