import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:go_ticket_user/core/models/booking_args.dart';
import '../../router/customer_router.dart';
import 'package:go_ticket_user/core/widgets/gt_ui.dart';

/// Layar sukses pembayaran — bukti transaksi QRIS yang jelas.
class PaymentSuccessScreen extends StatelessWidget {
  final dynamic arguments;
  const PaymentSuccessScreen({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    final a = BookingArgs.fromHotel(
        arguments is Map && arguments['args'] != null
            ? arguments['args']
            : arguments);

    final roomNum = arguments is Map && arguments['roomNumber'] != null
        ? arguments['roomNumber'].toString()
        : '003';

    // Ambil bookingCode dari argumen jika ada
    final bookingCode = (arguments is Map && arguments['bookingCode'] != null)
        ? arguments['bookingCode'].toString()
        : _fallbackCode();

    final now = DateTime.now();
    final stamp =
        '${now.day} ${BookingArgs.monthShort(now.month)} ${now.year}, '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')} WIB';
    final trxRef =
        'TRX-${now.millisecondsSinceEpoch % 100000}'.padLeft(10, '0');
    final name = a.guestName.isEmpty ? 'Tamu Go Ticket' : a.guestName;
    final qrData = '$bookingCode-CHECKIN';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: GT.bg,
        appBar: const GTAppBar(title: 'Checkout Flow', showBack: false),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 24),
          children: [
            // ---- Badge Sukses ----
            Center(
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GT.primary.withValues(alpha: 0.25),
                ),
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                        color: GT.teal, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 38),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: GTChip('PEMBAYARAN BERHASIL ✓',
                  icon: Icons.check_circle, bg: GT.sky),
            ),
            const SizedBox(height: 10),
            const Text('Terima Kasih!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 26,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: GT.ink)),
            const Text('Pemesanan Anda telah dikonfirmasi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: GT.body)),
            const SizedBox(height: 4),
            Text(stamp,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: GT.muted)),
            const SizedBox(height: 20),

            // ---- Foto Hotel ----
            GTCard(
              child: Column(children: [
                Stack(children: [
                  GTImage(a.imageUrl,
                      height: 160, width: double.infinity, radius: 14),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    right: 12,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GTChip('★  ${a.location}',
                              bg: Colors.white, fg: GT.ink),
                          const SizedBox(height: 4),
                          Text(a.hotelName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                        ]),
                  ),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  _info('Tipe Kamar', a.roomName, 'Kamar $roomNum'),
                  _info(
                    'Check-in',
                    '${a.checkIn.day} ${BookingArgs.monthShort(a.checkIn.month)}',
                    '14:00 WITA',
                  ),
                  _info(
                    'Check-out',
                    '${a.checkOut.day} ${BookingArgs.monthShort(a.checkOut.month)}',
                    '12:00 WITA',
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 14),

            // ---- Bukti Pembayaran QRIS ----
            GTCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.receipt_long_outlined,
                        color: GT.teal, size: 18),
                    const SizedBox(width: 8),
                    const Text('Bukti Pembayaran QRIS',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: GT.ink)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('LUNAS ✓',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A))),
                    ),
                  ]),
                  const Divider(height: 20),
                  _payRow('No. Referensi', trxRef),
                  _payRow('Kode Booking', bookingCode),
                  _payRow('Metode', 'QRIS'),
                  _payRow('Nominal Dibayar', rp(a.total)),
                  _payRow('Tanggal', stamp),
                  _payRow('Status', 'Pembayaran Dikonfirmasi'),
                  const Divider(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                        color: GT.soft,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Expanded(
                        child: Text('Total Dibayar',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: GT.ink)),
                      ),
                      Text(rp(a.total),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: GT.teal)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- E-Tiket (QR Check-in) ----
            GTCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.confirmation_number_outlined,
                        color: GT.teal, size: 18),
                    const SizedBox(width: 8),
                    const Text('E-Tiket Check-in',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: GT.ink)),
                    const Spacer(),
                    GTChip('AKTIF', bg: GT.sky),
                  ]),
                  const SizedBox(height: 14),
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    // QR code e-tiket (bukan QRIS bayar — ini untuk scan check-in)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GT.soft),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 90,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bookingCode,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: GT.teal)),
                          const SizedBox(height: 4),
                          const Text(
                              'Tunjukkan QR ini saat Check-in di meja resepsionis.',
                              style: TextStyle(
                                  fontSize: 11, color: GT.body, height: 1.4)),
                          const SizedBox(height: 6),
                          Text('Tamu: $name',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: GT.ink)),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- Info tambahan ----
            GTCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _note(Icons.mark_email_read_outlined, 'E-Tiket Siap Digunakan',
                      'Bukti reservasi resmi telah dikirim ke '
                          '${a.email.isEmpty ? 'email Anda' : a.email} dan akun WhatsApp aktif Anda.'),
                  const SizedBox(height: 10),
                  _note(Icons.info_outline, 'Kebijakan Check-In',
                      'Check-in dibuka mulai pukul 14:00 WITA. Siapkan kartu identitas (KTP/Paspor) serta deposit kunci saat tiba di area lobi utama resor.'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---- Tombol aksi ----
            GTButton(
              label: 'Lihat Detail Reservasi',
              leading: Icons.receipt_long_outlined,
              onTap: () => Navigator.pushNamed(
                context,
                CustomerRouter.reservationDetail,
                arguments: arguments is Map
                    ? {
                        ...arguments as Map,
                        'bookingCode': bookingCode,
                        'roomNumber': roomNum,
                        'args': a,
                        'hotelName': a.hotelName,
                        'hotelImageUrl': a.imageUrl,
                        'location': a.location,
                        'roomName': a.roomName,
                        'guestName': name,
                      }
                    : arguments,
              ),
            ),
            const SizedBox(height: 10),
            GTButton(
              label: 'Lihat E-Tiket Digital',
              leading: Icons.confirmation_number_outlined,
              color: Colors.white,
              textColor: GT.teal,
              onTap: () => Navigator.pushNamed(
                context,
                CustomerRouter.eTicket,
                arguments: arguments is Map
                    ? {
                        ...arguments as Map,
                        'bookingCode': bookingCode,
                        'roomNumber': roomNum,
                        'args': a,
                        'hotelName': a.hotelName,
                        'hotelImageUrl': a.imageUrl,
                        'location': a.location,
                        'roomName': a.roomName,
                        'guestName': name,
                      }
                    : arguments,
              ),
            ),
            const SizedBox(height: 10),
            GTButton(
              label: 'Kembali ke Beranda',
              leading: Icons.home_outlined,
              color: Colors.white,
              textColor: GT.muted,
              onTap: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil(CustomerRouter.dashboard, (r) => false),
            ),
          ],
        ),
      ),
    );
  }

  static String _fallbackCode() {
    final now = DateTime.now();
    return 'GT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecond.toString().padRight(3, '0')}';
  }

  Widget _info(String l, String v, String s) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: GT.muted)),
            Text(v,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: GT.ink)),
            Text(s,
                style: const TextStyle(fontSize: 10, color: GT.muted)),
          ],
        ),
      );

  Widget _payRow(String l, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Expanded(
              child: Text(l,
                  style: const TextStyle(fontSize: 12, color: GT.muted))),
          Text(v,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: GT.ink)),
        ]),
      );

  Widget _note(IconData i, String t, String s) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(i, color: GT.teal, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: GT.ink)),
                Text(s,
                    style: const TextStyle(
                        fontSize: 11, height: 1.4, color: GT.body)),
              ],
            ),
          ),
        ],
      );
}
