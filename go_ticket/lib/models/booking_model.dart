// =============================================================================
// FILE: lib/models/booking_model.dart
// RESPONSIBILITY: Model data untuk Pemesanan (Booking) hotel di Go Ticket.
// Mencakup:
// - Informasi booking (ID, tamu, kamar, hotel, tanggal)
// - Status booking (lifecycle dari pending sampai selesai)
// - Informasi pembayaran
// - Data check-in / check-out
// - E-Tiket (QR code data)
// =============================================================================

/// Enum status pemesanan / lifecycle booking di Go Ticket
enum BookingStatus {
  /// Booking dibuat, menunggu pembayaran dari Customer
  pendingPayment,

  /// Pembayaran terdeteksi, menunggu konfirmasi manual dari Staff FO
  pendingVerification,

  /// Pembayaran sudah diverifikasi, booking dikonfirmasi — siap check-in
  confirmed,

  /// Tamu sudah melakukan check-in — kamar berstatus Occupied
  checkedIn,

  /// Tamu sudah melakukan check-out — kamar berstatus Dirty
  checkedOut,

  /// Booking dibatalkan (oleh customer atau sistem)
  cancelled,

  /// Booking expired karena tidak bayar dalam batas waktu
  expired,
}

/// Extension untuk BookingStatus
extension BookingStatusExtension on BookingStatus {
  String get apiValue {
    switch (this) {
      case BookingStatus.pendingPayment:
        return 'pending_payment';
      case BookingStatus.pendingVerification:
        return 'pending_verification';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.checkedIn:
        return 'checked_in';
      case BookingStatus.checkedOut:
        return 'checked_out';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.expired:
        return 'expired';
    }
  }

  static BookingStatus fromString(String value) {
    switch (value) {
      case 'pending_verification':
        return BookingStatus.pendingVerification;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'checked_in':
        return BookingStatus.checkedIn;
      case 'checked_out':
        return BookingStatus.checkedOut;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'expired':
        return BookingStatus.expired;
      default:
        return BookingStatus.pendingPayment;
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.pendingPayment:
        return 'Menunggu Pembayaran';
      case BookingStatus.pendingVerification:
        return 'Menunggu Verifikasi';
      case BookingStatus.confirmed:
        return 'Dikonfirmasi';
      case BookingStatus.checkedIn:
        return 'Check-in';
      case BookingStatus.checkedOut:
        return 'Selesai';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
      case BookingStatus.expired:
        return 'Kedaluwarsa';
    }
  }

  /// [true] jika booking masih aktif / bisa ditampilkan di upcoming trips
  bool get isActive =>
      this == BookingStatus.confirmed || this == BookingStatus.checkedIn;

  /// [true] jika booking sudah selesai (bisa diberikan review)
  bool get isCompleted => this == BookingStatus.checkedOut;

  /// [true] jika booking berakhir tidak baik (cancelled / expired)
  bool get isTerminated =>
      this == BookingStatus.cancelled || this == BookingStatus.expired;
}

// =============================================================================
// BOOKING MODEL
// =============================================================================

/// Model data pemesanan hotel di Go Ticket.
class BookingModel {
  /// ID unik booking dari database
  final String id;

  /// Kode booking yang ditampilkan ke user (misalnya: 'GT-20261005-001')
  final String bookingCode;

  /// ID Customer yang melakukan booking
  final String customerId;

  /// Nama Customer (untuk display tanpa join)
  final String customerName;

  /// Nomor HP Customer
  final String? customerPhone;

  /// ID Hotel yang dipesan
  final String hotelId;

  /// Nama Hotel (untuk display)
  final String hotelName;

  /// ID Kamar yang dipesan
  final String roomId;

  /// Nama / Tipe Kamar (untuk display)
  final String roomTypeName;

  /// Nomor kamar
  final String? roomNumber;

  /// Tanggal check-in
  final DateTime checkInDate;

  /// Tanggal check-out
  final DateTime checkOutDate;

  /// Jumlah malam menginap
  final int totalNights;

  /// Jumlah tamu
  final int guestCount;

  /// Permintaan khusus dari tamu (opsional)
  final String? specialRequest;

  /// Harga kamar per malam yang digunakan saat booking dibuat
  final int pricePerNight;

  /// Total harga sebelum diskon
  final int subtotal;

  /// Jumlah diskon
  final int discountAmount;

  /// Kode promo yang digunakan (jika ada)
  final String? promoCode;

  /// Total yang harus dibayar (setelah diskon)
  final int totalAmount;

  /// Metode pembayaran yang dipilih
  final String? paymentMethod;

