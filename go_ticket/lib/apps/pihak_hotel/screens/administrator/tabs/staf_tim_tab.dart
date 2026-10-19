import 'package:flutter/material.dart';

import '../../../../../core/theme/hotel_admin_theme.dart';
import '../../../../../models/hotel_admin_model.dart';
import 'add_staff_screen.dart';
import 'edit_staff_screen.dart';

/// Tab 3: Manajemen Staf & Hak Akses Administrator
class StafTimTab extends StatefulWidget {
  final List<StaffData> staff;

  const StafTimTab({super.key, required this.staff});

  @override
  State<StafTimTab> createState() => _StafTimTabState();
}

class _StafTimTabState extends State<StafTimTab> {
  int _deptIndex = 0;
  final _depts = ['Semua (18)', 'Front Office (6)', 'Housekeeping (8)'];

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddStaffScreen()),
            );
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 8),

        // Ekspor Jadwal Shift
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_outlined, size: 14),
          label: const Text('Ekspor Jadwal Shift (PDF/Excel)'),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFF1F5F9),
            foregroundColor: const Color(0xFF334155),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            minimumSize: const Size.fromHeight(42),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),

        const SizedBox(height: 16),
        // Status Roster Hari Ini
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.calendar_month_outlined, size: 14, color: Color(0xFF0F172A)),
                SizedBox(width: 6),
                Text('Status Roster Hari Ini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: cLight, borderRadius: BorderRadius.circular(10)),
              child: const Text('Live Sync', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: cDarkActive)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 2 Shift Status Cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: adminCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('07:00 – 15:00', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                        Spacer(),
                        Icon(Icons.circle, size: 6, color: cNormal),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text('6 Karyawan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const Text('Shift Pagi (Active Now)', style: TextStyle(fontSize: 9, color: cDarkActive, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: adminCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('15:00 – 23:00', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                        Spacer(),
                        Icon(Icons.access_time, size: 10, color: Color(0xFF94A3B8)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text('5 Karyawan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const Text('Shift Siang (Terjadwal)', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),
        // Department Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_depts.length, (i) {
              final sel = _deptIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _deptIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? cDarkActive : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? cDarkActive : adminCardBorder),
                  ),
                  child: Text(
                    _depts[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),
        // Staff List
        ...widget.staff.map((s) => _buildStaffCard(s)),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStaffCard(StaffData s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: adminCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // AVATAR PHOTO
              Stack(
                children: [
                  ClipOval(
                    child: buildNetworkImage(
                      s.avatarUrl,
                      width: 44,
                      height: 44,
                      placeholder: CircleAvatar(
                        radius: 22,
                        backgroundColor: cLight,
                        child: Text(
                          s.name[0],
                          style: const TextStyle(fontWeight: FontWeight.w800, color: cDarkActive),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.onlineDotColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          s.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                          child: Text(s.id, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(s.role, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: s.statusBg, borderRadius: BorderRadius.circular(10)),
                child: Text(s.statusLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: s.statusFg)),
              ),
            ],
          ),

          const SizedBox(height: 10),
          // Otorisasi Box
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
                const Text('OTORISASI & HAK AKSES:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: s.akses.map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: adminCardBorder),
                      ),
                      child: Text('✔ $a', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 12, color: Color(0xFF22C55E)),
              const SizedBox(width: 4),
              Text('WhatsApp: ${s.wa}', style: const TextStyle(fontSize: 10, color: Color(0xFF475569))),
            ],
          ),

          const SizedBox(height: 10),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditStaffScreen(
                          staffName: s.name,
                          staffId: s.id,
                          initialRole: s.role,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 12),
                  label: const Text('Atur Shift'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditStaffScreen(
                          staffName: s.name,
                          staffId: s.id,
                          initialRole: s.role,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shield_outlined, size: 12),
                  label: const Text('Kelola Akses'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: cLight,
                    foregroundColor: cDarkActive,
                    side: const BorderSide(color: cLightActive),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
