import 'package:flutter/material.dart';

import '../../data/booking_args.dart';
import '../../router/customer_router.dart';
import '../../widgets/gt_ui.dart';

/// Pilih tanggal (kalender) + tipe kamar (Figma: "USER Page Room").
class RoomSelectionScreen extends StatefulWidget {
  final dynamic arguments;
  const RoomSelectionScreen({super.key, this.arguments});

  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

enum _DayStatus { available, full, maintenance }

class _Room {
  final String name;
  final String capacity;
  final List<String> features;
  final int price;
  final int? oldPrice;
  final String image;
  final String? badge;
  final String? note;
  final bool soldOut;
  const _Room({
    required this.name,
    required this.capacity,
    required this.features,
    required this.price,
    required this.image,
    this.oldPrice,
    this.badge,
    this.note,
    this.soldOut = false,
  });
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  late final BookingArgs _args = BookingArgs.fromHotel(widget.arguments);

  late DateTime _month = DateTime(_args.checkIn.year, _args.checkIn.month);
  DateTime? _in;
  DateTime? _out;
  int _room = 0;

  static const _rooms = [
    _Room(
      name: 'Deluxe Ocean View',
      capacity: 'Maks. 2 Dewasa, 1 Anak',
      features: ['1 King Bed', 'Balkon Menghadap Laut', 'Sarapan Gratis',
        'High-Speed WiFi'],
      price: 850000,
      oldPrice: 1100000,
      image:
          'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800',
      badge: 'Sisa 2 Kamar Lagi!',
    ),
    _Room(
      name: 'Executive Suite Jacuzzi',
      capacity: 'Maks. 3 Dewasa',
      features: ['Ruang Tamu Terpisah', 'Private Jacuzzi', 'Akses VIP Lounge'],
      price: 1450000,
      image:
          'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
      note: 'Tersedia untuk 2 malam',
    ),
    _Room(
      name: 'Sunset Villa with Private Pool',
      capacity: 'Maks. 4 Dewasa',
      features: [],
      price: 2900000,
      image:
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
      note:
          'Kolam renang pribadi, dek berjemur eksklusif, pelayanan pribadi 24 jam.',
      soldOut: true,
    ),
  ];

  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
    'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _in = _args.checkIn;
    _out = _args.checkOut;
    // pastikan pilihan awal valid
    if (!_rangeIsFree(_in!, _out!)) {
      _in = null;
      _out = null;
    }
  }

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Status dummy per tanggal (sampai ada data dari API).
  _DayStatus _status(DateTime d) {
    if (d.day % 9 == 0) return _DayStatus.full;
    if (d.day % 11 == 0) return _DayStatus.maintenance;
    return _DayStatus.available;
  }

  bool _selectable(DateTime d) =>
      !d.isBefore(_today) && _status(d) == _DayStatus.available;

  bool _rangeIsFree(DateTime a, DateTime b) {
    // Malam yang diinap: a .. b-1 harus tersedia. Hari check-out boleh penuh.
    for (var d = a; d.isBefore(b); d = d.add(const Duration(days: 1))) {
      if (!_selectable(d)) return false;
    }
    return true;
  }

  void _tapDay(DateTime d) {
    if (!_selectable(d)) return;
    setState(() {
      if (_in == null || _out != null) {
        _in = d;
        _out = null;
      } else if (d.isAfter(_in!) && _rangeIsFree(_in!, d)) {
        _out = d;
      } else {
        _in = d;
        _out = null;
      }
    });
  }

  int get _nights => (_in != null && _out != null)
      ? _out!.difference(_in!).inDays
      : 0;

