import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_ticket/core/services/promo_service.dart';
import 'shared_widgets.dart';

class _Voucher {
  final String badge;
  final String tag;
  final String tagKind;
  final String title;
  final String desc;
  final String valid;
  final String code;
  final String image;

  const _Voucher(this.badge, this.tag, this.tagKind, this.title, this.desc,
      this.valid, this.code, this.image);
}

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final _code = TextEditingController();
  bool _history = false;
  bool _isLoading = true;
  List<_Voucher> _available = [];
  final List<_Voucher> _used = [];

  static const _defaultImg =
      'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=300';

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() => _isLoading = true);
    try {
      final promos = await PromoService.instance.getPromos();
      if (mounted) {
        setState(() {
          _available = promos.map((p) {
            final code = p['code']?.toString() ?? '';
            final title = p['title']?.toString() ?? 'Promo Spesial';
            final desc = p['description']?.toString() ?? '';
            final discount = p['discountPercent']?.toString() ?? '10';
            final valid = p['expiredDate']?.toString() ?? '2026-12-31';
            return _Voucher(
              'DISKON $discount%',
              'Aktif',
              'cyan',
              title,
              desc,
              'Berlaku s/d $valid',
              code,
              _defaultImg,
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _available = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  Future<void> _claim() async {
    final c = _code.text.trim().toUpperCase();
    if (c.isEmpty) return _snack('Masukkan kode promo terlebih dahulu');
    if (_available.any((v) => v.code == c)) {
      return _snack('Kode $c sudah ada di daftar voucher kamu');
    }

    try {
      final promo = await PromoService.instance.validatePromo(
        code: c,
        bookingAmount: 500000,
      );
      if (promo != null) {
        setState(() {
          _available.insert(
            0,
            _Voucher(
              'PROMO KLAIM',
              'Baru',
              'cyan',
              'Voucher $c',
              'Potongan harga untuk pemesananmu',
              'Berlaku Aktif',
              c,
              _defaultImg,
            ),
          );
          _code.clear();
        });
        _snack('Kode promo berhasil diklaim');
      } else {
        _snack('Kode promo tidak ditemukan di database');
      }
    } catch (e) {
      _snack('Kode promo tidak valid atau tidak aktif');
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              children: [
                GTCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 16),
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
                    child: _tab('Voucher Tersedia',
                        Icons.confirmation_number_outlined, _available.length,
                        !_history, () => setState(() => _history = false)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _tab('Riwayat Digunakan', Icons.history, _used.length,
                        _history, () => setState(() => _history = true)),
                  ),
                ]),
                const SizedBox(height: 12),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.confirmation_number_outlined,
                              size: 48, color: GT.muted),
                          const SizedBox(height: 12),
                          Text(
                            _history
                                ? 'Belum ada riwayat voucher yang digunakan'
                                : 'Belum ada promo voucher aktif saat ini',
                            style: const TextStyle(
                                fontSize: 13, color: GT.muted),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final v in list) _card(v),
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
