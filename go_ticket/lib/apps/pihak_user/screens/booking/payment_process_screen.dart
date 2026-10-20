import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/booking_args.dart';
import '../../router/customer_router.dart';
import '../../widgets/gt_ui.dart';

/// Pembayaran (Figma: "USER Page Payment").
class PaymentProcessScreen extends StatefulWidget {
  final dynamic arguments;
  const PaymentProcessScreen({super.key, this.arguments});

  @override
  State<PaymentProcessScreen> createState() => _PaymentProcessScreenState();
}

class _PaymentProcessScreenState extends State<PaymentProcessScreen> {
  late BookingArgs _args = BookingArgs.fromHotel(widget.arguments);

  Timer? _timer;
  int _secs = 14 * 60 + 59;

  int _method = 0;
  int? _open = 0;

  static const _methods = [
    ['E-Wallet & QRIS Instan', 'Konfirmasi otomatis tanpa upload bukti',
      'QRIS / GoPay Instan'],
    ['Virtual Account Bank', 'BCA, Mandiri, BNI, BRI & Permata',
      'Virtual Account Bank'],
    ['Kartu Kredit / Debit', 'Visa, Mastercard, JCB & AMEX',
      'Kartu Kredit / Debit'],
    ['PayLater & Cicilan', 'Liburan sekarang, bayar bulan depan',
      'PayLater & Cicilan'],
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secs <= 1) {
        t.cancel();
        _expired();
        return;
      }
      setState(() => _secs--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _expired() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Waktu Pembayaran Habis'),
        content: const Text(
            'Batas waktu pembayaran telah berakhir. Silakan ulangi pemesanan.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  String get _clock {
    final m = (_secs ~/ 60).toString().padLeft(2, '0');
    final s = (_secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _pay() {
    _timer?.cancel();
    Navigator.pushReplacementNamed(
      context,
      CustomerRouter.paymentSuccess,
      arguments: _args.copyWith(paymentMethod: _methods[_method][2]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Checkout Flow'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: GT.soft, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const CircleAvatar(
                  radius: 20,
                  backgroundColor: GT.sky,
                  child: Icon(Icons.timer_outlined, color: GT.teal)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BATAS WAKTU SELESAI',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: GT.muted)),
                    Text('Selesaikan pembayaran dalam',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: GT.ink)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: GT.primary,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(_clock,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: GT.ink)),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          _summaryCard(),
          const SizedBox(height: 4),
          Row(children: const [
            Icon(Icons.payments_outlined, color: GT.teal),
            SizedBox(width: 8),
            Expanded(
              child: Text('Metode Pembayaran',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: GT.ink)),
            ),
            Text('Semua Transaksi Instan',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: GT.ink)),
          ]),
          const SizedBox(height: 12),
          _methodTile(0, badge: 'Terpopuler', chips: const [
            'QRIS', 'GoPay', 'OVO', 'DANA'
          ]),
          _promoRow(),
          _methodTile(1),
          _methodTile(2, lock: true),
          _methodTile(3, badge: 'Bunga 0%'),
        ],
      ),
      bottomNavigationBar: GTBottomBar(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL PEMBAYARAN',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: GT.muted)),
                  Text(rp(_args.total),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: GT.teal)),
                ],
              ),
            ),
            const Icon(Icons.hotel_outlined, size: 14, color: GT.teal),
            const SizedBox(width: 4),
            Text('1 Kamar / ${_args.nights} Malam',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GT.teal)),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GTButton(
              label: 'Bayar Sekarang ${rp(_args.total)}',
              leading: Icons.shield_rounded,
              onTap: _pay,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _summaryCard() {
    return GTCard(
      child: Column(children: [
        Row(children: [
          GTImage(_args.roomImage, height: 64, width: 64, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GTChip('Hotel • 1 Kamar',
                    icon: Icons.hotel, bg: GT.soft),
                const SizedBox(height: 4),
                Text(_args.roomName,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: GT.ink)),
                Text('${_args.nights} Malam • ${_args.adults} Dewasa',
                    style: const TextStyle(
                        fontSize: 12, color: GT.muted)),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 14),
        _line('${_args.nights} Malam x ${rp(_args.roomPrice)}',
            Text(rp(_args.subtotal),
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: GT.ink))),
        const SizedBox(height: 8),
        _line('Layanan & Kebersihan',
            const GTChip('GRATIS',
                bg: Color(0xFFDCFCE7), fg: GT.green)),
        const SizedBox(height: 8),
        _line('Pajak Pemerintah & Daerah (10%)',
            const Text('Termasuk',
                style: TextStyle(fontSize: 12, color: GT.muted))),
        if (_args.promoApplied) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFE6F6F0),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const CircleAvatar(
                  radius: 16,
                  backgroundColor: GT.sky,
                  child:
                      Icon(Icons.sell_outlined, size: 16, color: GT.teal)),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('STAYHEMAT ✓',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: GT.teal)),
                    Text('Kupon potongan berhasil terpasang',
                        style: TextStyle(fontSize: 11, color: GT.body)),
                  ],
                ),
              ),
              Text('- ${rp(_args.discount)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: GT.teal)),
            ]),
          ),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
              color: GT.soft, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Expanded(
              child: Text('Total Tagihan',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: GT.ink)),
            ),
            Text(rp(_args.total),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: GT.teal)),
          ]),
        ),
      ]),
    );
  }

  Widget _line(String l, Widget r) => Row(children: [
        Expanded(
            child: Text(l,
                style: const TextStyle(fontSize: 13, color: GT.body))),
        r,
      ]);

  Widget _promoRow() {
    return GTCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        const Icon(Icons.confirmation_number_outlined, color: GT.teal),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('Pilih Kode Promo',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: GT.ink)),
        ),
        GTButton(
          label: _args.promoApplied ? 'Lepas' : 'Terapkan',
          height: 44,
          onTap: () => setState(
              () => _args = _args.copyWith(promoApplied: !_args.promoApplied)),
        ),
      ]),
    );
  }

  Widget _methodTile(int i,
      {String? badge, List<String>? chips, bool lock = false}) {
    final m = _methods[i];
    final selected = _method == i;
    final open = _open == i;
    return GTCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: Column(children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() {
            _method = i;
            _open = open ? null : i;
          }),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                    color: selected ? GT.primary : GT.soft,
                    shape: BoxShape.circle),
                child: selected
                    ? const Icon(Icons.check, size: 16, color: GT.teal)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(m[0],
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: GT.ink)),
                        if (lock)
                          const Icon(Icons.lock_rounded,
                              size: 14, color: GT.green),
                        if (badge != null)
                          GTChip(badge, bg: GT.sky),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(m[1],
                        style: const TextStyle(
                            fontSize: 12, color: GT.muted)),
                  ],
                ),
              ),
              Icon(open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: GT.teal),
            ]),
          ),
        ),
        if (open && chips != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final c in chips) GTChip(c, bg: GT.soft, fg: GT.ink),
            ]),
          ),
      ]),
    );
  }
}
