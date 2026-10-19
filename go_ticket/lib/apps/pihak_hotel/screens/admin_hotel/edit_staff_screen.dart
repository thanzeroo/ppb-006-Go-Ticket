import 'package:flutter/material.dart';

class EditStaffScreen extends StatefulWidget {
  final String staffName;
  final String staffId;
  final String initialRole;

  const EditStaffScreen({
    super.key,
    this.staffName = 'Ni Made Anggreni, S.Tr.Par',
    this.staffId = '#STF-2024-004',
    this.initialRole = 'Front Office Lead',
  });

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  static const Color _teal = Color(0xFF007A87);
  static const Color _bg = Color(0xFFF6F8FB);
  static const Color _cardBorder = Color(0xFFE5E9F0);

  late TextEditingController _nameController;
  late TextEditingController _nikController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  final String _statusDuty = 'Aktif Bertugas (On-Duty)';
  String _selectedDept = 'Front Office Department';
  String _selectedJabatan = 'Front Office Lead / Senior';
  int _selectedShift = 0; // 0: Pagi, 1: Siang, 2: Malam

  // Permissions state (6 active, 2 locked)
  final Map<String, bool> _permissions = {
    'booking_approval': true,
    'checkin_keycard': true,
    'checkout_minibar': true,
    'room_grid': true,
    'complaint_wa': true,
    'refund_deposit': true,
    'escrow_payout': false,
    'edit_tariff': false,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Ni Made Anggreni');
    _nikController = TextEditingController(text: '5171015509980002');
    _emailController = TextEditingController(text: 'anggreni.fo@amoraresort.com');
    _phoneController = TextEditingController(text: '+62 813-3982-1140');
    _addressController = TextEditingController(text: 'Jl. Danau Tamblingan No. 24, Sanur, Denpasar');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  int get _activePermissionsCount => _permissions.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF007A87),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'GO',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Edit Data Karyawan',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF64748B), size: 20),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF007A87).withValues(alpha: 0.15),
              child: const Icon(Icons.person, size: 16, color: Color(0xFF007A87)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Top Profile Card
            _buildProfileSummaryCard(),

            const SizedBox(height: 16),
            // Card 1: Informasi Profil
            _buildProfileInfoCard(),

            const SizedBox(height: 16),
            // Card 2: Departemen & Penjadwalan
            _buildDeptScheduleCard(),

            const SizedBox(height: 16),
            // Card 3: Matriks Hak Akses
            _buildAccessMatrixCard(),

            const SizedBox(height: 16),
            // Card 4: Kredensial & Autentikasi
            _buildCredentialsCard(),

            const SizedBox(height: 16),
            // Card 5: Area Tindakan Kritis
            _buildCriticalActionsCard(),

            const SizedBox(height: 24),
            // Bottom Buttons
            _buildBottomButtons(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFCCFBF1),
                      border: Border.all(color: const Color(0xFF007A87), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, size: 36, color: Color(0xFF007A87)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.staffId,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('• Sejak 12 Jan 2024', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.staffName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.badge_outlined, size: 10, color: Color(0xFF007A87)),
                          const SizedBox(width: 4),
                          Text(widget.initialRole, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF007A87))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          // Status Kepegawaian & Tugas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status Kepegawaian & Tugas', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 7, color: Color(0xFF16A34A)),
                        const SizedBox(width: 4),
                        Text(_statusDuty, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                        const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.access_time, size: 11, color: Color(0xFF94A3B8)),
                    SizedBox(width: 4),
                    Text('Terakhir aktif: Hari ini 13:45 WITA di Terminal FO-1', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          // 3 Stat Metrics
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('CHECK-IN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                    SizedBox(height: 2),
                    Text('348', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    Text('Tamu bulan ini', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('RATING FO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                    SizedBox(height: 2),
                    Text('4.95 / 5', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    Text('⭐ 98 ulasan tamu', style: TextStyle(fontSize: 9, color: Color(0xFFD97706), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('AKURASI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                    SizedBox(height: 2),
                    Text('100%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),
                    Text('Selisih kas nol', style: TextStyle(fontSize: 9, color: Color(0xFF16A34A))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return _buildSectionContainer(
      icon: Icons.badge_outlined,
      title: 'Informasi Profil',
      subtitle: 'Data legalitas & jalur komunikasi staf',
      trailing: const Icon(Icons.lock_outline, size: 16, color: Color(0xFF94A3B8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Lengkap
          const Text('Nama Lengkap Sesuai Identitas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          _buildTextFormField(
            controller: _nameController,
            prefixIcon: Icons.badge_outlined,
          ),

          const SizedBox(height: 12),
          // NIK
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('NIK (KTP Bali)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('✔ Terverifikasi HRD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildTextFormField(
            controller: _nikController,
            prefixIcon: Icons.credit_card,
            suffixIcon: Icons.lock_outline,
            readOnly: true,
          ),

          const SizedBox(height: 12),
          // Email
          const Text('Email Resmi Akun Ops', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          _buildTextFormField(
            controller: _emailController,
            prefixIcon: Icons.mail_outline,
          ),

          const SizedBox(height: 12),
          // WA
          const Text('Nomor WhatsApp / HP Aktif', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          _buildTextFormField(
            controller: _phoneController,
            prefixIcon: Icons.phone_android,
          ),

          const SizedBox(height: 12),
          // Alamat
          const Text('Alamat Tinggal Sekarang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          _buildTextFormField(
            controller: _addressController,
            prefixIcon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildDeptScheduleCard() {
    return _buildSectionContainer(
      icon: Icons.calendar_month_outlined,
      title: 'Departemen & Penjadwalan',
      subtitle: 'Alokasi shift kerja & stasiun operasional',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Departemen Utama', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDept,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                items: [
                  'Front Office Department',
                  'Housekeeping Department',
                  'Engineering & Maintenance',
                  'Finance & Accounting',
                ].map((d) => DropdownMenuItem(value: d, child: Row(
                  children: [
                    const Icon(Icons.domain, size: 16, color: Color(0xFF007A87)),
                    const SizedBox(width: 8),
                    Text(d),
                  ],
                ))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDept = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('Jabatan / Level Tanggung Jawab', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedJabatan,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                items: [
                  'Front Office Lead / Senior',
                  'Front Desk Agent (Staff)',
                  'Duty Manager',
                  'Guest Service Officer',
                ].map((j) => DropdownMenuItem(value: j, child: Row(
                  children: [
                    const Icon(Icons.military_tech_outlined, size: 16, color: Color(0xFF007A87)),
                    const SizedBox(width: 8),
                    Text(j),
                  ],
                ))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedJabatan = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 14),
          const Text('Shift Kerja Aktif Minggu Ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 8),

          _buildShiftOption(
            index: 0,
            title: 'Shift Pagi (07.00 – 15.00 WITA)',
            badge: 'ON-DUTY',
            desc: 'Aktif beroperasi hari ini • Handover FO-Lead',
          ),
          const SizedBox(height: 8),
          _buildShiftOption(
            index: 1,
            title: 'Shift Siang (15.00 – 23.00 WITA)',
            desc: 'Peak arrival & dinner reservation',
          ),
          const SizedBox(height: 8),
          _buildShiftOption(
            index: 2,
            title: 'Shift Malam (23.00 – 07.00 WITA)',
            desc: 'Night audit & late check-in',
          ),

          const SizedBox(height: 14),
          const Text('Nomor Stasiun / Terminal Kasir POS FO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.desktop_windows_outlined, size: 16, color: Color(0xFF007A87)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Terminal FO 01 & Terminal FO 02', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 20),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('UBAH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF007A87))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftOption({
    required int index,
    required String title,
    String? badge,
    required String desc,
  }) {
    final isSel = _selectedShift == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedShift = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFF0FDFE) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSel ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: isSel ? const Color(0xFF007A87) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(badge, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessMatrixCard() {
    return _buildSectionContainer(
      icon: Icons.shield_outlined,
      title: 'Matriks Hak Akses',
      subtitle: 'Kewenangan modul & persetujuan transaksi',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F7FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$_activePermissionsCount/8 Aktif',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF007A87)),
        ),
      ),
      child: Column(
        children: [
          _buildAccessRow(
            keyName: 'booking_approval',
            icon: Icons.verified_user_outlined,
            title: 'Verifikasi Booking & Approval OTA',
            desc: 'Konfirmasi reservasi Traveloka, Agoda, Booking.com',
          ),
          const SizedBox(height: 8),
          _buildAccessRow(
            keyName: 'checkin_keycard',
            icon: Icons.vpn_key_outlined,
            title: 'Check-In, Room Assign & Keycard Encoder',
            desc: 'Assign nomor kamar fisik & generate RFID kunci kartu',
          ),
          const SizedBox(height: 8),
          _buildAccessRow(
            keyName: 'checkout_minibar',
            icon: Icons.receipt_long_outlined,
            title: 'Check-Out, Extra Bill & Denda Minibar',
            desc: 'Posting biaya tambahan & cetak invoice tamu',
          ),
          const SizedBox(height: 8),
          _buildAccessRow(
            keyName: 'room_grid',
            icon: Icons.grid_view_outlined,
            title: 'Pemantauan Status Kamar (Room Grid)',
            desc: 'Melihat visual live matriks kamar bersih/kotor HK',
          ),
          const SizedBox(height: 8),
          _buildAccessRow(
            keyName: 'complaint_wa',
            icon: Icons.chat_bubble_outline,
            title: 'Penanganan Komplain & Concierge WA',
            desc: 'Akses chat tiket bantuan tamu via Go Ticket gateway',
          ),
          const SizedBox(height: 8),
          _buildAccessRow(
            keyName: 'refund_deposit',
            icon: Icons.currency_exchange,
            title: 'Otorisasi Refund Deposit Tunai',
            desc: 'Maksimal limit otorisasi mandiri: Rp 500.000 / tamu',
          ),
          const SizedBox(height: 8),
          _buildAccessRow(
            keyName: 'escrow_payout',
            icon: Icons.account_balance_outlined,
            title: 'Rekonsiliasi Escrow & Payout Global',
            desc: 'Eksklusif otorisasi General Manager / Direksi Keuangan',
            isLocked: true,
          ),
          const SizedBox(height: 8),
          _buildAccessRow(
            keyName: 'edit_tariff',
            icon: Icons.edit_note,
            title: 'Edit Master Tarif Kamar & Dynamic Pricing',
            desc: 'Eksklusif otorisasi GM & Revenue Management System',
            isLocked: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAccessRow({
    required String keyName,
    required IconData icon,
    required String title,
    required String desc,
    bool isLocked = false,
  }) {
    final isChecked = _permissions[keyName] ?? false;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFFF0FDFE) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isChecked ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isChecked ? const Color(0xFF007A87) : const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isLocked ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    if (isLocked) ...[
                      const Icon(Icons.lock, size: 12, color: Color(0xFFD97706)),
                      const SizedBox(width: 4),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: isChecked,
            onChanged: isLocked
                ? null
                : (val) {
                    setState(() => _permissions[keyName] = val ?? false);
                  },
            activeColor: const Color(0xFF007A87),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsCard() {
    return _buildSectionContainer(
      icon: Icons.key_outlined,
      title: 'Kredensial & Autentikasi',
      subtitle: 'Keamanan login stasiun & sesi aktif',
      child: Column(
        children: [
          // 2FA Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_android, size: 20, color: Color(0xFF16A34A)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('2FA (Two-Factor Auth) Aktif', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                      Text('Terhubung Google Authenticator • Device Terverifikasi', style: TextStyle(fontSize: 9, color: Color(0xFF166534))),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, size: 18, color: Color(0xFF16A34A)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Send Reset Link
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link reset sandi telah dikirim ke email staf')),
              );
            },
            icon: const Icon(Icons.send_outlined, size: 14, color: Color(0xFF0284C7)),
            label: const Text('Kirim Link Reset Sandi ke Email Staf', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              backgroundColor: const Color(0xFFF0F9FF),
              side: const BorderSide(color: Color(0xFFBAE6FD)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 8),

          // Force Logout
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesi seluruh perangkat staf telah diputus')),
              );
            },
            icon: const Icon(Icons.logout, size: 14, color: Color(0xFFD97706)),
            label: const Text('Paksa Log Out dari Seluruh Perangkat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              backgroundColor: const Color(0xFFFFFBEB),
              side: const BorderSide(color: Color(0xFFFDE68A)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text('Area Tindakan Kritis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF991B1B))),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tindakan ini akan mencabut seluruh akses operasional staf ke sistem front office resort secara instan. Gunakan jika staf mengundurkan diri, mutasi, atau melanggar SOP berat.',
            style: TextStyle(fontSize: 10, color: Color(0xFF7F1D1D), height: 1.4),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Akun karyawan dinonaktifkan'), backgroundColor: Colors.red),
              );
            },
            icon: const Icon(Icons.person_remove, size: 16),
            label: const Text('Nonaktifkan Akun Karyawan Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              backgroundColor: const Color(0xFFB91C1C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Batal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perubahan data karyawan berhasil disimpan!'),
                  backgroundColor: Color(0xFF007A87),
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Simpan Perubahan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        filled: true,
        fillColor: readOnly ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
        prefixIcon: Icon(prefixIcon, size: 16, color: const Color(0xFF007A87)),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 16, color: const Color(0xFF94A3B8)) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      ),
    );
  }

  Widget _buildSectionContainer({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF007A87), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
