// =============================================================================
// FILE: lib/apps/pihak_user/screens/ticket/e_ticket_detail_screen.dart
// E-Tiket digital — terintegrasi dengan data dinamis, foto hotel & GT UI
// =============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/models/booking_args.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/widgets/gt_ui.dart';
import '../../router/customer_router.dart';

/// Halaman E-Tiket untuk Check-in Customer.
class ETicketDetailScreen extends StatelessWidget {
  final dynamic arguments;
  const ETicketDetailScreen({super.key, this.arguments});

  // --------------- Unpack Helpers ---------------

  BookingModel? get _booking {
    if (arguments is BookingModel) return arguments as BookingModel;
    if (arguments is Map && arguments['booking'] is BookingModel) {
      return arguments['booking'] as BookingModel;
    }
    return null;
  }

  BookingArgs? get _bookingArgs {
    if (arguments is BookingArgs) return arguments as BookingArgs;
    if (arguments is Map) {
      if (arguments['args'] is BookingArgs) {
        return arguments['args'] as BookingArgs;
      }
      if (arguments['args'] is Map) {
        return BookingArgs.fromHotel(arguments['args']);
      }
      if (arguments['hotelName'] != null || arguments['roomName'] != null) {
        return BookingArgs.fromHotel(arguments);
      }
    }
    return null;
  }

  Map? get _argMap => arguments is Map ? (arguments as Map) : null;

  // --------------- Data Getters ---------------

