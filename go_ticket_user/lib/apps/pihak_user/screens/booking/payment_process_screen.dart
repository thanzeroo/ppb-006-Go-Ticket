import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:go_ticket_user/core/models/booking_args.dart';
import 'package:go_ticket_user/core/models/booking_model.dart';
import 'package:go_ticket_user/core/services/auth_service.dart';
import 'package:go_ticket_user/core/services/booking_service.dart';
import 'package:go_ticket_user/core/services/qris_service.dart';
import '../../router/customer_router.dart';
import '../../services/user_booking_storage.dart';
import 'package:go_ticket_user/core/widgets/gt_ui.dart';

/// Layar pembayaran — hanya QRIS Dinamis.
class PaymentProcessScreen extends StatefulWidget {
  final dynamic arguments;
  const PaymentProcessScreen({super.key, this.arguments});

  @override
  State<PaymentProcessScreen> createState() => _PaymentProcessScreenState();
}

class _PaymentProcessScreenState extends State<PaymentProcessScreen> {
  late BookingArgs _args;
  late final String _roomNumber;

  Timer? _timer;
  int _secs = 14 * 60 + 59;

  // ---- State untuk bottom sheet QRIS ----
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _args = (widget.arguments is Map && widget.arguments['args'] != null)
        ? BookingArgs.fromHotel(widget.arguments['args'])
        : BookingArgs.fromHotel(widget.arguments);
    _roomNumber =
        (widget.arguments is Map && widget.arguments['roomNumber'] != null)
            ? widget.arguments['roomNumber'].toString()
            : '003';
    _startTimer();
  }

  void _startTimer() {
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
    if (!mounted) return;
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

  // ---- Tampilkan bottom sheet QR sebelum konfirmasi ----
  void _showQrisSheet() {
    final qrisData =
        QrisService.convertToDynamic(_args.total.round());

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _QrisBottomSheet(
        qrisData: qrisData,
        amount: _args.total,
        clock: _clock,
        onConfirm: () {
          Navigator.pop(ctx);
          _pay();
        },
      ),
    );
  }

  // ---- Proses booking setelah user konfirmasi ----
  Future<void> _pay() async {
    if (_paying) return;
    setState(() => _paying = true);
    _timer?.cancel();

    const paymentMethodName = 'QRIS';
    final user = AuthService.instance.currentUser;
    final now = DateTime.now();
    final bookingCode =
        'GT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 1000}';

    final booking = BookingModel(
      id: 'bkg-${now.millisecondsSinceEpoch}',
      bookingCode: bookingCode,
      customerId: user?.id ?? '1',
      customerName: _args.guestName.isNotEmpty
          ? _args.guestName
          : (user?.fullName ?? 'Tamu Go Ticket'),
      customerPhone: _args.phone.isNotEmpty ? _args.phone : user?.phoneNumber,
      hotelId: _args.hotelId.isNotEmpty ? _args.hotelId : '1',
      hotelName: _args.hotelName,
      roomId: _args.roomId.isNotEmpty ? _args.roomId : '1',
      roomTypeName: _args.roomName,
      roomNumber: _roomNumber,
      checkInDate: _args.checkIn,
      checkOutDate: _args.checkOut,
      totalNights: _args.nights > 0 ? _args.nights : 1,
      guestCount: _args.adults + _args.children,
      pricePerNight: _args.roomPrice,
      subtotal: _args.subtotal,
      discountAmount: _args.discount,
      totalAmount: _args.total,
      paymentMethod: paymentMethodName,
      paymentStatus: 'paid',
      status: BookingStatus.pendingVerification,
      isPaid: true,
      paidAt: now,
      createdAt: now,
      qrCodeData: '$bookingCode-CHECKIN',
    );

    try {
      await UserBookingStorage.instance.saveBooking(booking);
    } catch (_) {}
    try {
      await BookingService.instance.createBooking(booking);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _paying = false);

    Navigator.pushReplacementNamed(
      context,
      CustomerRouter.paymentSuccess,
      arguments: {
        'args': _args.copyWith(paymentMethod: paymentMethodName),
        'roomNumber': _roomNumber,
        'booking': booking,
        'bookingCode': bookingCode,
      },
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
          // ---- Timer countdown ----
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
                    Text('BATAS WAKTU PEMBAYARAN',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: GT.muted)),
                    Text('Selesaikan pembayaran sebelum waktu habis',
                        style: TextStyle(
                            fontSize: 12,
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

          // ---- Ringkasan pesanan ----
          _summaryCard(),
          const SizedBox(height: 14),

          // ---- Metode pembayaran: hanya QRIS ----
          Row(children: const [
            Icon(Icons.qr_code_2_rounded, color: GT.teal),
            SizedBox(width: 8),
            Expanded(
              child: Text('Metode Pembayaran',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: GT.ink)),
            ),
          ]),
          const SizedBox(height: 10),
          _qrisMethodCard(),
          const SizedBox(height: 10),

          // ---- Informasi keamanan ----
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: GT.sky.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GT.teal.withValues(alpha: 0.2))),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.shield_outlined, color: GT.teal, size: 16),
                  SizedBox(width: 6),
                  Text('Pembayaran Aman & Terenkripsi',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: GT.teal)),
                ]),
                SizedBox(height: 6),
                Text(
                  'QRIS diterima di semua bank & e-wallet (GoPay, OVO, DANA, ShopeePay, BCA, Mandiri, BNI, BRI, dll.)',
                  style: TextStyle(fontSize: 11, color: GT.body, height: 1.5),
                ),
              ],
            ),
          ),
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
            const Icon(Icons.qr_code_rounded, size: 14, color: GT.teal),
            const SizedBox(width: 4),
            const Text('via QRIS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GT.teal)),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _paying
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ))
                : GTButton(
                    label: 'Tampilkan QR & Bayar  ${rp(_args.total)}',
                    leading: Icons.qr_code_2_rounded,
                    onTap: _showQrisSheet,
                  ),
          ),
        ]),
      ),
    );
  }

  // ---- QRIS Method Card (satu pilihan saja) ----
  Widget _qrisMethodCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GT.teal, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: GT.teal.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: GT.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.qr_code_2_rounded, color: GT.teal, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QRIS',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: GT.ink)),
                  Text('Scan QR — semua bank & e-wallet didukung',
                      style: TextStyle(fontSize: 11, color: GT.muted)),
                ],
              ),
            ),
            GTChip('Terpopuler', bg: GT.sky),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: const [
              _WalletChip('GoPay'),
              _WalletChip('OVO'),
              _WalletChip('DANA'),
              _WalletChip('ShopeePay'),
              _WalletChip('BCA'),
              _WalletChip('Mandiri'),
              _WalletChip('BNI'),
              _WalletChip('BRI'),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Ringkasan pesanan ----
  Widget _summaryCard() {
    return GTCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GTImage(_args.roomImage, height: 60, width: 60, radius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_args.hotelName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: GT.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(_args.roomName,
                      style: const TextStyle(fontSize: 12, color: GT.muted)),
                  Text(
                    '${BookingArgs.monthShort(_args.checkIn.month)} ${_args.checkIn.day} – '
                    '${BookingArgs.monthShort(_args.checkOut.month)} ${_args.checkOut.day}  •  ${_args.nights} malam',
                    style:
                        const TextStyle(fontSize: 11, color: GT.body),
                  ),
                ]),
          ),
        ]),
        const Divider(height: 20),
        _line('Harga Kamar', Text(rp(_args.roomPrice),
            style: const TextStyle(fontWeight: FontWeight.w700, color: GT.ink))),
        const SizedBox(height: 6),
        _line('${_args.nights} Malam', Text(rp(_args.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w700, color: GT.ink))),
        if (_args.discount > 0) ...[
          const SizedBox(height: 6),
          _line('Diskon Promo',
              Text('- ${rp(_args.discount)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: GT.teal))),
        ],
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: GT.soft, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Expanded(
              child: Text('Total Tagihan',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: GT.ink)),
            ),
            Text(rp(_args.total),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: GT.teal)),
          ]),
        ),
      ]),
    );
  }

  Widget _line(String l, Widget r) => Row(children: [
        Expanded(
            child:
                Text(l, style: const TextStyle(fontSize: 13, color: GT.body))),
        r,
      ]);
}

