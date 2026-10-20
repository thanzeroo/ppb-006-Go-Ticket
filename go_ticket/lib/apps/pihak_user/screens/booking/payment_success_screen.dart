import 'package:flutter/material.dart';

import '../../data/booking_args.dart';
import '../../router/customer_router.dart';
import '../../widgets/gt_ui.dart';

/// Pembayaran berhasil + E-Tiket (Figma: "USER Page Payment Valid").
class PaymentSuccessScreen extends StatelessWidget {
  final dynamic arguments;
  const PaymentSuccessScreen({super.key, this.arguments});

  static const _code = 'GT-884920';
  static const _ref = '#TRX-99214';

  @override
  Widget build(BuildContext context) {
    final a = BookingArgs.fromHotel(arguments);
    final now = DateTime.now();
    final stamp =
        '${now.day} ${BookingArgs.monthShort(now.month)} ${now.year}, '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';
    final name = a.guestName.isEmpty ? 'Tamu Go Ticket' : a.guestName;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: GT.bg,
        appBar: const GTAppBar(title: 'Checkout Flow', showBack: false),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 24),
          children: [
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
              child: GTChip('PEMBAYARAN TERVERIFIKASI & BERHASIL',
                  icon: Icons.circle, bg: GT.sky),
            ),
            const SizedBox(height: 12),
            const Text('Terima Kasih, Pemesanan Anda Berhasil!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: GT.ink)),
            const SizedBox(height: 6),
            Text('$stamp  •  Ref: $_ref',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: GT.teal)),
            const SizedBox(height: 16),
            GTCard(
              child: Column(children: [
                Stack(children: [
                  GTImage(a.imageUrl,
                      height: 170, width: double.infinity, radius: 16),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
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
                        GTChip('Resor Bintang 5 • ${a.location}',
                            icon: Icons.star_rounded,
                            bg: Colors.white,
                            fg: GT.ink),
                        const SizedBox(height: 6),
                        Text(a.hotelName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: GT.soft.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    Expanded(
                        child: _info('TIPE KAMAR', a.roomName,
                            '1 Kamar • ${a.adults} Dewasa')),
                    Expanded(
                        child: _info('JADWAL MENGINAP', a.dateRange,
                            'Durasi: ${a.nights} Malam')),
                  ]),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: GT.soft.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    const CircleAvatar(
                        radius: 20,
                        backgroundColor: GT.sky,
                        child: Icon(Icons.person_outline, color: GT.teal)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TAMU UTAMA',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: GT.muted)),
                          Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: GT.ink)),
                          Text(a.phone,
                              style: const TextStyle(
                                  fontSize: 11, color: GT.muted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.badge_outlined, color: GT.teal),
                  ]),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE2E5FF),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    Row(children: const [
                      Expanded(
                        child: Text('KODE BOOKING E-TIKET',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: GT.muted)),
                      ),
                      GTChip('AKTIF', bg: GT.teal, fg: Colors.white),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: const SizedBox(
                          width: 96,
                          height: 96,
                          child: CustomPaint(painter: _QrPainter(_code)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_code,
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: GT.teal)),
                            SizedBox(height: 4),
                            Text(
                                'Tunjukkan QR ini saat Check-in di meja resepsionis.',
                                style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: GT.body)),
                          ],
                        ),
                      ),
                    ]),
                  ]),
                ),
              ]),
            ),
            GTCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Rincian Pembayaran',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: GT.ink)),
                const SizedBox(height: 12),
                _pay('Metode Pembayaran',
                    Text(a.paymentMethod,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: GT.ink))),
                _pay('Status Penerbitan',
                    const Text('Lunas & Terbit Otomatis',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: GT.teal))),
                _pay('PPN & Biaya Layanan',
                    const Text('Termasuk',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: GT.ink))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                      color: GT.soft.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Expanded(
                      child: Text('Total Dibayar',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: GT.ink)),
                    ),
                    Text(rp(a.total),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: GT.teal)),
                  ]),
                ),
              ]),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: GT.sky.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _note(Icons.mark_email_read_outlined,
                      'E-Tiket Siap Digunakan',
                      'Bukti reservasi resmi telah dikirim ke ${a.email.isEmpty ? 'email Anda' : a.email} dan akun WhatsApp aktif Anda.'),
                  const SizedBox(height: 10),
                  _note(Icons.info_outline, 'Kebijakan Check-In',
                      'Check-in dibuka mulai pukul 14:00 WITA. Siapkan kartu identitas (KTP/Paspor) serta deposit kunci saat tiba di area lobi utama resor.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GTButton(
              label: 'Lihat E-Tiket & Detail Reservasi',
              leading: Icons.confirmation_number_outlined,
              onTap: () => Navigator.pushNamed(context, CustomerRouter.eTicket,
                  arguments: a),
            ),
            const SizedBox(height: 10),
            GTButton(
              label: 'BATALKAN TIKET',
              color: const Color(0xFFFF0000),
              textColor: Colors.white,
              onTap: () => _confirmCancel(context),
            ),
            const SizedBox(height: 10),
            GTButton(
              label: 'Kembali ke Menu Utama / Beranda',
              leading: Icons.home_outlined,
              color: Colors.white,
              textColor: GT.teal,
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  CustomerRouter.dashboard, (r) => false),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Tiket?'),
        content: const Text(
            'Pembatalan mengikuti kebijakan hotel. Dana dikembalikan sesuai '
            'ketentuan refund yang berlaku.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tidak')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Permintaan pembatalan dikirim')));
              Navigator.of(context).pushNamedAndRemoveUntil(
                  CustomerRouter.dashboard, (r) => false);
            },
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: GT.red)),
          ),
        ],
      ),
    );
  }

  Widget _info(String l, String v, String s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: GT.muted)),
          Text(v,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: GT.ink)),
          Text(s, style: const TextStyle(fontSize: 11, color: GT.muted)),
        ],
      );

  Widget _pay(String l, Widget r) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Expanded(
              child: Text(l,
                  style: const TextStyle(fontSize: 13, color: GT.body))),
          r,
        ]),
      );

  Widget _note(IconData i, String t, String s) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(i, color: GT.teal, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: GT.ink)),
                Text(s,
                    style: const TextStyle(
                        fontSize: 11, height: 1.4, color: GT.body)),
              ],
            ),
          ),
        ],
      );
}

/// QR code dummy (pola deterministik dari kode booking), sampai terhubung ke generator QR asli.
class _QrPainter extends CustomPainter {
  final String data;
  const _QrPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    const n = 21;
    final cell = size.width / n;
    final paint = Paint()..color = GT.ink;
    var seed = data.codeUnits.fold<int>(7, (p, c) => (p * 31 + c) & 0x7fffffff);
    bool finder(int x, int y) =>
        (x < 7 && y < 7) || (x >= n - 7 && y < 7) || (x < 7 && y >= n - 7);

    void drawFinder(int ox, int oy) {
      canvas.drawRect(
          Rect.fromLTWH(ox * cell, oy * cell, 7 * cell, 7 * cell), paint);
      canvas.drawRect(
          Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, 5 * cell, 5 * cell),
          Paint()..color = Colors.white);
      canvas.drawRect(
          Rect.fromLTWH((ox + 2) * cell, (oy + 2) * cell, 3 * cell, 3 * cell),
          paint);
    }

    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (finder(x, y)) continue;
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        if ((seed >> 16) % 2 == 0) {
          canvas.drawRect(
              Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
        }
      }
    }
    drawFinder(0, 0);
    drawFinder(n - 7, 0);
    drawFinder(0, n - 7);
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.data != data;
}
