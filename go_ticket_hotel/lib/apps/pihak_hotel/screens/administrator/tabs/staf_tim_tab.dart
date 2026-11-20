import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:go_ticket_hotel/core/widgets/app_pagination_bar.dart';
import '../../../../../core/config/supabase_config.dart';
import '../../../../../core/models/hotel_admin_model.dart';
import '../../../../../core/theme/hotel_admin_theme.dart';
import 'add_staff_screen.dart';
import 'edit_staff_screen.dart';
import '../widgets/request_admin_email_sheet.dart';

/// Tab 3: Manajemen Staf & Hak Akses Administrator
/// Menampilkan daftar karyawan dengan filter 3 Role Utama:
/// 1. Administrator
/// 2. Maintenance
/// 3. Staf (Front Office)
class StafTimTab extends StatefulWidget {
  final List<StaffData> staff;
  final VoidCallback? onRefresh;

  const StafTimTab({super.key, required this.staff, this.onRefresh});

  @override
  State<StafTimTab> createState() => _StafTimTabState();
}

class _StafTimTabState extends State<StafTimTab> {
  // 0: Semua, 1: Administrator, 2: Maintenance, 3: Staf
  int _roleFilterIndex = 0;
  int _currentPage = 1;

  List<StaffData> get _filteredStaff {
    switch (_roleFilterIndex) {
      case 1:
        return widget.staff
            .where((s) => s.role.toLowerCase().contains('admin'))
            .toList();
      case 2:
        return widget.staff
            .where((s) =>
                s.role.toLowerCase().contains('maint') ||
                s.role.toLowerCase().contains('housekeeping'))
            .toList();
      case 3:
        return widget.staff
            .where((s) =>
                s.role.toLowerCase().contains('staf') ||
                s.role.toLowerCase().contains('front'))
            .toList();
      default:
        return widget.staff;
    }
  }

  int get _adminCount => widget.staff
      .where((s) => s.role.toLowerCase().contains('admin'))
      .length;

  int get _maintenanceCount => widget.staff
      .where((s) =>
          s.role.toLowerCase().contains('maint') ||
          s.role.toLowerCase().contains('housekeeping'))
      .length;

  int get _stafCount => widget.staff
      .where((s) =>
          s.role.toLowerCase().contains('staf') ||
          s.role.toLowerCase().contains('front'))
      .length;

  int get _pagiCount => widget.staff
      .where((s) => s.shift?.toLowerCase().contains('pagi') == true)
      .length;

  int get _siangCount => widget.staff
      .where((s) =>
          s.shift?.toLowerCase().contains('siang') == true ||
          s.shift?.toLowerCase().contains('sore') == true)
      .length;

  int get _malamCount => widget.staff
      .where((s) => s.shift?.toLowerCase().contains('malam') == true)
      .length;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredStaff;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title
        const Text(
          'Manajemen Staf & Hak Akses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        // Bright Cyan Pill Button: + Tambah Karyawan Baru
        ElevatedButton.icon(
          onPressed: () async {
            final res = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddStaffScreen()),
            );
            if (res == true) {
              widget.onRefresh?.call();
            }
          },
          icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
          label: const Text(
            '+ Tambah Karyawan Baru',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: cNormal,
            foregroundColor: const Color(0xFF00383D),
            minimumSize: const Size.fromHeight(46),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 8),