  String get hotelName {
    if (_booking != null && _booking!.hotelName.isNotEmpty) {
      return _booking!.hotelName;
    }
    if (_bookingArgs != null && _bookingArgs!.hotelName.isNotEmpty) {
      return _bookingArgs!.hotelName;
    }
    if (_argMap != null) {
      final v = _argMap!['hotelName'] ??
          _argMap!['hotel_name'] ??
          _argMap!['nama_properti'];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return 'Hotel';
  }

  String get hotelLocation {
    if (_booking != null &&
        _booking!.hotelAddress != null &&
        _booking!.hotelAddress!.isNotEmpty) {
      return _booking!.hotelAddress!;
    }
    if (_bookingArgs != null && _bookingArgs!.location.isNotEmpty) {
      return _bookingArgs!.location;
    }
    if (_argMap != null) {
      final v = _argMap!['location'] ??
          _argMap!['hotelAddress'] ??
          _argMap!['alamat_lengkap'] ??
          _argMap!['kota_wilayah'];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return 'Indonesia';
  }

  String get hotelImageUrl {
    if (_booking != null &&
        _booking!.hotelImageUrl != null &&
        _booking!.hotelImageUrl!.isNotEmpty) {
      return _booking!.hotelImageUrl!;
    }
    if (_bookingArgs != null && _bookingArgs!.imageUrl.isNotEmpty) {
      return _bookingArgs!.imageUrl;
    }
    if (_argMap != null) {
      final v = _argMap!['hotelImageUrl'] ??
          _argMap!['imageUrl'] ??
          _argMap!['main_image_url'] ??
          _argMap!['thumbnail_url'];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return '';
  }

  String get guestName {
    if (_booking != null && _booking!.customerName.isNotEmpty) {
      return _booking!.customerName;
    }
    if (_bookingArgs != null && _bookingArgs!.guestName.isNotEmpty) {
      return _bookingArgs!.guestName;
    }
    if (_argMap != null) {
      final v = _argMap!['guestName'] ??
          _argMap!['customerName'] ??
          _argMap!['nama_tamu'];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return 'Tamu Go Ticket';
  }

  String get bookingCode {
    if (_booking != null && _booking!.bookingCode.isNotEmpty) {
      return _booking!.bookingCode;
    }
    if (_argMap != null) {
      final v = _argMap!['bookingCode'] ?? _argMap!['booking_code'];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return 'GT-RESERVASI';
  }

  String get roomName {
    if (_booking != null && _booking!.roomTypeName.isNotEmpty) {
      return _booking!.roomTypeName;
    }
    if (_bookingArgs != null && _bookingArgs!.roomName.isNotEmpty) {
      return _bookingArgs!.roomName;
    }
    if (_argMap != null) {
      final v = _argMap!['roomName'] ??
          _argMap!['roomTypeName'] ??
          _argMap!['nama_tipe'];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return 'Standard Room';
  }

  String get roomNumber {
    if (_booking != null &&
        _booking!.roomNumber != null &&
        _booking!.roomNumber!.isNotEmpty) {
      return _booking!.roomNumber!;
    }
    if (_argMap != null && _argMap!['roomNumber'] != null) {
      return _argMap!['roomNumber'].toString();
    }
    return '003';
  }

  String get dateRange {
    if (_booking != null) {
      final b = _booking!;
      return '${b.checkInDate.day}/${b.checkInDate.month}/${b.checkInDate.year}'
          ' – ${b.checkOutDate.day}/${b.checkOutDate.month}/${b.checkOutDate.year}';
    }
    if (_bookingArgs != null &&
        _bookingArgs!.dateRange.isNotEmpty &&
        _bookingArgs!.dateRange != '-') {
      return _bookingArgs!.dateRange;
    }
    if (_argMap != null && _argMap!['dateRange'] != null) {
      return _argMap!['dateRange'].toString();
    }
    final now = DateTime.now();
    final checkOut = now.add(const Duration(days: 2));
    return '${now.day}/${now.month}/${now.year} – ${checkOut.day}/${checkOut.month}/${checkOut.year}';
  }

  String get guestCount {
    if (_booking != null) {
      final b = _booking!;
      return '${b.guestCount} Tamu (${b.totalNights} Malam)';
    }
    if (_bookingArgs != null) {
      final b = _bookingArgs!;
      final night = b.nights > 0 ? ' (${b.nights} Malam)' : '';
      return '${b.adults} Dewasa${b.children > 0 ? ', ${b.children} Anak' : ''}$night';
    }
    return '2 Tamu (2 Malam)';
  }

  String get qrData {
    if (_booking != null &&
        _booking!.qrCodeData != null &&
        _booking!.qrCodeData!.isNotEmpty) {
      return _booking!.qrCodeData!;
    }
    return '$bookingCode-CHECKIN';
  }

  // --------------- Build ---------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: GT.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('E-Tiket',
            style: TextStyle(
                color: GT.ink, fontWeight: FontWeight.w800, fontSize: 17)),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tautan E-Tiket disalin'))),
            icon: const Icon(Icons.share_outlined, color: GT.teal),
          ),
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('E-Tiket sedang diunduh'))),
            icon: const Icon(Icons.download_outlined, color: GT.teal),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            // ---- Status badge ----
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF16A34A)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 16, color: Color(0xFF16A34A)),
                  SizedBox(width: 6),
                  Text('Booking Dikonfirmasi',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Tiket card ----
            _buildTicketCard(),
            const SizedBox(height: 14),

            // ---- QR Code check-in ----
            _buildQrSection(),
            const SizedBox(height: 14),

            // ---- Instruksi check-in ----
            _buildCheckinInfo(),
            const SizedBox(height: 20),

            // ---- Tombol aksi ----
            GTButton(
              label: 'Lihat Detail Reservasi',
              leading: Icons.receipt_long_outlined,
              onTap: () => Navigator.pushNamed(
                context,
                CustomerRouter.reservationDetail,
                arguments: arguments,
              ),
            ),
            const SizedBox(height: 10),
            GTButton(
              label: 'Kembali ke Beranda',
              leading: Icons.home_outlined,
              color: Colors.white,
              textColor: GT.teal,
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                CustomerRouter.dashboard,
                (r) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Ticket card dengan foto hotel & gradient header ----
  Widget _buildTicketCard() {
    final photo = hotelImageUrl;
    final isLocal = photo.startsWith('/') || photo.startsWith('file://');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: GT.teal.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header dengan foto hotel / gradient
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                // Background image or gradient
                if (photo.isNotEmpty && !isLocal)
                  Image.network(
                    photo,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackHeader(),
                  )
                else if (photo.isNotEmpty && isLocal)
                  Image.file(
                    File(photo.replaceFirst('file://', '')),
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackHeader(),
                  )
                else
                  _fallbackHeader(),

                // Dark gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.78),
                        ],
                      ),
                    ),
                  ),
                ),

                // Hotel Name and Address
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Column(
                    children: [
                      Text(
                        hotelName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              hotelLocation,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dotted divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                _clip(isLeft: true),
                Expanded(
                  child: LayoutBuilder(builder: (ctx, constraints) {
                    return Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        (constraints.constrainWidth() / 8).floor(),
                        (_) => const SizedBox(
                          width: 4,
                          height: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: GT.soft),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                _clip(isLeft: false),
              ],
            ),
          ),

          // Detail baris
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                _row('Nama Tamu', guestName),
                _row('Kode Booking', bookingCode),
                _row('Tipe Kamar', roomName),
                _row('Nomor Kamar', 'Kamar $roomNumber'),
                _row('Jadwal Menginap', dateRange),
                _row('Jumlah Tamu', guestCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackHeader() {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00677F), Color(0xFF00C7F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.hotel_rounded, color: Colors.white24, size: 48),
      ),
    );
  }

  Widget _clip({required bool isLeft}) {
    return Container(
      width: 16,
      height: 32,
      decoration: BoxDecoration(
        color: GT.bg,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? Radius.zero : const Radius.circular(16),
          right: isLeft ? const Radius.circular(16) : Radius.zero,
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: GT.body)),
          ),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: GT.ink)),
          ),
        ],
      ),
    );
  }

  // ---- QR Code section ----
  Widget _buildQrSection() {
    return GTCard(
      child: Column(
        children: [
          const Text('Tunjukkan QR Code ini saat Check-in',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: GT.ink)),
          const SizedBox(height: 4),
          const Text('Staff FO akan memindai untuk validasi reservasi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: GT.muted)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GT.soft, width: 2),
            ),
            child: Column(
              children: [
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
                const SizedBox(height: 8),
                Text(bookingCode,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: GT.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Instruksi check-in ----
  Widget _buildCheckinInfo() {
    final items = [
      'Waktu check-in standar mulai pukul 14:00 waktu setempat.',
      'Siapkan KTP/Paspor asli yang sesuai dengan nama pada tiket.',
      'Deposit dapat diperlukan saat check-in sesuai kebijakan hotel.',
      'Hubungi Front Office jika Anda tiba lebih lambat dari jadwal.',
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GT.sky.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GT.teal.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.info_outline_rounded, size: 16, color: GT.teal),
            SizedBox(width: 6),
            Text('Petunjuk Check-in',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: GT.teal)),
          ]),
          const SizedBox(height: 10),
          ...items.map((inst) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            color: GT.teal, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(inst,
                          style: const TextStyle(
                              fontSize: 12, color: GT.body, height: 1.4)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
