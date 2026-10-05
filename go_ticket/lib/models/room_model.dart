// =============================================================================
// FILE: lib/models/room_model.dart
// RESPONSIBILITY: Model data untuk Kamar Hotel di platform Go Ticket.
// Mencakup:
// - Informasi kamar (nama tipe, deskripsi, kapasitas, fasilitas)
// - Harga harian dan harga weekend/peak season
// - Status kamar (Available, Occupied, Dirty, Cleaning, Maintenance)
// - Foto kamar
// =============================================================================

/// Enum status kamar hotel — digunakan di Hotel Partner app
enum RoomStatus {
  /// Kamar kosong dan siap dipesan / ditempati
  available,

  /// Kamar sedang ditempati tamu (Check-in sudah dilakukan)
  occupied,

  /// Kamar sudah checkout tapi belum dibersihkan
  dirty,

  /// Kamar sedang dalam proses pembersihan oleh Maintenance
  cleaning,

  /// Kamar sedang dalam perbaikan dan tidak bisa dipesan
  maintenance,
}

/// Extension untuk RoomStatus
extension RoomStatusExtension on RoomStatus {
  String get apiValue {
    switch (this) {
      case RoomStatus.available:
        return 'available';
      case RoomStatus.occupied:
        return 'occupied';
      case RoomStatus.dirty:
        return 'dirty';
      case RoomStatus.cleaning:
        return 'cleaning';
      case RoomStatus.maintenance:
        return 'maintenance';
    }
  }

  static RoomStatus fromString(String value) {
    switch (value) {
      case 'occupied':
        return RoomStatus.occupied;
      case 'dirty':
        return RoomStatus.dirty;
      case 'cleaning':
        return RoomStatus.cleaning;
      case 'maintenance':
        return RoomStatus.maintenance;
      default:
        return RoomStatus.available;
    }
  }

  String get displayName {
    switch (this) {
      case RoomStatus.available:
        return 'Tersedia';
      case RoomStatus.occupied:
        return 'Ditempati';
      case RoomStatus.dirty:
        return 'Perlu Dibersihkan';
      case RoomStatus.cleaning:
        return 'Sedang Dibersihkan';
      case RoomStatus.maintenance:
        return 'Maintenance';
    }
  }
}

// =============================================================================
// ROOM MODEL
// =============================================================================

/// Model data untuk kamar hotel Go Ticket.
class RoomModel {
  /// ID unik kamar dari database
  final String id;

  /// ID hotel pemilik kamar ini
  final String hotelId;

  /// Nomor kamar (misalnya: '101', '201A')
  final String roomNumber;

  /// Tipe / nama kategori kamar (misalnya: 'Standard', 'Deluxe', 'Suite')
  final String typeName;

  /// Deskripsi detail kamar
  final String? description;

  /// Kapasitas maksimal tamu
  final int maxGuests;

  /// Jumlah kasur (untuk display: '2 Kasur Twin' atau '1 Kasur King')
  final String? bedType;

  /// Luas kamar dalam meter persegi
  final double? areaM2;

  /// Harga kamar per malam (harga normal weekday)
  final int pricePerNight;

  /// Harga kamar di akhir pekan / weekend (Sabtu-Minggu)
  final int? weekendPrice;

  /// Harga peak season (misalnya: Lebaran, Natal, Tahun Baru)
  final int? peakSeasonPrice;

  /// Persentase diskon yang sedang berlaku (0 jika tidak ada diskon)
  final int discountPercent;

  /// Daftar fasilitas kamar (misalnya: 'AC', 'TV', 'WiFi', 'Bathtub')
  final List<String> facilities;

  /// URL foto utama kamar
  final String? mainImageUrl;

  /// Daftar URL foto kamar (galeri)
  final List<String> imageUrls;

  /// Status kamar saat ini
  final RoomStatus status;

  /// Lantai kamar berada
  final int? floorNumber;