        // Outlined Button: Request Penambahan Akun Administrator via Email ke Go Ticket
        OutlinedButton.icon(
          onPressed: () => showRequestAdminEmailModal(context),
          icon: const Icon(Icons.mark_email_unread_outlined, size: 16, color: Color(0xFF00758F)),
          label: const Text(
            'Ajukan Akun Admin Baru (Email ke Go Ticket)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF00758F)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFBAE6FD)),
            minimumSize: const Size.fromHeight(40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        const SizedBox(height: 16),

        // Status Roster Hari Ini (Dihitung Dinamis dari Database)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.calendar_month_outlined,
                    size: 15, color: Color(0xFF0F172A)),
                SizedBox(width: 6),
                Text(
                  'Status Roster Hari Ini',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A)),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: cLight, borderRadius: BorderRadius.circular(10)),
              child: const Text('Live Sync',
                  style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: cDarkActive)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 3 Kartu Ringkasan Shift Hari Ini
        Row(
          children: [
            Expanded(
              child: _buildShiftSummaryCard(
                time: '07:00 – 15:00',
                title: 'Shift Pagi',
                count: _pagiCount,
                color: const Color(0xFF0284C7),
                bg: const Color(0xFFE0F4FB),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildShiftSummaryCard(
                time: '15:00 – 23:00',
                title: 'Shift Siang',
                count: _siangCount,
                color: const Color(0xFFD97706),
                bg: const Color(0xFFFEF3C7),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildShiftSummaryCard(
                time: '23:00 – 07:00',
                title: 'Shift Malam',
                count: _malamCount,
                color: const Color(0xFF7C3AED),
                bg: const Color(0xFFEDE9FE),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Role Filter Tabs (Sesuai 3 Roles Hotel)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRoleFilterTab(0, 'Semua (${widget.staff.length})'),
              _buildRoleFilterTab(1, 'Administrator ($_adminCount)'),
              _buildRoleFilterTab(2, 'Maintenance ($_maintenanceCount)'),
              _buildRoleFilterTab(3, 'Staf ($_stafCount)'),
            ],
          ),
        ),

        const SizedBox(height: 14),

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: adminCardBorder),
            ),
            child: Column(
              children: [
                const Icon(Icons.people_outline,
                    size: 44, color: Color(0xFF94A3B8)),
                const SizedBox(height: 10),
                Text(
                  _roleFilterIndex == 0
                      ? 'Belum ada karyawan terdaftar'
                      : 'Tidak ada karyawan dengan role ini',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Gunakan tombol "+ Tambah Karyawan Baru" untuk mendaftarkan akun baru.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          )
        else ...[
          Builder(
            builder: (ctx) {
              final total = filtered.length;
              final maxPage = (total / 10).ceil();
              final safePage = _currentPage.clamp(1, maxPage > 0 ? maxPage : 1);
              final pagedStaff = paginateList(filtered, safePage, pageSize: 10);

              return Column(
                children: [
                  for (final s in pagedStaff) _buildStaffCard(s),
                  AppPaginationBar(
                    currentPage: safePage,
                    totalItems: total,
                    pageSize: 10,
                    itemLabel: 'karyawan',
                    primaryColor: cDarkActive,
                    onPageChanged: (newPage) => setState(() => _currentPage = newPage),
                  ),
                ],
              );
            },
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildShiftSummaryCard({
    required String time,
    required String title,
    required int count,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: adminCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(time,
                  style:
                      const TextStyle(fontSize: 8.5, color: Color(0xFF64748B))),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$count Karyawan',
            style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A)),
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 9.5, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterTab(int index, String label) {
    final sel = _roleFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        _roleFilterIndex = index;
        _currentPage = 1;
      }),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? cDarkActive : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? cDarkActive : adminCardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: sel ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard(StaffData s) {
    final isDuty = s.statusLabel == 'On-Duty';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: adminCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar Profil
              Stack(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: const Color(0xFFE0F4FB),
                    backgroundImage: s.avatarUrl.isNotEmpty
                        ? NetworkImage(s.avatarUrl)
                        : null,
                    child: s.avatarUrl.isEmpty
                        ? Text(
                            s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF007A87),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: isDuty
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Nama, ID Petugas, & Role Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            s.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            s.id,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: s.statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            s.role,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: s.statusFg,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isDuty ? '• On-Duty' : '• Off-Duty',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDuty
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol Hapus Cepat (Trash)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), size: 20),
                tooltip: 'Hapus Akun Karyawan',
                onPressed: () => _confirmDeleteStaff(s),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Info Shift Tugas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 13, color: Color(0xFF007A87)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Shift: ${s.shift ?? "Shift Pagi (07:00 – 15:00 WIB)"}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Hak Akses Modul Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HAK AKSES AKTIF:',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: s.akses.map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: adminCardBorder),
                      ),
                      child: Text(
                        '✔ $a',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // WhatsApp & Kontak
          Row(
            children: [
              const Icon(Icons.phone_android,
                  size: 12, color: Color(0xFF007A87)),
              const SizedBox(width: 4),
              Text(
                'Kontak: ${s.wa}',
                style:
                    const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2 Tombol Aksi: [ Atur Shift ] dan [ Kelola Akses ]
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showShiftBottomSheet(s),
                  icon: const Icon(Icons.schedule_rounded, size: 13),
                  label: const Text('Atur Shift'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    textStyle: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditStaffScreen(
                          staffName: s.name,
                          staffId: s.id,
                          initialRole: s.role,
                          staff: s,
                        ),
                      ),
                    );
                    if (res == true) {
                      widget.onRefresh?.call();
                    }
                  },
                  icon: const Icon(Icons.shield_outlined, size: 13),
                  label: const Text('Kelola Akses'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: cLight,
                    foregroundColor: cDarkActive,
                    side: const BorderSide(color: cLightActive),
                    textStyle: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Form Bottom Sheet Khusus Atur Shift Karyawan Terdaftar
  void _showShiftBottomSheet(StaffData s) {
    String selectedShift = s.shift ?? 'Shift Pagi (07:00 – 15:00 WIB)';
    bool isDuty = s.statusLabel == 'On-Duty';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Atur Shift & Jam Kerja',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              '${s.name} (${s.id}) • ${s.role}',
                              style: const TextStyle(
                                  fontSize: 11.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Pilih Jam Tugas / Shift Operasional:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Opsi Pilihan Shift
                    _buildShiftRadioItem(
                      title: 'Shift Pagi',
                      time: '07:00 – 15:00 WIB',
                      value: 'Shift Pagi (07:00 – 15:00 WIB)',
                      groupValue: selectedShift,
                      onChanged: (val) =>
                          setSheetState(() => selectedShift = val!),
                    ),
                    _buildShiftRadioItem(
                      title: 'Shift Siang / Sore',
                      time: '15:00 – 23:00 WIB',
                      value: 'Shift Siang (15:00 – 23:00 WIB)',
                      groupValue: selectedShift,
                      onChanged: (val) =>
                          setSheetState(() => selectedShift = val!),
                    ),
                    _buildShiftRadioItem(
                      title: 'Shift Malam',
                      time: '23:00 – 07:00 WIB',
                      value: 'Shift Malam (23:00 – 07:00 WIB)',
                      groupValue: selectedShift,
                      onChanged: (val) =>
                          setSheetState(() => selectedShift = val!),
                    ),
                    _buildShiftRadioItem(
                      title: 'Normal Shift (Office Hours)',
                      time: '08:00 – 17:00 WIB',
                      value: 'Normal Shift (08:00 – 17:00 WIB)',
                      groupValue: selectedShift,
                      onChanged: (val) =>
                          setSheetState(() => selectedShift = val!),
                    ),

                    const SizedBox(height: 14),

                    // Status Keaktifan Bertugas (On-Duty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDuty
                                ? Icons.check_circle_rounded
                                : Icons.pause_circle_outline_rounded,
                            color: isDuty
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF64748B),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isDuty
                                      ? 'Status: Sedang Bertugas (On-Duty)'
                                      : 'Status: Sedang Libur / Istirahat (Off)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const Text(
                                  'Tampilkan indikator aktif di dashboard operasional',
                                  style: TextStyle(
                                      fontSize: 10, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isDuty,
                            activeThumbColor: const Color(0xFF00C2FF),
                            onChanged: (val) =>
                                setSheetState(() => isDuty = val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                final messenger =
                                    ScaffoldMessenger.of(context);
                                setSheetState(() => isSaving = true);
                                try {
                                  final serviceKey = SupabaseConfig
                                          .supabaseServiceRoleKey.isNotEmpty
                                      ? SupabaseConfig.supabaseServiceRoleKey
                                      : SupabaseConfig.activeApiKey;

                                  final uri = Uri.parse(
                                      '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableStafHotel}?id_staf=eq.${s.id}');
                                  final resp = await http.patch(
                                    uri,
                                    headers: {
                                      'apikey': serviceKey,
                                      'Authorization': 'Bearer $serviceKey',
                                      'Content-Type': 'application/json',
                                    },
                                    body: jsonEncode({
                                      'shift_tugas': selectedShift,
                                      'status_duty': isDuty ? 'On' : 'Off',
                                    }),
                                  );

                                  if (resp.statusCode != 200 &&
                                      resp.statusCode != 204) {
                                    throw Exception(
                                        'Gagal memperbarui shift: ${resp.body}');
                                  }

                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Shift tugas untuk ${s.name} berhasil diperbarui!'),
                                      backgroundColor: const Color(0xFF007A87),
                                    ),
                                  );
                                  widget.onRefresh?.call();
                                } catch (e) {
                                  setSheetState(() => isSaving = false);
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: const Color(0xFFEF4444),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007A87),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Simpan Perubahan Shift',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold)),
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

  Widget _buildShiftRadioItem({
    required String title,
    required String time,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFFF0FDFE) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00C2FF)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              size: 16,
              color: isSelected
                  ? const Color(0xFF007A87)
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                        fontSize: 10.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog Konfirmasi Hapus Akun Karyawan
  Future<void> _confirmDeleteStaff(StaffData s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFFDC2626), size: 26),
            SizedBox(width: 8),
            Text('Hapus Akun Karyawan?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 12.5, color: Color(0xFF475569), height: 1.4),
            children: [
              const TextSpan(text: 'Apakah Anda yakin ingin menghapus akun '),
              TextSpan(
                text: s.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              TextSpan(text: ' (${s.id}) dengan role '),
              TextSpan(
                text: s.role,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF007A87)),
              ),
              const TextSpan(
                  text:
                      '? Data karyawan dan hak akses login akan dihapus secara permanen.'),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus Akun',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
          ? SupabaseConfig.supabaseServiceRoleKey
          : SupabaseConfig.activeApiKey;

      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableStafHotel}?id_staf=eq.${s.id}');
      final resp = await http.delete(
        uri,
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
        },
      );

      if (resp.statusCode != 200 && resp.statusCode != 204) {
        throw Exception('Gagal menghapus dari database: ${resp.body}');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Akun karyawan ${s.name} berhasil dihapus!'),
          backgroundColor: const Color(0xFF007A87),
        ),
      );
      widget.onRefresh?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus karyawan: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}