// ---------------------------------------------------------------------------
// Chip kecil wallet
// ---------------------------------------------------------------------------
class _WalletChip extends StatelessWidget {
  final String label;
  const _WalletChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: GT.soft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GT.teal.withValues(alpha: 0.2)),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: GT.ink)),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom Sheet QRIS — QR dinamis + konfirmasi
// ---------------------------------------------------------------------------
class _QrisBottomSheet extends StatefulWidget {
  final String qrisData;
  final int amount;
  final String clock;
  final VoidCallback onConfirm;

  const _QrisBottomSheet({
    required this.qrisData,
    required this.amount,
    required this.clock,
    required this.onConfirm,
  });

  @override
  State<_QrisBottomSheet> createState() => _QrisBottomSheetState();
}

class _QrisBottomSheetState extends State<_QrisBottomSheet> {
  bool _confirming = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 16),

          // Judul
          Row(children: [
            const Icon(Icons.qr_code_2_rounded, color: GT.teal, size: 22),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Scan QRIS untuk Bayar',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: GT.ink)),
            ),
            // Countdown kecil
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: GT.primary, borderRadius: BorderRadius.circular(20)),
              child: Text(widget.clock,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: GT.ink)),
            ),
          ]),
          const SizedBox(height: 16),

          // QR Code
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GT.soft, width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4))
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              QrImageView(
                data: widget.qrisData,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
              const SizedBox(height: 10),
              Text('QRIS Go Ticket',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: GT.muted)),
            ]),
          ),
          const SizedBox(height: 14),

          // Nominal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: GT.soft, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              const Text('NOMINAL PEMBAYARAN',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: GT.muted)),
              const SizedBox(height: 2),
              Text(rp(widget.amount),
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: GT.teal)),
            ]),
          ),
          const SizedBox(height: 10),

          // Instruksi
          const Text(
            'Buka GoPay, OVO, DANA, ShopeePay, atau m-Banking,\n'
            'lalu scan QR di atas untuk menyelesaikan pembayaran.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: GT.body, height: 1.5),
          ),
          const SizedBox(height: 16),

          // Tombol konfirmasi
          SizedBox(
            width: double.infinity,
            child: _confirming
                ? const Center(child: CircularProgressIndicator())
                : GTButton(
                    label: 'Saya Sudah Bayar — Konfirmasi',
                    leading: Icons.check_circle_outline_rounded,
                    onTap: () {
                      setState(() => _confirming = true);
                      widget.onConfirm();
                    },
                  ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Belum Bayar — Kembali',
                style: TextStyle(color: GT.muted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
