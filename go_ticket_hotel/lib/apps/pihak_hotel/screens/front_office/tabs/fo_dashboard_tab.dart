import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_ticket_hotel/core/widgets/terms_and_policy_screen.dart';
import '../../../../../core/config/supabase_config.dart';
import '../../../../../core/models/booking_model.dart';
import '../../../../../core/models/maintenance_ticket_model.dart';
import '../../../../../core/models/room_model.dart';
import '../../../../../core/models/user_model.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/booking_service.dart';
import '../../../../../core/services/hotel_service.dart';
import '../../../../../core/services/maintenance_service.dart';
import '../widgets/fo_barcode_scanner_modal.dart';

/// Tab 1: Overview Dashboard Front Office (100% Dinamis dari Database)
class FoDashboardTab extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const FoDashboardTab({super.key, this.onNavigateTab});

  @override
  State<FoDashboardTab> createState() => _FoDashboardTabState();
}

class _FoDashboardTabState extends State<FoDashboardTab> {
  List<RoomModel> _rooms = [];
  List<BookingModel> _bookings = [];
  List<Map<String, dynamic>> _physicalRooms = [];
  List<Map<String, dynamic>> _maintenanceStaff = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    final userHotelId = AuthService.instance.currentUser?.managedHotelId;
    final hotelId =
        (userHotelId != null && userHotelId.isNotEmpty) ? userHotelId : '1';
    final svcKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
        ? SupabaseConfig.supabaseServiceRoleKey
        : SupabaseConfig.activeApiKey;
    final headers = {
      'apikey': svcKey,
      'Authorization': 'Bearer $svcKey',
    };