  /// Apakah kamar bisa di-cancel gratis
  final bool freeCancellation;

  /// Tanggal terakhir status diubah (untuk tracking housekeeping)
  final DateTime? statusUpdatedAt;

  const RoomModel({
    required this.id,
    required this.hotelId,
    required this.roomNumber,
    required this.typeName,
    required this.pricePerNight,
    required this.maxGuests,
    this.description,
    this.bedType,
    this.areaM2,
    this.weekendPrice,
    this.peakSeasonPrice,
    this.discountPercent = 0,
    this.facilities = const [],
    this.mainImageUrl,
    this.imageUrls = const [],
    this.status = RoomStatus.available,
    this.floorNumber,
    this.freeCancellation = true,
    this.statusUpdatedAt,
  });

  // ---------------------------------------------------------------------------
  // CONVENIENCE GETTERS
  // ---------------------------------------------------------------------------

  /// Harga efektif setelah diskon
  int get effectivePrice {
    if (discountPercent <= 0) return pricePerNight;
    return (pricePerNight * (100 - discountPercent) / 100).round();
  }

  /// Mengecek apakah kamar tersedia untuk dipesan
  bool get isAvailable => status == RoomStatus.available;

  /// Mendapatkan gambar utama atau placeholder
  String get displayImage =>
      mainImageUrl ?? 'https://via.placeholder.com/400x300?text=Room+$roomNumber';

  // ---------------------------------------------------------------------------
  // SERIALIZATION
  // ---------------------------------------------------------------------------

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id']?.toString() ?? '',
      hotelId: json['hotel_id']?.toString() ?? '',
      roomNumber: json['room_number'] ?? '',
      typeName: json['type_name'] ?? json['type'] ?? '',
      pricePerNight: json['price_per_night'] ?? 0,
      maxGuests: json['max_guests'] ?? 2,
      description: json['description'],
      bedType: json['bed_type'],
      areaM2: (json['area_m2'] as num?)?.toDouble(),
      weekendPrice: json['weekend_price'],
      peakSeasonPrice: json['peak_season_price'],
      discountPercent: json['discount_percent'] ?? 0,
      facilities: (json['facilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      mainImageUrl: json['main_image_url'] ?? json['image'],
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: RoomStatusExtension.fromString(json['status'] ?? 'available'),
      floorNumber: json['floor_number'],
      freeCancellation: json['free_cancellation'] ?? true,
      statusUpdatedAt: json['status_updated_at'] != null
          ? DateTime.tryParse(json['status_updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'room_number': roomNumber,
      'type_name': typeName,
      'price_per_night': pricePerNight,
      'max_guests': maxGuests,
      'description': description,
      'bed_type': bedType,
      'area_m2': areaM2,
      'weekend_price': weekendPrice,
      'peak_season_price': peakSeasonPrice,
      'discount_percent': discountPercent,
      'facilities': facilities,
      'main_image_url': mainImageUrl,
      'image_urls': imageUrls,
      'status': status.apiValue,
      'floor_number': floorNumber,
      'free_cancellation': freeCancellation,
    };
  }

  RoomModel copyWith({
    RoomStatus? status,
    int? pricePerNight,
    int? discountPercent,
    DateTime? statusUpdatedAt,
  }) {
    return RoomModel(
      id: id,
      hotelId: hotelId,
      roomNumber: roomNumber,
      typeName: typeName,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      maxGuests: maxGuests,
      description: description,
      bedType: bedType,
      areaM2: areaM2,
      weekendPrice: weekendPrice,
      peakSeasonPrice: peakSeasonPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      facilities: facilities,
      mainImageUrl: mainImageUrl,
      imageUrls: imageUrls,
      status: status ?? this.status,
      floorNumber: floorNumber,
      freeCancellation: freeCancellation,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
    );
  }

  @override
  String toString() =>
      'RoomModel(id: $id, roomNumber: $roomNumber, type: $typeName, status: ${status.displayName})';
}