  /// Status pembayaran
  final String? paymentStatus;

  /// ID transaksi dari payment gateway
  final String? paymentTransactionId;

  /// URL bukti transfer / payment (jika ada)
  final String? paymentProofUrl;

  /// Tanggal pembayaran berhasil
  final DateTime? paidAt;

  /// Status booking saat ini
  final BookingStatus status;

  /// Data QR code untuk E-Tiket check-in
  final String? qrCodeData;

  /// Waktu aktual check-in (diisi oleh Staff FO)
  final DateTime? actualCheckInTime;

  /// Waktu aktual check-out (diisi oleh Staff FO)
  final DateTime? actualCheckOutTime;

  /// Catatan dari Staff FO saat checkout (kerusakan/minibar)
  final String? checkoutNotes;

  /// Apakah sudah memberikan review
  final bool hasReviewed;

  /// Tanggal booking dibuat
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.bookingCode,
    required this.customerId,
    required this.customerName,
    required this.hotelId,
    required this.hotelName,
    required this.roomId,
    required this.roomTypeName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalNights,
    required this.guestCount,
    required this.pricePerNight,
    required this.subtotal,
    required this.totalAmount,
    this.customerPhone,
    this.roomNumber,
    this.specialRequest,
    this.discountAmount = 0,
    this.promoCode,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentTransactionId,
    this.paymentProofUrl,
    this.paidAt,
    this.status = BookingStatus.pendingPayment,
    this.qrCodeData,
    this.actualCheckInTime,
    this.actualCheckOutTime,
    this.checkoutNotes,
    this.hasReviewed = false,
    this.createdAt,
  });

  // ---------------------------------------------------------------------------
  // SERIALIZATION
  // ---------------------------------------------------------------------------

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      bookingCode: json['booking_code'] ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'],
      hotelId: json['hotel_id']?.toString() ?? '',
      hotelName: json['hotel_name'] ?? '',
      roomId: json['room_id']?.toString() ?? '',
      roomTypeName: json['room_type_name'] ?? '',
      roomNumber: json['room_number'],
      checkInDate: DateTime.parse(json['check_in_date']),
      checkOutDate: DateTime.parse(json['check_out_date']),
      totalNights: json['total_nights'] ?? 1,
      guestCount: json['guest_count'] ?? 1,
      specialRequest: json['special_request'],
      pricePerNight: json['price_per_night'] ?? 0,
      subtotal: json['subtotal'] ?? 0,
      discountAmount: json['discount_amount'] ?? 0,
      promoCode: json['promo_code'],
      totalAmount: json['total_amount'] ?? 0,
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      paymentTransactionId: json['payment_transaction_id'],
      paymentProofUrl: json['payment_proof_url'],
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
      status: BookingStatusExtension.fromString(json['status'] ?? 'pending_payment'),
      qrCodeData: json['qr_code_data'],
      actualCheckInTime: json['actual_check_in_time'] != null
          ? DateTime.tryParse(json['actual_check_in_time'])
          : null,
      actualCheckOutTime: json['actual_check_out_time'] != null
          ? DateTime.tryParse(json['actual_check_out_time'])
          : null,
      checkoutNotes: json['checkout_notes'],
      hasReviewed: json['has_reviewed'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_code': bookingCode,
      'customer_id': customerId,
      'customer_name': customerName,
      'hotel_id': hotelId,
      'hotel_name': hotelName,
      'room_id': roomId,
      'room_type_name': roomTypeName,
      'check_in_date': checkInDate.toIso8601String().substring(0, 10),
      'check_out_date': checkOutDate.toIso8601String().substring(0, 10),
      'total_nights': totalNights,
      'guest_count': guestCount,
      'price_per_night': pricePerNight,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'status': status.apiValue,
      'has_reviewed': hasReviewed,
    };
  }

  BookingModel copyWith({BookingStatus? status, bool? hasReviewed, String? qrCodeData}) {
    return BookingModel(
      id: id,
      bookingCode: bookingCode,
      customerId: customerId,
      customerName: customerName,
      hotelId: hotelId,
      hotelName: hotelName,
      roomId: roomId,
      roomTypeName: roomTypeName,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      totalNights: totalNights,
      guestCount: guestCount,
      pricePerNight: pricePerNight,
      subtotal: subtotal,
      totalAmount: totalAmount,
      status: status ?? this.status,
      hasReviewed: hasReviewed ?? this.hasReviewed,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }

  @override
  String toString() =>
      'BookingModel(id: $id, code: $bookingCode, status: ${status.displayName})';
}