    try {
      final results = await Future.wait([
        HotelService.instance.getRoomsByHotel(hotelId),
        BookingService.instance.getHotelBookings(hotelId),
        http.get(
          Uri.parse(
              '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableKamar}?id_penginapan=eq.$hotelId&select=*,tipe_kamar(nama_tipe,harga_dasar)&order=nomor_kamar.asc'),
          headers: headers,
        ),
        http.get(
          Uri.parse(
              '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableStafHotel}?id_penginapan=eq.$hotelId&role_jabatan=eq.maintenance&select=*'),
          headers: headers,
        ),
      ]);

      final physResp = results[2] as http.Response;
      final List<Map<String, dynamic>> physList = physResp.statusCode == 200
          ? List<Map<String, dynamic>>.from(jsonDecode(physResp.body))
          : [];

      final mtcResp = results[3] as http.Response;
      final List<Map<String, dynamic>> mtcList = mtcResp.statusCode == 200
          ? List<Map<String, dynamic>>.from(jsonDecode(mtcResp.body))
          : [];

      if (mounted) {
        setState(() {
          _rooms = results[0] as List<RoomModel>;
          _bookings = results[1] as List<BookingModel>;
          _physicalRooms = physList;
          _maintenanceStaff = mtcList;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Modal Cek Kondisi Kamar Real-Time (Kosong / Terisi / Kotor / Maintenance)
  void _showCheckRoomsSheet() {
    String filter = 'Semua'; // Semua, Kosong, Terisi, Perlu Bersih
    final activeBookings =
        _bookings.where((b) => b.status == BookingStatus.checkedIn).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final sourceList = _physicalRooms.isNotEmpty
                ? _physicalRooms
                : _rooms
                    .map((r) => {
                          'id_kamar': r.id,
                          'nomor_kamar': r.typeName,
                          'lantai': '1',
                          'status_kamar': r.status.displayName,
                          'tipe_kamar': {'nama_tipe': r.typeName},
                        })
                    .toList();

            final filtered = sourceList.where((r) {
              final statusStr =
                  (r['status_kamar'] ?? 'Tersedia').toString().toLowerCase();
              if (filter == 'Kosong') {
                return statusStr.contains('tersedia') ||
                    statusStr.contains('available') ||
                    statusStr.contains('ready');
              }
              if (filter == 'Terisi') {
                return statusStr.contains('terisi') ||
                    statusStr.contains('occupied') ||
                    statusStr.contains('booked');
              }
              if (filter == 'Perlu Bersih') {
                return statusStr.contains('kotor') ||
                    statusStr.contains('dirty') ||
                    statusStr.contains('clean') ||
                    statusStr.contains('rusak') ||
                    statusStr.contains('maint');
              }
              return true;
            }).toList();

            final totalCount = sourceList.length;
            final emptyCount = sourceList.where((r) {
              final s =
                  (r['status_kamar'] ?? 'Tersedia').toString().toLowerCase();
              return s.contains('tersedia') ||
                  s.contains('available') ||
                  s.contains('ready');
            }).length;
            final occupiedCount = sourceList.where((r) {
              final s = (r['status_kamar'] ?? '').toString().toLowerCase();
              return s.contains('terisi') ||
                  s.contains('occupied') ||
                  s.contains('booked');
            }).length;

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.82,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFD),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 10, 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F4FB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.meeting_room_rounded,
                              color: Color(0xFF00758F), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cek Kondisi Kamar Hotel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '$totalCount Unit • $emptyCount Kosong • $occupiedCount Terisi',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: ['Semua', 'Kosong', 'Terisi', 'Perlu Bersih']
                          .map((f) {
                        final sel = filter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              f,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: sel
                                    ? Colors.white
                                    : const Color(0xFF334155),
                              ),
                            ),
                            selected: sel,
                            selectedColor: const Color(0xFF00758F),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: sel
                                  ? const Color(0xFF00758F)
                                  : const Color(0xFFE2E8F0),
                            ),
                            onSelected: (_) =>
                                setSheetState(() => filter = f),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada kamar sesuai filter ini.',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final item = filtered[i];
                              final roomNo =
                                  (item['nomor_kamar'] ?? '-').toString();
                              final floor = (item['lantai'] ?? '1').toString();
                              final rawStatus =
                                  (item['status_kamar'] ?? 'Tersedia')
                                      .toString();
                              final statusLower = rawStatus.toLowerCase();
                              final tipeMap = item['tipe_kamar'];
                              final tipeName = tipeMap is Map
                                  ? (tipeMap['nama_tipe'] ?? 'Kamar')
                                      .toString()
                                  : 'Kamar';

                              final isEmpty =
                                  statusLower.contains('tersedia') ||
                                      statusLower.contains('available') ||
                                      statusLower.contains('ready');
                              final isOccupied =
                                  statusLower.contains('terisi') ||
                                      statusLower.contains('occupied') ||
                                      statusLower.contains('booked');
                              final isDirty = statusLower.contains('kotor') ||
                                  statusLower.contains('dirty') ||
                                  statusLower.contains('clean');

                              Color badgeBg = const Color(0xFFDCFCE7);
                              Color badgeFg = const Color(0xFF15803D);
                              String statusLabel = 'Kosong • Siap Huni';

                              if (isOccupied) {
                                badgeBg = const Color(0xFFE0F2FE);
                                badgeFg = const Color(0xFF0369A1);
                                statusLabel = 'Ada Tamu (Terisi)';
                              } else if (isDirty) {
                                badgeBg = const Color(0xFFFEF3C7);
                                badgeFg = const Color(0xFFB45309);
                                statusLabel = 'Kotor / Perlu Bersih';
                              } else if (!isEmpty) {
                                badgeBg = const Color(0xFFFEE2E2);
                                badgeFg = const Color(0xFFDC2626);
                                statusLabel = rawStatus;
                              }

                              String? occupantName;
                              if (isOccupied && activeBookings.isNotEmpty) {
                                final matched = activeBookings.where((b) =>
                                    b.roomTypeName.toLowerCase() ==
                                    tipeName.toLowerCase());
                                if (matched.isNotEmpty) {
                                  occupantName = matched.first.customerName;
                                }
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        roomNo,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: badgeFg,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Kamar $roomNo • Lt. $floor',
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            occupantName != null
                                                ? '$tipeName • Tamu: $occupantName'
                                                : tipeName,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF64748B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: badgeFg,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Modal Contact Maintenance (Daftar Petugas & Kirim Pesan/Tiket ke Maintenance)
  void _showContactMaintenanceSheet() {
    final roomCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 14,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFBEF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.build_circle_outlined,
                                  color: Color(0xFF0D9488), size: 22),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Hubungi Tim Maintenance',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Daftar Petugas Maintenance yang terdaftar di DB
                    const Text(
                      'Petugas Maintenance Aktif',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_maintenanceStaff.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          'Belum ada petugas maintenance terdaftar. Anda tetap dapat mengirim laporan di bawah ini.',
                          style:
                              TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      )
                    else
                      ..._maintenanceStaff.map((m) {
                        final nama = (m['nama_staf'] ?? 'Teknisi').toString();
                        final shift = (m['shift_tugas'] ?? '-').toString();
                        final telp = (m['no_telepon'] ?? '-').toString();
                        final duty = (m['status_duty'] ?? 'Off').toString();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFFCCFBEF),
                                child: Text(
                                  nama.isNotEmpty ? nama[0].toUpperCase() : 'M',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0D9488),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nama,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      'Shift: $shift • Telp: $telp',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: duty.toLowerCase().contains('on')
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  duty,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: duty.toLowerCase().contains('on')
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 14),
                    const Text(
                      'Kirim Permintaan / Laporan ke Maintenance',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: roomCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nomor Kamar / Area',
                        hintText: 'Masukkan nomor kamar (contoh: 102)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: msgCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Pesan / Kendala',
                        hintText: 'Masukkan pesan atau kendala untuk maintenance',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: isSending
                            ? null
                            : () async {
                                final msg = msgCtrl.text.trim();
                                final room = roomCtrl.text.trim();
                                if (msg.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Pesan untuk tim maintenance wajib diisi.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                setSheetState(() => isSending = true);
                                try {
                                  final userHotelId = AuthService
                                      .instance.currentUser?.managedHotelId;
                                  final hotelId = (userHotelId != null &&
                                          userHotelId.isNotEmpty)
                                      ? userHotelId
                                      : '1';
                                  final ticket = MaintenanceTicketModel(
                                    id: 'MTC-${DateTime.now().millisecondsSinceEpoch}',
                                    hotelId: hotelId,
                                    roomNumber: room.isNotEmpty ? room : 'Umum',
                                    title: room.isNotEmpty
                                        ? 'Permintaan FO - Kamar $room'
                                        : 'Permintaan Front Office',
                                    description: msg,
                                    category: 'Pemeliharaan',
                                    priority: MaintenancePriority.medium,
                                    status: MaintenanceStatus.open,
                                    reportedById: AuthService
                                            .instance.currentUser?.id ??
                                        'FO',
                                    reportedByName: AuthService
                                            .instance.currentUser?.fullName ??
                                        'Front Office',
                                    createdAt: DateTime.now(),
                                  );
                                  await MaintenanceService.instance
                                      .createTicket(ticket);
                                  if (!ctx.mounted) return;
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Laporan berhasil dikirim ke tim Maintenance!'),
                                      backgroundColor: Color(0xFF0D9488),
                                    ),
                                  );
                                } catch (e) {
                                  setSheetState(() => isSending = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Gagal mengirim: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        icon: isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded, size: 17),
                        label: const Text(
                          'Kirim ke Maintenance',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _rooms.isEmpty && _bookings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C2FF)),
      );
    }
    return _buildDashboardTab();
  }

  Widget _buildDashboardTab() {
    final currentUser = AuthService.instance.currentUser;
    final staffName = currentUser?.fullName ?? 'Staff FO';
    final initials = staffName.trim().isNotEmpty
        ? staffName
            .trim()
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'FO';
    final roleLabel =
        currentUser?.role.displayName ?? 'Front Office & Resepsionis';

    // Hitung okupansi & status kamar dari data REAL
    final totalRooms = _physicalRooms.isNotEmpty
        ? _physicalRooms.length
        : _rooms.fold<int>(0, (sum, r) => sum + r.totalUnits);
    final occupiedRooms = _physicalRooms.isNotEmpty
        ? _physicalRooms.where((r) {
            final s = (r['status_kamar'] ?? '').toString().toLowerCase();
            return s.contains('terisi') ||
                s.contains('occupied') ||
                s.contains('booked');
          }).length
        : _bookings.where((b) => b.status == BookingStatus.checkedIn).length;
    final occupancyPercent =
        totalRooms > 0 ? ((occupiedRooms / totalRooms) * 100).round() : 0;

    final totalCheckIn = _bookings
        .where((b) =>
            b.status == BookingStatus.checkedIn ||
            b.status == BookingStatus.confirmed)
        .length;
    final pendingCheckIn =
        _bookings.where((b) => b.status == BookingStatus.confirmed).length;
    final doneCheckIn =
        _bookings.where((b) => b.status == BookingStatus.checkedIn).length;

    final checkOutCount =
        _bookings.where((b) => b.status == BookingStatus.checkedOut).length;
    final dirtyRoomsCount = _physicalRooms.isNotEmpty
        ? _physicalRooms.where((r) {
            final s = (r['status_kamar'] ?? '').toString().toLowerCase();
            return s.contains('kotor') || s.contains('dirty');
          }).length
        : _rooms.where((r) => r.status == RoomStatus.dirty).length;

    final pendingVerificationCount = _bookings
        .where((b) =>
            b.status == BookingStatus.pendingVerification ||
            b.status == BookingStatus.pendingPayment)
        .length;

    return RefreshIndicator(
      onRefresh: _loadSummary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card Profile User (Tanpa ikon notifikasi)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF334155),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                staffName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              color: Color(0xFF0284C7),
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          roleLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Besar Buka Scanner QR E-Tiket
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final res = await FoBarcodeScannerModal.show(
                    context,
                    availableBookings: _bookings,
                  );
                  if (res != null) {
                    _loadSummary();
                  }
                },
                icon: const Icon(Icons.qr_code_scanner_rounded,
                    color: Colors.white, size: 26),
                label: const Text(
                  'Buka Scanner',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0096B4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Ringkasan Operasional
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Ringkasan Operasional',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'HARI INI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0284C7),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Baris 1 (Atas): Check-In & Check-Out Sejajar
            Row(
              children: [
                // Card 1: Check-In
                Expanded(
                  child: _buildSummaryCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Check-In',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                            Icon(Icons.login_rounded,
                                size: 16, color: Color(0xFF0284C7)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$totalCheckIn',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Tamu',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$pendingCheckIn Menunggu • $doneCheckIn Selesai',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00C2FF),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                pendingCheckIn > 0
                                    ? '$pendingCheckIn siap check-in'
                                    : 'Semua telah check-in',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Card 2: Check-Out
                Expanded(
                  child: _buildSummaryCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Check-Out',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                            Icon(Icons.logout_rounded,
                                size: 16, color: Color(0xFF0284C7)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$checkOutCount',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Kamar',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$dirtyRoomsCount Perlu Bersih • $checkOutCount Beres',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF94A3B8),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '$dirtyRoomsCount unit kotor',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Baris 2 (Bawah): Okupansi Kamar & Verifikasi Sejajar
            Row(
              children: [
                // Card 3: Okupansi Kamar
                Expanded(
                  child: _buildSummaryCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Okupansi Kamar',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                            Icon(Icons.bed_outlined,
                                size: 16, color: Color(0xFF0284C7)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF00C2FF), width: 3),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$occupancyPercent%',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$occupiedRooms / $totalRooms',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const Text(
                                    'Kamar terisi',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (occupancyPercent / 100.0).clamp(0.0, 1.0),
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF00C2FF)),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Card 4: Verifikasi
                Expanded(
                  child: _buildSummaryCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Verifikasi',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                            Icon(Icons.assignment_late_outlined,
                                size: 16, color: Color(0xFFDC2626)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$pendingVerificationCount',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pengajuan baru tiket',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                pendingVerificationCount > 0
                                    ? '$pendingVerificationCount perlu disetujui'
                                    : 'Semua telah diverifikasi',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Aksi Cepat Petugas (3 Tombol Sejajar Horizontal)
            const Text(
              'Aksi Cepat Petugas',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCompact(
                    icon: Icons.hotel_rounded,
                    iconBg: const Color(0xFFBAF0FD),
                    iconColor: const Color(0xFF00758F),
                    title: 'Cek Kamar',
                    onTap: _showCheckRoomsSheet,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionCompact(
                    icon: Icons.badge_outlined,
                    iconBg: const Color(0xFFEDE9FE),
                    iconColor: const Color(0xFF6D28D9),
                    title: 'Daftar Tamu',
                    onTap: () => widget.onNavigateTab?.call(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionCompact(
                    icon: Icons.support_agent_rounded,
                    iconBg: const Color(0xFFCCFBEF),
                    iconColor: const Color(0xFF0D9488),
                    title: 'Contact\nMaintenance',
                    onTap: _showContactMaintenanceSheet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tautan Syarat & Ketentuan (Terms & Policies)
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const TermsAndPolicyScreen()),
                  );
                },
                child: const Text(
                  'Syarat & Ketentuan (Terms & Policies)',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0284C7),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildQuickActionCompact({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
