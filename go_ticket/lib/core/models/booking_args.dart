/// Data yang dibawa sepanjang alur pemesanan:
/// Detail Hotel -> Pilih Kamar -> Checkout -> Pembayaran -> Sukses.
class BookingArgs {
  final String hotelName;
  final String hotelType;
  final String location;
  final String imageUrl;
  final String rating;

  final String roomName;
  final String roomImage;
  final int roomPrice; // per malam

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
    required this.hotelName,
    required this.hotelType,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.roomName,
    required this.roomImage,
    required this.roomPrice,
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
    if (arg is BookingArgs) return arg;
    final m = arg is Map ? arg : const {};
    final start = DateTime.now().add(const Duration(days: 2));
    final checkIn = DateTime(start.year, start.month, start.day);
    return BookingArgs(
      hotelName: (m['name'] ?? 'The Grand Amora Resort & Spa').toString(),
      hotelType: 'RESORT BINTANG 5',
      location: (m['location'] ?? 'Seminyak, Bali').toString(),
      imageUrl: (m['imageUrl'] ?? defaultImage).toString(),
      rating: (m['rating'] ?? '4.9').toString(),
      roomName: 'Deluxe Ocean View',
      roomImage: defaultRoomImage,
      roomPrice: 850000,
      checkIn: checkIn,
      checkOut: checkIn.add(const Duration(days: 2)),
    );
  }

  BookingArgs copyWith({
    String? roomName,
    String? roomImage,
    int? roomPrice,
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
    return BookingArgs(
      hotelName: hotelName,
      hotelType: hotelType,
      location: location,
      imageUrl: imageUrl,
      rating: rating,
      roomName: roomName ?? this.roomName,
      roomImage: roomImage ?? this.roomImage,
      roomPrice: roomPrice ?? this.roomPrice,
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

  int get nights => checkOut.difference(checkIn).inDays;
  int get subtotal => roomPrice * nights;
  int get discount => promoApplied ? 100000 : 0;
  int get total => subtotal - discount;

  static const _m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  static String monthShort(int m) => _m[m - 1];

  /// "24 - 26 Okt 2026"
  String get dateRange {
    final a = checkIn, b = checkOut;
    if (a.month == b.month && a.year == b.year) {
      return '${a.day} - ${b.day} ${_m[b.month - 1]} ${b.year}';
    }
    return '${a.day} ${_m[a.month - 1]} - ${b.day} ${_m[b.month - 1]} ${b.year}';
  }
}