  void _next() {
    final room = _rooms[_room];
    Navigator.pushNamed(
      context,
      CustomerRouter.guestDetail,
      arguments: _args.copyWith(
        roomName: room.name,
        roomImage: room.image,
        roomPrice: room.price,
        checkIn: _in,
        checkOut: _out,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _in != null && _out != null && !_rooms[_room].soldOut;
    final total = _rooms[_room].price * _nights;
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Property Detail'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          GTCard(
            child: Row(children: [
              const CircleAvatar(
                  radius: 22,
                  backgroundColor: GT.sky,
                  child: Icon(Icons.bed_outlined, color: GT.teal)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PROPERTI TERPILIH',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: GT.muted)),
                    Text(_args.hotelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, color: GT.ink)),
                  ],
                ),
              ),
              GTChip(_args.rating,
                  icon: Icons.star_rounded, bg: GT.soft, fg: GT.ink),
            ]),
          ),
          _calendarCard(),
          const SizedBox(height: 8),
          Row(children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pilihan Tipe Kamar',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: GT.ink)),
                  Text('Disesuaikan untuk tanggal terpilih',
                      style: TextStyle(fontSize: 12, color: GT.muted)),
                ],
              ),
            ),
            GTChip('${_rooms.length} Opsi', bg: GT.soft),
          ]),
          const SizedBox(height: 12),
          for (var i = 0; i < _rooms.length; i++) _roomCard(i),
        ],
      ),
      bottomNavigationBar: GTBottomBar(
        child: Row(children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('TOTAL HARGA',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: GT.muted)),
                  const SizedBox(width: 6),
                  if (_nights > 0)
                    GTChip('$_nights Malam', bg: GT.sky),
                ]),
                const SizedBox(height: 2),
                Text(ready ? rp(total) : '-',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: GT.teal)),
                const Text('Termasuk pajak & sarapan',
                    style: TextStyle(fontSize: 10, color: GT.muted)),
              ],
            ),
          ),
          GTButton(
            label: 'Lanjut Pemesanan',
            trailing: Icons.arrow_forward_rounded,
            onTap: ready ? _next : null,
          ),
        ]),
      ),
    );
  }

  // ---------------------------------------------------------------- kalender

  Widget _calendarCard() {
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final offset = first.weekday % 7; // Minggu = 0
    final cells = <Widget>[];
    for (var i = 0; i < offset; i++) {
      cells.add(const SizedBox());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(_dayCell(DateTime(_month.year, _month.month, day)));
    }
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox());
    }
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 7) {
      rows.add(Row(
        children: [for (final c in cells.sublist(i, i + 7)) Expanded(child: c)],
      ));
    }

    return GTCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('KETERSEDIAAN TANGGAL',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: GT.teal)),
                  Text('${_monthNames[_month.month - 1]} ${_month.year}',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: GT.ink)),
                ],
              ),
            ),
            _navBtn(Icons.chevron_left_rounded,
                () => setState(() => _month =
                    DateTime(_month.year, _month.month - 1))),
            const SizedBox(width: 8),
            _navBtn(Icons.chevron_right_rounded,
                () => setState(() => _month =
                    DateTime(_month.year, _month.month + 1))),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: GT.sky, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.calendar_month_outlined,
                  color: GT.teal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DURASI MENGINAP',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: GT.teal)),
                    Text(
                      _in == null
                          ? 'Pilih tanggal check-in'
                          : _out == null
                              ? '${_in!.day} ${BookingArgs.monthShort(_in!.month)} – pilih check-out'
                              : '${_in!.day} ${BookingArgs.monthShort(_in!.month)} – ${_out!.day} ${BookingArgs.monthShort(_out!.month)} ($_nights Malam)',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: GT.ink),
                    ),
                  ],
                ),
              ),
              if (_nights > 0)
                GTChip('$_nights Malam', bg: GT.primary, fg: GT.ink),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            for (final h in ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'])
              Expanded(
                child: Center(
                  child: Text(h,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: h == 'Min' ? GT.red : GT.body)),
                ),
              ),
          ]),
          const SizedBox(height: 6),
          ...rows,
          const SizedBox(height: 10),
          Wrap(spacing: 14, runSpacing: 6, children: const [
            _Legend(GT.green, 'Tersedia'),
            _Legend(GT.red, 'Penuh'),
            _Legend(Color(0xFF7C3AED), 'Perbaikan'),
            _Legend(GT.primary, 'Pilihan Anda'),
          ]),
        ],
      ),
    );
  }

  Widget _navBtn(IconData i, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 38,
          height: 38,
          decoration:
              const BoxDecoration(color: GT.soft, shape: BoxShape.circle),
          child: Icon(i, color: GT.ink),
        ),
      );

  Widget _dayCell(DateTime d) {
    final st = _status(d);
    final isIn = _in != null && d == _in;
    final isOut = _out != null && d == _out;
    final inRange = _in != null &&
        _out != null &&
        d.isAfter(_in!) &&
        d.isBefore(_out!);
    final past = d.isBefore(_today);
    final ok = _selectable(d);

    Color bg = GT.soft;
    Color fg = GT.ink;
    if (isIn) {
      bg = GT.primary;
    } else if (isOut) {
      bg = GT.teal;
      fg = Colors.white;
    } else if (inRange) {
      bg = GT.sky;
    } else if (!ok) {
      bg = GT.soft.withValues(alpha: 0.5);
      fg = GT.muted.withValues(alpha: 0.6);
    }
    final dot = st == _DayStatus.available
        ? GT.green
        : st == _DayStatus.full
            ? GT.red
            : const Color(0xFF7C3AED);

    return GestureDetector(
      onTap: () => _tapDay(d),
      child: Container(
        margin: const EdgeInsets.all(2),
        height: 44,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isIn || isOut)
              Text(isIn ? 'IN' : 'OUT',
                  style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      color: isIn ? GT.teal : Colors.white)),
            Text('${d.day}',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
            if (!past)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration:
                    BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- kartu kamar

  Widget _roomCard(int i) {
    final r = _rooms[i];
    final selected = _room == i && !r.soldOut;
    return Opacity(
      opacity: r.soldOut ? 0.6 : 1,
      child: GTCard(
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              GTImage(r.image,
                  height: 170, width: double.infinity, radius: 20),
              if (r.soldOut)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('Penuh pada Tanggal Terpilih',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              Positioned(
                left: 10,
                top: 10,
                child: r.soldOut
                    ? const SizedBox()
                    : selected
                        ? const GTChip('Kamar Terpilih',
                            icon: Icons.check_circle,
                            bg: GT.primary,
                            fg: GT.ink)
                        : const GTChip('Tersedia',
                            icon: Icons.check,
                            bg: Color(0xFFDCFCE7),
                            fg: GT.green),
              ),
              if (r.badge != null && !r.soldOut)
                Positioned(
                  right: 10,
                  top: 10,
                  child: GTChip(r.badge!,
                      icon: Icons.local_fire_department_rounded,
                      bg: const Color(0xFFFEE2E2),
                      fg: GT.red),
                ),
            ]),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(r.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: GT.ink)),
                    ),
                    if (!r.soldOut)
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: selected ? GT.primary : GT.soft,
                          shape: BoxShape.circle,
                        ),
                        child: selected
                            ? const Icon(Icons.check,
                                size: 16, color: GT.teal)
                            : null,
                      ),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.people_outline,
                        size: 15, color: GT.muted),
                    const SizedBox(width: 4),
                    Text(r.capacity,
                        style: const TextStyle(
                            fontSize: 12, color: GT.muted)),
                  ]),
                  if (r.features.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final f in r.features) GTChip(f, bg: GT.sky),
                    ]),
                  ],
                  if (r.soldOut && r.note != null) ...[
                    const SizedBox(height: 8),
                    Text(r.note!,
                        style: const TextStyle(
                            fontSize: 12, color: GT.muted, height: 1.4)),
                  ],
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: r.soldOut
                          ? Row(children: const [
                              Icon(Icons.remove_circle_outline,
                                  size: 16, color: GT.red),
                              SizedBox(width: 4),
                              Text('Kamar Tidak Tersedia',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: GT.red)),
                            ])
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (r.oldPrice != null)
                                  Text(rp(r.oldPrice!),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: GT.muted,
                                          decoration:
                                              TextDecoration.lineThrough)),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(rp(r.price),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: GT.teal)),
                                    const Text(' / malam',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: GT.muted)),
                                  ],
                                ),
                                if (r.note != null)
                                  Text(r.note!,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: GT.green)),
                              ],
                            ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed:
                            r.soldOut ? null : () => setState(() => _room = i),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selected ? GT.primary : GT.soft,
                          disabledBackgroundColor: GT.soft,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(
                          r.soldOut ? 'Habis' : selected ? 'Terpilih' : 'Pilih',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: r.soldOut ? GT.muted : GT.teal),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11, color: GT.body)),
    ]);
  }
}
