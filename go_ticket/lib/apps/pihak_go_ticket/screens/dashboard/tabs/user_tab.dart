import 'package:flutter/material.dart';

/// Tab 4: Direktori Pengguna & Staf (Image 3)
class UserTab extends StatefulWidget {
  const UserTab({super.key});

  @override
  State<UserTab> createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
  int _selectedDirectoryTab = 0; // 0 = Data Tamu / User, 1 = Staf & Petugas
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'Semua (1.438)',
    'Aktif',
    'Tersuspend / Banned',
    'VIP Platinum',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 1. Title & Super Admin Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Direktori Pengguna &\nStaf',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kelola izin akses, akun tamu, serta penugasan staf operasional',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFCFFAFE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Super\nAdmin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0891B2),
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2. Segmented Tabs Switch: Data Tamu / User (1.420) vs Staf & Petugas (18)
        _buildDirectorySegmentedControl(),
        const SizedBox(height: 14),

        // 3. Search & Filter Bar
        _buildSearchAndFilters(),
        const SizedBox(height: 16),

        // 4. Header: DAFTAR PELANGGAN & TAMU
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'DAFTAR PELANGGAN & TAMU',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'URUTKAN: TERBARU',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 5. Customer Items
        _buildCustomerItem(
          initials: 'AP',
          initialsBg: const Color(0xFF00C2FF),
          name: 'Aditya Pratama',
          tierBadge: 'PLATINUM',
          tierBg: const Color(0xFFCFFAFE),
          tierFg: const Color(0xFF0891B2),
          hasGreenDot: true,
          emailPhone: 'aditya.pratama@email.com • 08...',
          stats: '8x Booking • Rp 14.800.000',
          status: 'Aktif',
          statusBg: const Color(0xFFEFF6FF),
          statusFg: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 10),

        _buildCustomerItem(
          initials: 'DA',
          initialsBg: const Color(0xFF93C5FD),
          name: 'Dimas Anggara',
          tierBadge: 'REGULER',
          tierBg: const Color(0xFFF1F5F9),
          tierFg: const Color(0xFF475569),
          emailPhone: 'dimas.ang@email.com • 0812-9988-1234',
          stats: '2x Booking • Rp 1.700.000',
          status: 'Aktif',
          statusBg: const Color(0xFFEFF6FF),
          statusFg: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 10),

        _buildCustomerItem(
          initials: 'MA',
          initialsBg: const Color(0xFF5EEAD4),
          name: 'Maya Anggraini',
          tierBadge: 'GOLD',
          tierBg: const Color(0xFFFEF3C7),
          tierFg: const Color(0xFFD97706),
          emailPhone: 'maya.ang@email.com • 0813-7744-8899',
          stats: '5x Booking • Rp 7.250.000',
          status: 'Aktif',
          statusBg: const Color(0xFFEFF6FF),
          statusFg: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 10),

        // Suspicious / Banned User item
        _buildSuspiciousUserItem(),
        const SizedBox(height: 10),

        _buildCustomerItem(
          initials: 'NP',
          initialsBg: const Color(0xFFCBD5E1),
          name: 'Nadia Pramestuti',
          tierBadge: 'REGULER',
          tierBg: const Color(0xFFF1F5F9),
          tierFg: const Color(0xFF475569),
          emailPhone: 'nadia.p@email.com • 0857-1122-3344',
          stats: '3x Booking • Rp 3.400.000',
          status: 'Aktif',
          statusBg: const Color(0xFFEFF6FF),
          statusFg: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 10),

        _buildCustomerItem(
          initials: 'RD',
          initialsBg: const Color(0xFFBAE6FD),
          name: 'Rendra Darmawan',
          tierBadge: 'SILVER',
          tierBg: const Color(0xFFE2E8F0),
          tierFg: const Color(0xFF334155),
          emailPhone: 'rendra.d@email.com • 0818-4455-6677',
          stats: '4x Booking • Rp 5.100.000',
          status: 'Aktif',
          statusBg: const Color(0xFFEFF6FF),
          statusFg: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 20),

        // 6. Section: Staf & Tim Bertugas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Icon(Icons.badge_outlined, size: 18, color: Color(0xFF007A94)),
                SizedBox(width: 6),
                Text(
                  'Staf & Tim Bertugas',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Text(
              '12 Staf Online',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0284C7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Staff Items
        _buildStaffItem(
          initials: 'BS',
          name: 'Bambang Sutejo',
          nik: 'NIK: 3201-9981',
          role: 'Front Office Manager',
          shift: 'Shift Pagi (07:00 - 15:00)',
          statusLabel: 'Bertugas',
          isDuty: true,
        ),
        const SizedBox(height: 10),

        _buildStaffItem(
          initials: 'SN',
          name: 'Siti Nurhaliza',
          nik: 'NIK: 3201-9944',
          role: 'Resepsionis',
          shift: 'Shift Sore (15:00 - 23:00)',
          statusLabel: 'Standby',
          isDuty: false,
        ),
        const SizedBox(height: 10),

        _buildStaffItem(
          initials: 'AR',
          name: 'Asep Ridwan',
          nik: 'NIK: 3201-8812',
          role: 'Housekeeping Lead',
          shift: 'Shift Pagi (06:00 - 14:00)',
          statusLabel: 'Bertugas',
          isDuty: true,
        ),
        const SizedBox(height: 18),

        // 7. Bottom Card: Ekspor Data Audit
        _buildExportAuditCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Segmented Control: Data Tamu vs Staf & Petugas
  // ---------------------------------------------------------------------------
  Widget _buildDirectorySegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Option 1: Data Tamu / User (1.420)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDirectoryTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: _selectedDirectoryTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedDirectoryTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 16,
                      color: _selectedDirectoryTab == 0
                          ? const Color(0xFF007A94)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Data Tamu / User',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: _selectedDirectoryTab == 0 ? FontWeight.w800 : FontWeight.w600,
                        color: _selectedDirectoryTab == 0 ? const Color(0xFF007A94) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '1.420',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Option 2: Staf & Petugas (18)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDirectoryTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: _selectedDirectoryTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedDirectoryTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 16,
                      color: _selectedDirectoryTab == 1
                          ? const Color(0xFF007A94)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Staf & Petugas',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: _selectedDirectoryTab == 1 ? FontWeight.w800 : FontWeight.w600,
                        color: _selectedDirectoryTab == 1 ? const Color(0xFF007A94) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '18',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search & Filter Bar
  // ---------------------------------------------------------------------------
  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: const [
              Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari nama, email, NIK, atau no HP...',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                ),
              ),
              Icon(Icons.tune_rounded, size: 18, color: Color(0xFF64748B)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_filters.length, (index) {
              final isSelected = _selectedFilterIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedFilterIndex = index),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE0F2FE) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF7DD3FC)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      _filters[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Normal Customer Item
  // ---------------------------------------------------------------------------
  Widget _buildCustomerItem({
    required String initials,
    required Color initialsBg,
    required String name,
    required String tierBadge,
    required Color tierBg,
    required Color tierFg,
    bool hasGreenDot = false,
    required String emailPhone,
    required String stats,
    required String status,
    required Color statusBg,
    required Color statusFg,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: initialsBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tierBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tierBadge,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: tierFg,
                        ),
                      ),
                    ),
                    if (hasGreenDot) ...[
                      const SizedBox(width: 5),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  emailPhone,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  stats,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
          ),

          // Status & More
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusFg,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Suspicious User Item (with Detail Fraud & Buka Blokir buttons)
  // ---------------------------------------------------------------------------
  Widget _buildSuspiciousUserItem() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFB91C1C),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'UF',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'User Suspicious #10492',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PELANGGARAN',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'user.fake091@temp.com • 0x Sukses (3x Fra...)',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF991B1B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Banned',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Two Action Buttons: Detail Fraud & Buka Blokir
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text(
                    'Detail Fraud',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C2FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text(
                    'Buka Blokir',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Staff Item
  // ---------------------------------------------------------------------------
  Widget _buildStaffItem({
    required String initials,
    required String name,
    required String nik,
    required String role,
    required String shift,
    required String statusLabel,
    required bool isDuty,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFF67E8F9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0E7490),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        nik,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                    children: [
                      TextSpan(
                        text: role,
                        style: const TextStyle(
                          color: Color(0xFF0284C7),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: ' • '),
                      TextSpan(text: shift),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDuty ? const Color(0xFFCFFAFE) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDuty) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0891B2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDuty ? const Color(0xFF0891B2) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Ekspor Data Audit Card
  // ---------------------------------------------------------------------------
  Widget _buildExportAuditCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.download_rounded, color: Color(0xFF0096B4), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Ekspor Data Audit',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Format CSV / Excel terenkripsi',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mengunduh berkas data audit pengguna & staf...')),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            child: const Text(
              'Unduh File',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF007A94),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
