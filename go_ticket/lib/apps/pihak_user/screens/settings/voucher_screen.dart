import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_ticket/core/widgets/gt_ui.dart';

class _Voucher {
  final String badge;
  final String tag;
  final String tagKind; // 'red' | 'cyan' | 'grey'
  final String title;
  final String desc;
  final String valid;
  final String code;
  final String image;
  const _Voucher(this.badge, this.tag, this.tagKind, this.title, this.desc,
      this.valid, this.code, this.image);
}

/// Voucher & Promo Saya (Figma: "USER Page Voucher&PromoSaya").
class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final _code = TextEditingController();
  bool _history = false;

  static const _img1 =
      'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=300';
  static const _img2 =
      'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=300';
  static const _img3 =
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=300';

  final List<_Voucher> _available = [
    const _Voucher('DISKON 20% • SPESIAL MEMBER GOLD', 'Sisa 12 Hari', 'red',
        'Diskon Resor & Villa Bali',
        'Min. Transaksi Rp 1.000.000 • Maks. Rp 500.000',
        'Berlaku s/d 30 Nov 2026', 'GOTICKET20', _img1),
    const _Voucher('CASHBACK RP 150.000', 'Hotel Bintang 4 & 5', 'cyan',
        'Cashback QRIS & Virtual Account',
        'Berlaku untuk semua hotel bintang 4 & 5',
        'Berlaku s/d 15 Des 2026', 'PAYCASH150', _img2),
    const _Voucher('GRATIS SARAPAN & SPA', 'Khusus Pasangan', 'grey',
        'Free Breakfast & Welcome Drink',
        'The Grand Amora & Kayumanis Villa',
        'Berlaku s/d 31 Des 2026', 'FREEMORNING', _img3),
    const _Voucher('DISKON 10%', 'Weekend', 'cyan', 'STAYHEMAT Weekend',
        'Diskon spesial menginap akhir pekan',
        'Berlaku s/d 31 Des 2026', 'STAYHEMAT', _img1),
  ];

  final List<_Voucher> _used = [
    const _Voucher('DISKON 15%', 'Sudah digunakan', 'grey', 'Promo Akhir Tahun',
        'Digunakan pada pemesanan GT-772109', 'Digunakan 12 Sep 2026',
        'AKHIRTAHUN15', _img2),
    const _Voucher('CASHBACK RP 50.000', 'Sudah digunakan', 'grey',
        'Cashback Pengguna Baru', 'Digunakan pada pemesanan GT-661084',
        'Digunakan 22 Jul 2026', 'NEWUSER50', _img3),
    const _Voucher('GRATIS UPGRADE KAMAR', 'Sudah digunakan', 'grey',
        'Free Room Upgrade', 'Digunakan pada pemesanan GT-554101',
        'Digunakan 01 Agu 2026', 'UPGRADEME', _img1),
  ];

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  void _claim() {
    final c = _code.text.trim().toUpperCase();
    if (c.isEmpty) return _snack('Masukkan kode promo terlebih dahulu');
    if (_available.any((v) => v.code == c)) {
      return _snack('Kode $c sudah ada di daftar voucher kamu');
    }
    setState(() {
      _available.insert(
        0,
        _Voucher('PROMO $c', 'Baru', 'cyan', 'Voucher $c',
            'Potongan harga untuk pemesananmu', 'Berlaku s/d 31 Des 2026', c,
            _img2),
      );
      _code.clear();
    });
    _snack('Kode promo berhasil diklaim');
  }

  void _copy(String code) {
    Clipboard.setData(ClipboardData(text: code));
    _snack('Kode $code disalin');
  }

  @override
  Widget build(BuildContext context) {
    final list = _history ? _used : _available;
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Vouchers'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          GTCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [
                Icon(Icons.confirmation_number, color: GT.teal),
                SizedBox(width: 8),
                Text('Klaim Kode Promo',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: GT.ink)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: GT.soft.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(14)),
                    child: TextField(
                      controller: _code,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'PUNYA KODE PROMO HOTEL?',
                        hintStyle: TextStyle(fontSize: 12),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GTButton(label: 'Terapkan', height: 50, onTap: _claim),
              ]),
            ]),
          ),
          Row(children: [
            Expanded(
              child: _tab('Voucher Tersedia', Icons.confirmation_number_outlined,
                  _available.length, !_history,
                  () => setState(() => _history = false)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _tab('Riwayat Digunakan', Icons.history, _used.length,
                  _history, () => setState(() => _history = true)),
            ),
          ]),
          const SizedBox(height: 12),
          for (final v in list) _card(v),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                  colors: [GT.teal, GT.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(14)),
                child: const Text('POIN GO TICKET REWARDS',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
              const SizedBox(height: 10),
              const Text('Kumpulkan poin reservasi di Go Ticket!',
                  style: TextStyle(
                      fontSize: 22,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 8),
              const Text(
                  'Tukarkan poin menginapmu dengan voucher diskon hingga menginap gratis di hotel favorit seluruh nusantara.',
                  style: TextStyle(
                      fontSize: 12, height: 1.4, color: Colors.white70)),
              const SizedBox(height: 14),
              Row(children: [
                GestureDetector(
                  onTap: () => _snack('Penukaran poin segera hadir'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('Tukar Poin Saya  ›',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: GT.teal)),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('1.250 Poin Aktif',
                    style: TextStyle(fontSize: 12, color: Colors.white)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _tab(String t, IconData i, int n, bool on, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
            color: on ? GT.sky : GT.soft,
            borderRadius: BorderRadius.circular(24)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i, size: 16, color: GT.ink),
          const SizedBox(width: 6),
          Flexible(
            child: Text(t,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: on ? GT.ink : GT.muted)),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
              radius: 10,
              backgroundColor: on ? GT.teal : Colors.white,
              child: Text('$n',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: on ? Colors.white : GT.ink))),
        ]),
      ),
    );
  }

  Widget _card(_Voucher v) {
    final tagBg = v.tagKind == 'red'
        ? const Color(0xFFFEE2E2)
        : v.tagKind == 'cyan'
            ? GT.sky
            : GT.soft;
    final tagFg = v.tagKind == 'red' ? GT.red : GT.teal;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Opacity(
        opacity: _history ? 0.65 : 1,
        child: Column(children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              gradient: LinearGradient(colors: [GT.primary, GT.teal]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                    child: GTChip(v.badge,
                        icon: Icons.star, bg: GT.sky, fg: GT.teal)),
                const Spacer(),
                GTChip(v.tag, bg: tagBg, fg: tagFg),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                GTImage(v.image, height: 62, width: 62, radius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: GT.ink)),
                      Text(v.desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 11, color: GT.body)),
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.event, size: 13, color: GT.teal),
                        const SizedBox(width: 4),
                        Text(v.valid,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: GT.teal)),
                      ]),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _copy(v.code),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                          color: GT.bg,
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        const Icon(Icons.vpn_key_outlined,
                            size: 16, color: GT.teal),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(v.code,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w800,
                                  color: GT.ink)),
                        ),
                        const Icon(Icons.copy, size: 15, color: GT.teal),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (!_history)
                  GTButton(
                    label: 'Gunakan Sekarang',
                    trailing: Icons.arrow_forward,
                    height: 46,
                    color: GT.teal,
                    textColor: Colors.white,
                    onTap: () {
                      _snack('Voucher ${v.code} siap dipakai saat pembayaran');
                      Navigator.of(context).pop();
                    },
                  ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
