import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_ticket/core/models/booking_args.dart';
import 'package:go_ticket/core/models/booking_model.dart';
import 'package:go_ticket/core/utils/currency_formatter.dart';
import '../../router/customer_router.dart';

/// Halaman Detail Reservasi Lengkap untuk User/Tamu.
/// Menampilkan rincian reservasi, alokasi kamar, status, toleransi reject (1 hari),
/// aksi reject dengan konfirmasi, dan tautan ke E-Tiket.
class ReservationDetailScreen extends StatefulWidget {
  final dynamic arguments;
  const ReservationDetailScreen({super.key, this.arguments});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  BookingModel? _booking;
  BookingArgs? _args;
  bool _isLoading = false;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _parseArguments();
  }

  void _parseArguments() {
    final raw = widget.arguments;
    if (raw is BookingModel) {
      _booking = raw;
      _isCancelled = raw.status == BookingStatus.cancelled || raw.status == BookingStatus.expired;
    } else if (raw is Map && raw['booking'] is BookingModel) {
      _booking = raw['booking'] as BookingModel;
      _isCancelled = _booking!.status == BookingStatus.cancelled || _booking!.status == BookingStatus.expired;
    } else if (raw is BookingArgs) {
      _args = raw;
    } else if (raw is Map && raw['args'] != null) {
      _args = BookingArgs.fromHotel(raw['args']);
    } else {
      _args = BookingArgs.fromHotel(raw);
    }
  }

  String get _hotelName => _booking?.hotelName ?? _args?.hotelName ?? 'Hotel';
  String get _hotelAddress => _booking?.hotelAddress ?? _args?.location ?? 'Indonesia';
  String get _roomTypeName => _booking?.roomTypeName ?? _args?.roomName ?? 'Standard Room';
  String get _roomNumber => _booking?.roomNumber ?? (widget.arguments is Map ? widget.arguments['roomNumber']?.toString() : null) ?? '003';
  String get _bookingCode => _booking?.bookingCode ?? 'GT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  String get _guestName => _booking?.customerName.isNotEmpty == true ? _booking!.customerName : (_args?.guestName.isNotEmpty == true ? _args!.guestName : 'Tamu Go Ticket');
  String get _guestPhone => _booking?.customerPhone ?? _args?.phone ?? '-';
  int get _nights => _booking?.totalNights ?? _args?.nights ?? 1;
  int get _guestCount => _booking?.guestCount ?? ((_args?.adults ?? 2) + (_args?.children ?? 0));
  int get _totalAmount => _booking?.totalAmount ?? _args?.total ?? 850000;
  String get _paymentMethod => _booking?.paymentMethod ?? _args?.paymentMethod ?? 'QRIS';
  DateTime get _checkInDate => _booking?.checkInDate ?? _args?.checkIn ?? DateTime.now();
  DateTime get _checkOutDate => _booking?.checkOutDate ?? _args?.checkOut ?? DateTime.now().add(const Duration(days: 1));
  DateTime get _bookingTime => _booking?.paidAt ?? _booking?.createdAt ?? DateTime.now();

  BookingStatus get _currentStatus {
    if (_isCancelled) return BookingStatus.cancelled;
    return _booking?.status ?? BookingStatus.pendingVerification;
  }

  /// Mengecek apakah masih dalam batas toleransi pembatalan (1 hari = 24 jam)
  bool get _isWithinRejectTolerance {
    final diff = DateTime.now().difference(_bookingTime);
    return diff.inHours < 24;
  }

  int get _hoursRemaining {
    final diff = DateTime.now().difference(_bookingTime);
    final rem = 24 - diff.inHours;
    return rem > 0 ? rem : 0;
  }

  bool get _canReject {
    if (_isCancelled) return false;
    return _currentStatus == BookingStatus.confirmed;
  }

  Future<void> _handleReject() async {
    final res = await Navigator.pushNamed(
      context,
      CustomerRouter.rejectReason,
      arguments: _booking ?? _args,
    );
    if (res == true && mounted) {
      setState(() {
        _isCancelled = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil di-reject / dibatalkan.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _isCancelled
        ? 'Dibatalkan (Reject)'
        : _currentStatus == BookingStatus.checkedOut
            ? 'Selesai'
            : _currentStatus == BookingStatus.confirmed || _currentStatus == BookingStatus.checkedIn
                ? 'Dikonfirmasi'
                : 'Menunggu Konfirmasi';

    Color statusColor = const Color(0xFF0096C7);
    Color statusBg = const Color(0xFFE0F7FA);

    if (_isCancelled) {
      statusColor = Colors.red;
      statusBg = const Color(0xFFFEE2E2);
    } else if (_currentStatus == BookingStatus.checkedOut) {
      statusColor = const Color(0xFF16A34A);
      statusBg = const Color(0xFFDCFCE7);
    } else if (_currentStatus == BookingStatus.confirmed || _currentStatus == BookingStatus.checkedIn) {
      statusColor = const Color(0xFF2563EB);
      statusBg = const Color(0xFFDBEAFE);
    }

    final dateStr =
        '${_checkInDate.day} ${_monthName(_checkInDate.month)} ${_checkInDate.year} – ${_checkOutDate.day} ${_monthName(_checkOutDate.month)} ${_checkOutDate.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail Reservasi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Status Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text(
                                  statusText,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: _bookingCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kode booking disalin'), duration: Duration(seconds: 1)),
                              );
                            },
                            child: Row(
                              children: [
                                Text(_bookingCode, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF64748B))),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF94A3B8)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(_hotelName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(_hotelAddress, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Toleransi Reject Banner (jika belum di-cancel & status Menunggu Konfirmasi)
                if (!_isCancelled && (_currentStatus == BookingStatus.pendingVerification || _currentStatus == BookingStatus.pendingPayment))
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _isWithinRejectTolerance ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isWithinRejectTolerance ? const Color(0xFFFDE68A) : const Color(0xFFFECACA),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _isWithinRejectTolerance ? Icons.access_time_rounded : Icons.info_outline_rounded,
                          color: _isWithinRejectTolerance ? const Color(0xFFD97706) : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isWithinRejectTolerance
                                    ? 'Ketentuan Reject / Pembatalan: Sisa $_hoursRemaining Jam'
                                    : 'Batas Toleransi Reject Telah Lewat',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: _isWithinRejectTolerance ? const Color(0xFF92400E) : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isWithinRejectTolerance
                                    ? 'Pihak hotel menetapkan batas toleransi reject/pembatalan maksimal 1 hari setelah pembelian e-tiket. Anda masih dapat membatalkan tiket ini.'
                                    : 'Batas toleransi pembatalan 1 hari telah berakhir. E-tiket tidak dapat di-reject dan akan hangus jika Anda tidak tepat waktu melakukan check-in di penginapan.',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),

                // Rincian Kamar & Jadwal
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RINCIAN KAMAR & JADWAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0096C7))),
                      const SizedBox(height: 12),
                      _rowInfo('Tipe Kamar', _roomTypeName),
                      _rowInfo('Nomor Kamar', 'Kamar $_roomNumber', highlight: true),
                      _rowInfo('Durasi Menginap', '$_nights Malam'),
                      _rowInfo('Jadwal Menginap', dateStr),
                      _rowInfo('Jumlah Tamu', '$_guestCount Tamu'),
                      _rowInfo('Waktu Check-in', 'Mulai 14:00 WIB'),
                      _rowInfo('Waktu Check-out', 'Maksimal 12:00 WIB'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Data Tamu Pemesan
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DATA TAMU PEMESAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0096C7))),
                      const SizedBox(height: 12),
                      _rowInfo('Nama Tamu', _guestName),
                      _rowInfo('No. Handphone / WA', _guestPhone),
                      _rowInfo('Permintaan Khusus', _booking?.specialRequest ?? 'Kamar Bebas Asap Rokok'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Rincian Pembayaran
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RINCIAN PEMBAYARAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0096C7))),
                      const SizedBox(height: 12),
                      _rowInfo('Metode Pembayaran', _paymentMethod),
                      _rowInfo('Waktu Transaksi', '${_bookingTime.day} ${_monthName(_bookingTime.month)} ${_bookingTime.year}, ${_bookingTime.hour.toString().padLeft(2, '0')}:${_bookingTime.minute.toString().padLeft(2, '0')} WIB'),
                      _rowInfo('Status Pembayaran', _isCancelled ? 'Dibatalkan (Refund Diproses)' : '✓ Lunas & Terverifikasi', statusOk: !_isCancelled),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          Text(
                            CurrencyFormatter.toRupiah(_totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0096C7)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Aksi
                if (!_isCancelled) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          CustomerRouter.eTicket,
                          arguments: _booking ?? widget.arguments,
                        );
                      },
                      icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                      label: const Text('Lihat E-Tiket & QR Code', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tombol Reject (Aktif jika dalam toleransi 1 hari, dinonaktifkan jika lewat)
                  if (_currentStatus == BookingStatus.pendingVerification || _currentStatus == BookingStatus.pendingPayment) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _canReject ? _handleReject : null,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: Text(
                          _canReject
                              ? 'Reject / Batalkan Pesanan (Sisa $_hoursRemaining Jam)'
                              : 'Batas Waktu Reject Berakhir (Tiket Hangus Jika Tidak Hadir)',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _canReject ? Colors.red : const Color(0xFF94A3B8),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _canReject ? Colors.red : const Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],

                  // Tombol Beri Ulasan jika status Selesai
                  if (_currentStatus == BookingStatus.checkedOut) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            CustomerRouter.postCheckoutReview,
                            arguments: _booking ?? widget.arguments,
                          );
                        },
                        icon: const Icon(Icons.star_rounded, size: 20, color: Colors.amber),
                        label: const Text('Beri Ulasan (Terverifikasi)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Pesanan ini telah di-reject / dibatalkan.',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _rowInfo(String label, String value, {bool highlight = false, bool statusOk = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                color: highlight
                    ? const Color(0xFF0096C7)
                    : statusOk
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return (m >= 1 && m <= 12) ? months[m - 1] : '';
  }
}

