import 'package:flutter/material.dart';

import '../../data/booking_args.dart';
import '../../router/customer_router.dart';
import '../../widgets/gt_ui.dart';

/// Checkout: jumlah tamu, data pemesan, permintaan khusus
/// (Figma: "USER Page Booking").
class GuestDetailFormScreen extends StatefulWidget {
  final dynamic arguments;
  const GuestDetailFormScreen({super.key, this.arguments});

  @override
  State<GuestDetailFormScreen> createState() => _GuestDetailFormScreenState();
}

class _GuestDetailFormScreenState extends State<GuestDetailFormScreen> {
  late final BookingArgs _args = BookingArgs.fromHotel(widget.arguments);

  static const int _maxAdults = 2;
  static const int _maxChildren = 1;

  int _adults = 2;
  int _children = 0;
  bool _forSelf = true;

  final _name = TextEditingController(text: 'Aditya Pratama');
  final _email = TextEditingController(text: 'aditya.pratama@email.com');
  final _phone = TextEditingController(text: '812-3456-7890');
  final _note = TextEditingController();

  final Set<String> _requests = {};
  static const _requestOptions = [
    'Bebas Rokok',
    'Lantai Tinggi',
    'Check-in Awal',
    'King Size Bed',
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  void _next() {
    final emailOk =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());
    if (_name.text.trim().isEmpty) return _snack('Nama lengkap wajib diisi');
    if (!emailOk) return _snack('Alamat email tidak valid');
    if (_phone.text.trim().length < 8) {
      return _snack('Nomor WhatsApp / HP wajib diisi');
    }
    Navigator.pushNamed(
      context,
      CustomerRouter.payment,
      arguments: _args.copyWith(
        adults: _adults,
        children: _children,
        guestName: _name.text.trim(),
        email: _email.text.trim(),
        phone: '+62 ${_phone.text.trim()}',
      ),
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
          _summaryCard(),
          _guestCountCard(),
          _bookerCard(),
          _requestCard(),
        ],
      ),
      bottomNavigationBar: GTBottomBar(
        child: Row(children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Pembayaran (${_args.nights} Malam)',
                    style:
                        const TextStyle(fontSize: 11, color: GT.muted)),
                Row(children: [
                  Text(rp(_args.subtotal),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: GT.teal)),
                  const SizedBox(width: 6),
                  const GTChip('Termasuk Pajak',
                      bg: Color(0xFFDCFCE7), fg: GT.green),
                ]),
              ],
            ),
          ),
          GTButton(
            label: 'Lanjut ke Pembayaran',
            trailing: Icons.arrow_forward_rounded,
            height: 46,
            onTap: _next,
          ),
        ]),
      ),
    );
  }

  Widget _summaryCard() {
    return GTCard(
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            GTImage(_args.roomImage, height: 96, width: 96, radius: 14),
            Positioned(
              left: 6,
              top: 6,
              child: GTChip(_args.rating,
                  icon: Icons.star_rounded, bg: Colors.white, fg: GT.ink),
            ),
          ]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_args.hotelType,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: GT.teal)),
                Text(_args.hotelName,
                    style: const TextStyle(
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: GT.ink)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.bed_outlined, size: 16, color: GT.teal),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(_args.roomName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: GT.teal)),
                  ),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 13, color: GT.muted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('${_args.dateRange} • ${_args.nights} Malam',
                        style: const TextStyle(
                            fontSize: 12, color: GT.body)),
                  ),
                ]),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: GT.soft, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.event_available_outlined,
                size: 16, color: GT.teal),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Bebas Pembatalan (s/d ${_args.checkIn.subtract(const Duration(days: 1)).day} ${BookingArgs.monthShort(_args.checkIn.month)})',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GT.teal),
              ),
            ),
            const GTChip('Sarapan Gratis',
                bg: Color(0xFFDCFCE7), fg: GT.green),
          ]),
        ),
      ]),
    );
  }

  Widget _cardHeader(IconData icon, String title, String sub,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        CircleAvatar(
            radius: 20,
            backgroundColor: GT.sky,
            child: Icon(icon, color: GT.teal, size: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: GT.ink)),
              Text(sub,
                  style: const TextStyle(fontSize: 11, color: GT.muted)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ]),
    );
  }

  Widget _guestCountCard() {
    final ok = _adults <= _maxAdults && _children <= _maxChildren;
    return GTCard(
      child: Column(children: [
        _cardHeader(Icons.groups_rounded, 'Jumlah Tamu Menginap',
            'Kapasitas Maksimal: $_maxAdults Dewasa, $_maxChildren Anak'),
        _counter(Icons.person_outline, 'Tamu Dewasa', 'Usia 12+ tahun',
            _adults, 1, _maxAdults, (v) => setState(() => _adults = v)),
        const SizedBox(height: 10),
        _counter(Icons.child_care, 'Tamu Anak', 'Usia 0 - 11 tahun',
            _children, 0, _maxChildren, (v) => setState(() => _children = v)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: ok ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(ok ? Icons.check_circle : Icons.error,
                size: 18, color: ok ? GT.green : GT.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ok
                    ? 'Jumlah tamu sesuai dengan kapasitas tipe kamar.'
                    : 'Jumlah tamu melebihi kapasitas tipe kamar.',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ok ? GT.green : GT.red),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _counter(IconData icon, String title, String sub, int value, int min,
      int max, ValueChanged<int> onChange) {
    Widget btn(IconData i, bool enabled, VoidCallback onTap, bool primary) =>
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: !enabled
                  ? GT.soft
                  : primary
                      ? GT.primary
                      : Colors.white,
            ),
            child: Icon(i,
                size: 20, color: enabled ? GT.ink : GT.muted.withValues(alpha: 0.5)),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: GT.soft.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: GT.teal),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: GT.ink)),
              Text(sub,
                  style: const TextStyle(fontSize: 11, color: GT.muted)),
            ],
          ),
        ),
        btn(Icons.remove, value > min, () => onChange(value - 1), false),
        SizedBox(
          width: 36,
          child: Center(
            child: Text('$value',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: GT.ink)),
          ),
        ),
        btn(Icons.add, value < max, () => onChange(value + 1), true),
      ]),
    );
  }

  Widget _field(String label, TextEditingController c, IconData icon,
      {String? hint,
      String? trailingLabel,
      TextInputType? type,
      String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: GT.ink),
                children: const [
                  TextSpan(text: ' *', style: TextStyle(color: GT.red)),
                ],
              ),
            ),
          ),
          if (trailingLabel != null)
            Text(trailingLabel,
                style: const TextStyle(fontSize: 11, color: GT.muted)),
        ]),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
              color: GT.soft.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14)),
          child: TextField(
            controller: c,
            keyboardType: type,
            readOnly: false,
            style: const TextStyle(fontSize: 14, color: GT.ink),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              prefixIcon: prefix == null
                  ? Icon(icon, color: GT.teal, size: 20)
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(width: 14),
                      Icon(icon, color: GT.teal, size: 20),
                      const SizedBox(width: 8),
                      Text(prefix,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, color: GT.ink)),
                      const SizedBox(width: 8),
                    ]),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bookerCard() {
    return GTCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(Icons.badge_outlined, 'Data Diri Pemesan',
            'E-Tiket resmi diterbitkan atas identitas ini'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: GT.sky.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.how_to_reg_outlined, color: GT.teal),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pemesanan untuk diri sendiri',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: GT.ink)),
                  Text('Nama tamu sama dengan pemesan',
                      style: TextStyle(fontSize: 11, color: GT.muted)),
                ],
              ),
            ),
            Switch(
              value: _forSelf,
              activeColor: Colors.white,
              activeTrackColor: GT.primary,
              onChanged: (v) => setState(() => _forSelf = v),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        _field('Nama Lengkap', _name, Icons.account_circle_outlined,
            trailingLabel: 'Sesuai KTP / Paspor', hint: 'Nama lengkap'),
        const SizedBox(height: 14),
        _field('Alamat Email', _email, Icons.alternate_email_rounded,
            type: TextInputType.emailAddress, hint: 'nama@email.com'),
        const SizedBox(height: 14),
        _field('Nomor WhatsApp / HP', _phone, Icons.chat_outlined,
            type: TextInputType.phone, prefix: '+62', hint: '812-xxxx-xxxx'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: GT.soft.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: const [
            Icon(Icons.verified_user_outlined, size: 16, color: GT.teal),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Konfirmasi & QR E-Tiket otomatis dikirimkan lewat WhatsApp '
                'resmi Go Ticket.',
                style: TextStyle(fontSize: 11, color: GT.body, height: 1.4),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _requestCard() {
    return GTCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(Icons.room_service_outlined, 'Permintaan Khusus',
            'Berdasarkan ketersediaan pihak resort saat check-in',
            trailing: const GTChip('Opsional')),
        Row(children: [
          Expanded(child: _check(_requestOptions[0])),
          const SizedBox(width: 10),
          Expanded(child: _check(_requestOptions[1])),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _check(_requestOptions[2])),
          const SizedBox(width: 10),
          Expanded(child: _check(_requestOptions[3])),
        ]),
        const SizedBox(height: 14),
        const Text('Catatan Tambahan untuk Pihak Hotel',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: GT.ink)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
              color: GT.soft.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14)),
          child: TextField(
            controller: _note,
            maxLines: 4,
            maxLength: 250,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Contoh: Tolong disiapkan kamar dengan view sunset terbaik',
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _check(String label) {
    final on = _requests.contains(label);
    return GestureDetector(
      onTap: () => setState(() => on ? _requests.remove(label) : _requests.add(label)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
            color: GT.soft.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(on ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20, color: on ? GT.primary : GT.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: GT.ink)),
          ),
        ]),
      ),
    );
  }
}
