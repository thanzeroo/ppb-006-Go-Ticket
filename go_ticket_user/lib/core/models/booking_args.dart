import '../utils/currency_formatter.dart';

/// Data yang dibawa sepanjang alur pemesanan:
/// Detail Hotel -> Pilih Kamar -> Checkout -> Pembayaran -> Sukses.
class BookingArgs {
  final String hotelId;
  final String hotelName;
  final String hotelType;
  final String location;
  final String imageUrl;
  final String rating;

  final String roomId;
  final String roomName;
  final String roomImage;
  final int roomPrice; // per malam
  final int? originalPrice;

  final DateTime checkIn;
  final DateTime checkOut;

  final int adults;
  final int children;

  final String guestName;
  final String email;
  final String phone;

  final bool promoApplied;
  final String paymentMethod;

  const BookingArgs({
    this.hotelId = '',
    required this.hotelName,
    required this.hotelType,
    required this.location,
    required this.imageUrl,
    required this.rating,
    this.roomId = '',
    required this.roomName,
    required this.roomImage,
    required this.roomPrice,
    this.originalPrice,
    required this.checkIn,
    required this.checkOut,
    this.adults = 2,
    this.children = 0,
    this.guestName = '',
    this.email = '',
    this.phone = '',
    this.promoApplied = true,
    this.paymentMethod = 'QRIS / GoPay Instan',
  });

  static const defaultImage =
      'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800';
  static const defaultRoomImage =
      'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800';

  /// Dibuat dari argumen hotel (Map dari tab Beranda/Cari/Tersimpan) atau default.
  factory BookingArgs.fromHotel(dynamic arg) {
    if (arg is BookingArgs) {
      return arg.roomPrice > 0 ? arg : arg.copyWith(roomPrice: 850000);
    }
    final m = arg is Map ? arg : const {};
    final start = DateTime.now().add(const Duration(days: 2));
    final checkIn = DateTime(start.year, start.month, start.day);
    final listedPrice = m['discountedPrice'] ??
        m['price'] ??
        m['pricePerNight'];
    final parsedPrice = listedPrice is num
        ? listedPrice.toInt()
        : CurrencyFormatter.parseToInt(listedPrice?.toString() ?? '');
    final listedOriginalPrice = m['originalPrice'];
    final parsedOriginalPrice = listedOriginalPrice is num
        ? listedOriginalPrice.toInt()
        : CurrencyFormatter.parseToInt(
            listedOriginalPrice?.toString() ?? '',
          );
    final validPrice = parsedPrice > 0 ? parsedPrice : 850000;
    return BookingArgs(
      hotelId: (m['id'] ?? m['id_penginapan'] ?? '').toString(),
      hotelName: (m['name'] ?? m['nama_properti'] ?? 'Penginapan').toString(),
      hotelType: (m['type'] ?? 'HOTEL').toString(),
      location: (m['location'] ?? m['alamat_lengkap'] ?? 'Indonesia').toString(),
      imageUrl: (m['imageUrl'] ?? m['foto_utama'] ?? defaultImage).toString(),
      rating: (m['rating'] ?? '5.0').toString(),
      roomId: (m['id_tipe_kamar'] ?? m['roomId'] ?? '').toString(),
      roomName: (m['roomName'] ?? m['nama_tipe'] ?? 'Standard Room').toString(),
      roomImage: defaultRoomImage,
      roomPrice: validPrice,
      originalPrice:
          parsedOriginalPrice > validPrice ? parsedOriginalPrice : null,
      checkIn: checkIn,
      checkOut: checkIn.add(const Duration(days: 2)),
    );
  }

  BookingArgs copyWith({
    String? hotelId,
    String? hotelName,
    String? hotelType,
    String? location,
    String? imageUrl,
    String? rating,
    String? roomId,
    String? roomName,
    String? roomImage,
    int? roomPrice,
    int? originalPrice,
    DateTime? checkIn,
    DateTime? checkOut,
    int? adults,
    int? children,
    String? guestName,
    String? email,
    String? phone,
    bool? promoApplied,
    String? paymentMethod,
  }) {
    final nextRoomPrice = roomPrice ?? this.roomPrice;
    return BookingArgs(
      hotelId: hotelId ?? this.hotelId,
      hotelName: hotelName ?? this.hotelName,
      hotelType: hotelType ?? this.hotelType,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      roomImage: roomImage ?? this.roomImage,
      roomPrice: nextRoomPrice > 0 ? nextRoomPrice : 850000,
      originalPrice: originalPrice ?? this.originalPrice,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      guestName: guestName ?? this.guestName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      promoApplied: promoApplied ?? this.promoApplied,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  int get nights {
    final d = checkOut.difference(checkIn).inDays;
    return d > 0 ? d : 1;
  }

  int get subtotal => roomPrice * nights;
  int get basePrice => subtotal;
  int get serviceFee => (basePrice * 0.05).round();
  int get tax => (basePrice * 0.10).round();
  int get discount {
    if (!promoApplied || subtotal <= 1) return 0;
    return (subtotal * 0.15).round();
  }
  int get total => subtotal + serviceFee + tax - discount;
  int get totalPrice => total;
  int get originalTotalPrice =>
      ((originalPrice ?? roomPrice) * nights) + serviceFee + tax;

  static const _m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  static String monthShort(int m) => (m >= 1 && m <= 12) ? _m[m - 1] : '';

  /// "24 - 26 Okt 2026"
  String get dateRange {
    final a = checkIn, b = checkOut;
    if (a.month == b.month && a.year == b.year) {
      return '${a.day} - ${b.day} ${_m[b.month - 1]} ${b.year}';
    }
    return '${a.day} ${_m[a.month - 1]} - ${b.day} ${_m[b.month - 1]} ${b.year}';
  }
}
