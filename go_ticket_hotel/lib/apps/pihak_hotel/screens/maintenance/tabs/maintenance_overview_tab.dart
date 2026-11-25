import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_ticket_hotel/core/widgets/terms_and_policy_screen.dart';
import '../../../../../core/config/supabase_config.dart';
import '../../../../../core/models/maintenance_ticket_model.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/maintenance_service.dart';

/// Tab 1: Dashboard Operasional Maintenance & Housekeeping
/// 100% dinamis dari Supabase – tanpa data mockup.
class MaintenanceOverviewTab extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const MaintenanceOverviewTab({super.key, this.onNavigateTab});

  @override
  State<MaintenanceOverviewTab> createState() => _MaintenanceOverviewTabState();
}

class _MaintenanceOverviewTabState extends State<MaintenanceOverviewTab> {
  List<MaintenanceTicketModel> _tickets = [];
  List<Map<String, dynamic>> _usedRooms = [];
  bool _isLoading = true;

  // 0: Hari Ini, 1: Minggu Ini, 2: Bulan Ini, 3: Tahun Ini, 4: Custom
  int _timeFilterIndex = 0;
  DateTimeRange? _customRange;

  final List<String> _timeLabels = const [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
    'Tahun Ini',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final hotelId = AuthService.instance.currentUser?.managedHotelId ?? '1';
      final svcKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
          ? SupabaseConfig.supabaseServiceRoleKey
          : SupabaseConfig.activeApiKey;

      final results = await Future.wait([
        MaintenanceService.instance.getTickets(),
        http.get(
          Uri.parse(
              '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableKamar}?id_penginapan=eq.$hotelId&select=*,tipe_kamar(nama_tipe)&order=nomor_kamar.asc'),
          headers: {
            'apikey': svcKey,
            'Authorization': 'Bearer $svcKey',
          },
        ),
      ]);

      final tickets = results[0] as List<MaintenanceTicketModel>;
      final kamarResp = results[1] as http.Response;

      final List<Map<String, dynamic>> usedRooms = [];
      if (kamarResp.statusCode == 200) {
        final List<dynamic> allRooms = jsonDecode(kamarResp.body);
        for (final r in allRooms) {
          final status = (r['status_kamar'] ?? '').toString().toLowerCase();
          // Kamar yang sudah dipakai / perlu dicek & dibersihkan
          if (status.contains('kotor') ||
              status.contains('dirty') ||
              status.contains('terisi') ||
              status.contains('occupied') ||
              status.contains('proses') ||
              status.contains('clean')) {
            usedRooms.add(Map<String, dynamic>.from(r));
          }
        }
      }

      if (mounted) {
        setState(() {
          _tickets = tickets;
          _usedRooms = usedRooms;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _customRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00758F),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _customRange = picked;
        _timeFilterIndex = 4;
      });
    }
  }

  List<MaintenanceTicketModel> get _filteredTickets {
    final now = DateTime.now();
    return _tickets.where((t) {
      final dt = t.createdAt;
      switch (_timeFilterIndex) {
        case 0: // Hari Ini
          return dt.year == now.year &&
              dt.month == now.month &&
              dt.day == now.day;
        case 1: // Minggu Ini
          final startOfWeek =
              DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
          return !dt.isBefore(startOfWeek);
        case 2: // Bulan Ini
          return dt.year == now.year && dt.month == now.month;
        case 3: // Tahun Ini
          return dt.year == now.year;
        case 4: // Custom
          if (_customRange == null) return true;
          final start = DateTime(_customRange!.start.year,
              _customRange!.start.month, _customRange!.start.day);
          final end = DateTime(_customRange!.end.year, _customRange!.end.month,
              _customRange!.end.day, 23, 59, 59);
          return !dt.isBefore(start) && !dt.isAfter(end);
        default:
          return true;
      }
    }).toList();
  }

  /// Modal Cek & Data Kondisi Kamar yang Sudah Dipakai
  void _showRoomInspectModal(Map<String, dynamic> room) {
    final roomNo = (room['nomor_kamar'] ?? room['id_kamar']).toString();
    final idKamar = room['id_kamar'].toString();
    final tipeMap = room['tipe_kamar'];
    final tipeName =
        tipeMap is Map ? (tipeMap['nama_tipe'] ?? 'Kamar').toString() : 'Kamar';
    String selectedCondition = 'Siap Huni (Tersedia)';
    final notesCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 16,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cek & Data Kamar $roomNo',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  '$tipeName • Lantai ${room['lantai'] ?? 1}',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedCondition,
                  decoration: InputDecoration(
                    labelText: 'Hasil Pengecekan & Status',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Siap Huni (Tersedia)',
                      child: Text('Siap Huni (Bersih & Tersedia)',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                    DropdownMenuItem(
                      value: 'Sedang Dibersihkan',
                      child: Text('Sedang Dibersihkan',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                    DropdownMenuItem(
                      value: 'Kotor',
                      child: Text('Perlu Pembersihan (Kotor)',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                    DropdownMenuItem(
                      value: 'Maintenance',
                      child: Text('Perlu Perbaikan (Maintenance)',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setSheetState(() => selectedCondition = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Catatan Pengecekan',
                    hintText: 'Masukkan catatan hasil pengecekan kamar',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () async {
                            setSheetState(() => isSaving = true);
                            try {
                              final svcKey = SupabaseConfig
                                      .supabaseServiceRoleKey.isNotEmpty
                                  ? SupabaseConfig.supabaseServiceRoleKey
                                  : SupabaseConfig.activeApiKey;
                              final newStatus =
                                  selectedCondition.contains('Tersedia')
                                      ? 'Tersedia'
                                      : selectedCondition;

                              await http.patch(
                                Uri.parse(
                                    '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableKamar}?id_kamar=eq.$idKamar'),
                                headers: {
                                  'apikey': svcKey,
                                  'Authorization': 'Bearer $svcKey',
                                  'Content-Type': 'application/json',
                                },
                                body: jsonEncode({'status_kamar': newStatus}),
                              );

                              // Catat ke laporan_kebersihan
                              await http.post(
                                Uri.parse(
                                    '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableLaporanKebersihan}'),
                                headers: {
                                  'apikey': svcKey,
                                  'Authorization': 'Bearer $svcKey',
                                  'Content-Type': 'application/json',
                                  'Prefer': 'return=minimal',
                                },
                                body: jsonEncode({
                                  'id_kamar': roomNo,
                                  'id_staf':
                                      AuthService.instance.currentUser?.id ??
                                          'MTC',
                                  'status_kebersihan': selectedCondition,
                                  'catatan_sanitasi': notesCtrl.text.trim(),
                                  'tgl_tugas': DateTime.now().toIso8601String(),
                                }),
                              );

                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Data pengecekan Kamar $roomNo disimpan!'),
                                  backgroundColor: const Color(0xFF059669),
                                ),
                              );
                              _loadData();
                            } catch (e) {
                              setSheetState(() => isSaving = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal menyimpan: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Simpan Pengecekan',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00758F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Langsung bersihkan kamar & ubah status ke Tersedia di database
  Future<void> _markRoomCleaned(Map<String, dynamic> room) async {
    final roomNo = (room['nomor_kamar'] ?? room['id_kamar']).toString();
    final idKamar = room['id_kamar'].toString();
    try {
      final svcKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
          ? SupabaseConfig.supabaseServiceRoleKey
          : SupabaseConfig.activeApiKey;

      await http.patch(
        Uri.parse(
            '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableKamar}?id_kamar=eq.$idKamar'),
        headers: {
          'apikey': svcKey,
          'Authorization': 'Bearer $svcKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status_kamar': 'Tersedia'}),
      );

      await http.post(
        Uri.parse(
            '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableLaporanKebersihan}'),
        headers: {
          'apikey': svcKey,
          'Authorization': 'Bearer $svcKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'id_kamar': roomNo,
          'id_staf': AuthService.instance.currentUser?.id ?? 'MTC',
          'status_kebersihan': 'Selesai Dibersihkan (Siap Huni)',
          'catatan_sanitasi': 'Pembersihan & sanitasi selesai dilakukan.',
          'tgl_tugas': DateTime.now().toIso8601String(),
        }),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kamar $roomNo telah dibersihkan & siap huni!'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status kamar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF00C2FF)));
    }

    final filtered = _filteredTickets;
    final openTickets =
        filtered.where((t) => t.status == MaintenanceStatus.open).toList();
    final inProgressTickets = filtered
        .where((t) => t.status == MaintenanceStatus.inProgress)
        .toList();
    final resolvedTickets = filtered
        .where((t) =>
            t.status == MaintenanceStatus.resolved ||
            t.status == MaintenanceStatus.closed)
        .toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Waktu (Hari Ini, Minggu Ini, Bulan Ini, Tahun Ini, Custom)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_timeLabels.length, (i) {
                  final sel = _timeFilterIndex == i;
                  String label = _timeLabels[i];
                  if (i == 4 && _customRange != null && sel) {
                    label =
                        '${_customRange!.start.day}/${_customRange!.start.month} - ${_customRange!.end.day}/${_customRange!.end.month}';
                  }
                  return GestureDetector(
                    onTap: () {
                      if (i == 4) {
                        _pickCustomRange();
                      } else {
                        setState(() => _timeFilterIndex = i);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFF00758F) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? const Color(0xFF00758F)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (i == 4) ...[
                            Icon(Icons.date_range_rounded,
                                size: 13,
                                color: sel
                                    ? Colors.white
                                    : const Color(0xFF64748B)),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight:
                                  sel ? FontWeight.w800 : FontWeight.w600,
                              color: sel
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Header Metrik Operasional
            const Text(
              'Ringkasan Tugas & Pemeliharaan',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            // 2x2 Grid Metrik
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.fact_check_outlined,
                    iconColor: const Color(0xFFDC2626),
                    iconBg: const Color(0xFFFEE2E2),
                    hasDot: openTickets.isNotEmpty,
                    number: '${openTickets.length}',
                    unit: 'Tugas',
                    title: 'Perlu Pengecekan',
                    subtitle: '${openTickets.length} perlu dicek',
                    subtitleColor: openTickets.isEmpty
                        ? const Color(0xFF64748B)
                        : const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.hourglass_top_rounded,
                    iconColor: const Color(0xFFD97706),
                    iconBg: const Color(0xFFFEF3C7),
                    badgeText: inProgressTickets.isNotEmpty ? 'Proses' : null,
                    badgeBg: const Color(0xFFFEF3C7),
                    badgeTextColor: const Color(0xFFB45309),
                    number: '${inProgressTickets.length}',
                    unit: 'Tugas',
                    title: 'Sedang Dikerjakan',
                    subtitle: '${inProgressTickets.length} dalam proses',
                    subtitleColor: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.verified_outlined,
                    iconColor: const Color(0xFF059669),
                    iconBg: const Color(0xFFD1FAE5),
                    badgeText: resolvedTickets.isNotEmpty ? 'Selesai' : null,
                    badgeBg: const Color(0xFFD1FAE5),
                    badgeTextColor: const Color(0xFF059669),
                    number: '${resolvedTickets.length}',
                    unit: 'Tugas',
                    title: 'Tugas Selesai',
                    subtitle: '${resolvedTickets.length} diselesaikan',
                    subtitleColor: const Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.assessment_outlined,
                    iconColor: const Color(0xFF0284C7),
                    iconBg: const Color(0xFFE0F2FE),
                    number: '${filtered.length}',
                    unit: 'Total',
                    title: 'Total Tugas',
                    subtitle: '${filtered.length} tercatat',
                    subtitleColor: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bagian Kamar yang Sudah Dipakai (Cek, Data & Bersihkan)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kamar Sudah Dipakai',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${_usedRooms.length} Kamar',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_usedRooms.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'Seluruh kamar sudah dalam kondisi bersih & siap huni.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              )
            else
              ..._usedRooms.map((room) => _buildUsedRoomCard(room)),

            const SizedBox(height: 20),

            // Daftar Tugas Pemeliharaan Terkini
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Tugas Terkini',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Total ${filtered.length}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (filtered.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'Semua unit operasional berjalan normal pada periode ini.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              )
            else
              ...filtered.take(5).map((t) => _buildTicketCard(t)),

            const SizedBox(height: 18),

            // Tautan Syarat & Ketentuan
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

  Widget _buildUsedRoomCard(Map<String, dynamic> room) {
    final roomNo = (room['nomor_kamar'] ?? room['id_kamar']).toString();
    final floor = (room['lantai'] ?? '1').toString();
    final status = (room['status_kamar'] ?? 'Kotor').toString();
    final tipeMap = room['tipe_kamar'];
    final tipeName =
        tipeMap is Map ? (tipeMap['nama_tipe'] ?? 'Kamar').toString() : 'Kamar';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bed_outlined,
                        color: Color(0xFFD97706), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kamar $roomNo • Lt. $floor',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        tipeName,
                        style: const TextStyle(
                            fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRoomInspectModal(room),
                  icon: const Icon(Icons.fact_check_outlined, size: 15),
                  label: const Text('Cek & Data',
                      style:
                          TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00758F),
                    side: const BorderSide(color: Color(0xFFBAE6FD)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _markRoomCleaned(room),
                  icon: const Icon(Icons.cleaning_services_rounded,
                      size: 15, color: Colors.white),
                  label: const Text('Bersihkan',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(MaintenanceTicketModel t) {
    final statusBg = t.status == MaintenanceStatus.open
        ? const Color(0xFFFEE2E2)
        : t.status == MaintenanceStatus.inProgress
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFD1FAE5);
    final statusFg = t.status == MaintenanceStatus.open
        ? const Color(0xFFDC2626)
        : t.status == MaintenanceStatus.inProgress
            ? const Color(0xFFB45309)
            : const Color(0xFF059669);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    t.roomNumber != null
                        ? 'Kamar #${t.roomNumber}'
                        : 'ID #${t.id}',
                    style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t.status.displayName,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusFg),
                    ),
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.build_outlined,
                    color: Color(0xFF64748B), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(t.title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(
            '${t.category} • Pelapor: ${t.reportedByName}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag_outlined,
                      size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    t.priority.displayName,
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => widget.onNavigateTab?.call(2),
                icon: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 14),
                label: const Text('Detail',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00667C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    bool hasDot = false,
    String? badgeText,
    Color? badgeBg,
    Color? badgeTextColor,
    required String number,
    required String unit,
    required String title,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              if (hasDot)
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: iconColor, shape: BoxShape.circle))
              else if (badgeText != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: badgeBg, borderRadius: BorderRadius.circular(8)),
                  child: Text(badgeText,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(number,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A))),
              const SizedBox(width: 4),
              Text(unit,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: subtitleColor)),
        ],
      ),
    );
  }
}
