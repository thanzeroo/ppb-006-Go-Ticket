import 'package:flutter/material.dart';

import 'package:go_ticket/core/models/booking_args.dart';
import 'package:go_ticket/core/services/hotel_service.dart';
import '../../router/customer_router.dart';
import 'package:go_ticket/core/widgets/gt_ui.dart';

/// Pilih tanggal (kalender) + tipe kamar (Figma: "USER Page Room").
class RoomSelectionScreen extends StatefulWidget {
  final dynamic arguments;
  const RoomSelectionScreen({super.key, this.arguments});

  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

enum _DayStatus { available, full, maintenance }

class _RoomUnit {
  final String number;
  final bool isBooked;
  const _RoomUnit({required this.number, required this.isBooked});
}

class _Room {
  final String? id;
  final String name;
  final String capacity;
  final List<String> features;
  final int price;
  final int? oldPrice;
  final String image;
  final String? badge;
  final String? note;
  final bool soldOut;
  final List<_RoomUnit> units;
  const _Room({
    this.id,
    required this.name,
    required this.capacity,
    required this.features,
    required this.price,
    required this.image,
    this.oldPrice,
    this.badge,
    this.note,
    this.soldOut = false,
    this.units = const [],
  });
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  late final BookingArgs _args = BookingArgs.fromHotel(widget.arguments);

  late DateTime _month = DateTime(_args.checkIn.year, _args.checkIn.month);
  DateTime? _in;
  DateTime? _out;
  int _room = 0;
  List<_Room> _rooms = [];
  bool _isLoadingRooms = true;
  bool _isAutoRoom = true;
  final Map<int, String> _manualRoomSelection = {};

  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
    'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    final today = _today;
    DateTime checkIn = _args.checkIn;
    DateTime checkOut = _args.checkOut;
    if (checkIn.isBefore(today)) {
      checkIn = today.add(const Duration(days: 1));
      checkOut = checkIn.add(const Duration(days: 2));
    }
    _in = checkIn;
    _out = checkOut;
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final dbRooms =
          await HotelService.instance.getRoomsByHotel(_args.hotelId);
      if (mounted) {
        if (dbRooms.isNotEmpty) {
          setState(() {
            _rooms = dbRooms.map((r) {
              return _Room(
                id: r.id,
                name: r.name,
                capacity: 'Maks. ${r.capacity} Tamu',
                features: r.amenities.isNotEmpty
                    ? r.amenities
                    : [r.bedType ?? '1 King Bed', 'AC', 'WiFi Gratis'],
                price: r.priceWeekday.toInt(),
                image: r.displayImage,
                badge: r.totalUnits <= 2
                    ? 'Sisa ${r.totalUnits} Kamar Lagi!'
                    : null,
                units: _generateUnitsForType(r.name, r.totalUnits),
              );
            }).toList();
            _isLoadingRooms = false;
          });
        } else {
          setState(() {
            _rooms = _defaultRooms;
            _isLoadingRooms = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _rooms = _defaultRooms;
          _isLoadingRooms = false;
        });
      }
    }
  }

  static List<_RoomUnit> _generateUnitsForType(String typeName, int totalUnits) {
    final count = totalUnits > 0 ? totalUnits : 5;
    final isDeluxe = typeName.toLowerCase().contains('deluxe');
    final isSuite = typeName.toLowerCase().contains('suite');
    final prefix = isDeluxe ? '0' : (isSuite ? '1' : '2');

    return List.generate(count, (idx) {
      final numStr = '$prefix${(idx + 1).toString().padLeft(2, '0')}';
      // Sesuai kebutuhan: Tipe Deluxe 5 unit (001,002,003,004,005) kamar 001 & 002 sudah terisi/terbooking
      final isBooked = isDeluxe ? (idx < 2) : (idx == 0);
      return _RoomUnit(number: numStr, isBooked: isBooked);
    });
  }

  String _getEffectiveRoomNumber(int i) {
    if (i < 0 || i >= _rooms.length) return '001';
    final r = _rooms[i];
    if (r.units.isEmpty) return '001';

    if (!_isAutoRoom && _manualRoomSelection.containsKey(i)) {
      final selectedNum = _manualRoomSelection[i]!;
      final matchingUnit = r.units.firstWhere(
        (u) => u.number == selectedNum,
        orElse: () => r.units.first,
      );
      if (!matchingUnit.isBooked) {
        return matchingUnit.number;
      }
    }

    final freeUnit = r.units.firstWhere(
      (u) => !u.isBooked,
      orElse: () => r.units.first,
    );
    return freeUnit.number;
  }

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Status dummy per tanggal (sampai ada data dari API).
  _DayStatus _status(DateTime d) {
    if (d.day % 29 == 0) return _DayStatus.full;
    if (d.day % 31 == 0) return _DayStatus.maintenance;
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

  int get _baseRoomPrice => _args.roomPrice > 0 ? _args.roomPrice : 850000;

  List<_Room> get _defaultRooms => [
        _Room(
          id: '1',
          name: 'Deluxe Ocean View',
          capacity: 'Maks. 2 Dewasa, 1 Anak',
          features: const [
            '1 King Bed',
            'Balkon Menghadap Laut',
            'Sarapan Gratis',
            'High-Speed WiFi',
          ],
          price: _baseRoomPrice,
          oldPrice: _args.originalPrice != null &&
                  _args.originalPrice! > _baseRoomPrice
              ? _args.originalPrice
              : null,
          image:
              'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800',
          badge: 'Sisa 3 Kamar Lagi!',
          units: const [
            _RoomUnit(number: '001', isBooked: true),
            _RoomUnit(number: '002', isBooked: true),
            _RoomUnit(number: '003', isBooked: false),
            _RoomUnit(number: '004', isBooked: false),
            _RoomUnit(number: '005', isBooked: false),
          ],
        ),
        _Room(
          id: '2',
          name: 'Executive Suite Jacuzzi',
          capacity: 'Maks. 3 Dewasa',
          features: const [
            'Ruang Tamu Terpisah',
            'Private Jacuzzi',
            'Akses VIP Lounge',
          ],
          price: (_baseRoomPrice * 17 / 10).round(),
          image:
              'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
          note: 'Tersedia untuk 2 malam',
          units: const [
            _RoomUnit(number: '101', isBooked: true),
            _RoomUnit(number: '102', isBooked: false),
            _RoomUnit(number: '103', isBooked: false),
            _RoomUnit(number: '104', isBooked: false),
          ],
        ),
        _Room(
          id: '3',
          name: 'Sunset Villa with Private Pool',
          capacity: 'Maks. 4 Dewasa',
          features: const [],
          price: (_baseRoomPrice * 34 / 10).round(),
          image:
              'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
          note:
              'Kolam renang pribadi, dek berjemur eksklusif, pelayanan pribadi 24 jam.',
          soldOut: true,
          units: const [
            _RoomUnit(number: '201', isBooked: true),
            _RoomUnit(number: '202', isBooked: true),
          ],
        ),
      ];

  void _next() {
    if (_in == null || _out == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tentukan tanggal check-in dan check-out')),
      );
      return;
    }
    if (_rooms.isEmpty) return;
    final room = _rooms[_room.clamp(0, _rooms.length - 1)];
    if (room.soldOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tipe kamar ini sudah habis. Silakan pilih tipe kamar lain.')),
      );
      return;
    }
    final chosenRoomNum = _getEffectiveRoomNumber(_room);
    Navigator.pushNamed(
      context,
      CustomerRouter.guestDetail,
      arguments: {
        'args': _args.copyWith(
          roomId: room.id,
          roomName: '${room.name} (Kamar $chosenRoomNum)',
          roomImage: room.image,
          roomPrice: room.price,
          checkIn: _in,
          checkOut: _out,
        ),
        'rawRoomName': room.name,
        'roomNumber': chosenRoomNum,
        'isAutoRoom': _isAutoRoom,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRooms) {
      return Scaffold(
        backgroundColor: GT.bg,
        appBar: const GTAppBar(title: 'Pilih Kamar'),
        body: const Center(child: CircularProgressIndicator(color: GT.teal)),
      );
    }
    final currentRoom = _rooms.isNotEmpty
        ? _rooms[_room.clamp(0, _rooms.length - 1)]
        : _defaultRooms.first;
    final ready = _in != null && _out != null && !currentRoom.soldOut;
    final total = currentRoom.price * _nights;
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
                  const SizedBox(width: 6),
                  GTChip(
                    'No. ${_getEffectiveRoomNumber(_room)}',
                    bg: const Color(0xFFDCFCE7),
                    fg: GT.green,
                  ),
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
            onTap: _next,
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
                  if (selected && !r.soldOut && r.units.isNotEmpty)
                    _buildRoomNumberSelector(i, r),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomNumberSelector(int i, _Room r) {
    final effectiveNum = _getEffectiveRoomNumber(i);
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.meeting_room_outlined, size: 18, color: GT.teal),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'ALOKASI NOMOR KAMAR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: GT.teal,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _isAutoRoom = true),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _isAutoRoom ? GT.teal : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Otomatis',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _isAutoRoom ? Colors.white : GT.muted,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _isAutoRoom = false),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: !_isAutoRoom ? GT.teal : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Pilih Manual',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: !_isAutoRoom ? Colors.white : GT.muted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isAutoRoom) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: GT.green, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kamar Terpilih Otomatis: No. $effectiveNum',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: GT.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Sistem mengisi nomor kamar secara urut (kamar 001 & 002 yang sudah terisi otomatis dilewati).',
                          style: TextStyle(fontSize: 11, color: GT.muted, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              'Pilih salah satu nomor kamar yang masih tersedia:',
              style: TextStyle(fontSize: 11, color: GT.body, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: r.units.map((unit) {
                final isSelected = effectiveNum == unit.number && !unit.isBooked;
                if (unit.isBooked) {
                  return InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Kamar ${unit.number} sudah terisi / terbooking. Silakan pilih nomor kamar lain.'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline, size: 12, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            '${unit.number} (Terisi)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return InkWell(
                  onTap: () {
                    setState(() {
                      _manualRoomSelection[i] = unit.number;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? GT.teal : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? GT.teal : const Color(0xFF86EFAC),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: GT.teal.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.meeting_room,
                          size: 13,
                          color: isSelected ? Colors.white : GT.teal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${unit.number} (Tersedia)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : GT.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
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
