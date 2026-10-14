import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'saved_hotel_screen.dart';

/// Tab Pengaturan / Profil User
class PengaturanTab extends StatefulWidget {
  const PengaturanTab({super.key});

  @override
  State<PengaturanTab> createState() => _PengaturanTabState();
}

class _PengaturanTabState extends State<PengaturanTab> {
  bool _notifEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 12),
            _buildSaldoCard(),
            const SizedBox(height: 20),
            _buildSectionLabel('AKUN & KEAMANAN'),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profil Saya',
                subtitle: 'Ubah nama, nomor HP & tanggal lahir',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),
              _buildMenuItem(
                icon: Icons.people_outline,
                title: 'Data Tamu Tersimpan',
                subtitle: 'Isi cepat data penumpang & tamu hotel',
                badge: '3 Tamu',
                badgeColor: const Color(0xFF00B4D8),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),
              _buildMenuItem(
                icon: Icons.lock_outline,
                title: 'Keamanan Akun & Kata Sandi',
                subtitle: 'Ganti password & otentikasi 2 langkah',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionLabel('RESERVASI & TRANSAKSI'),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Riwayat Pesanan & E-Tiket Saya',
                subtitle: 'Akses tiket aktif, voucher hotel & invoice',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),
              _buildMenuItem(
                icon: Icons.favorite_outline,
                title: 'Penginapan Tersimpan',
                subtitle: 'Daftar villa & resort favorit Anda',
                badge: '5 Hotel',
                badgeColor: const Color(0xFF00B4D8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedHotelScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),
              _buildMenuItem(
                icon: Icons.local_offer_outlined,
                title: 'Voucher & Promo Saya',
                subtitle: 'Diskon eksklusif member Platinum',
                badge: '2 Baru',
                badgeColor: const Color(0xFFF59E0B),
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionLabel('PENGATURAN APLIKASI'),
            _buildMenuCard([
              _buildMenuItemSwitch(
                icon: Icons.notifications_outlined,
                title: 'Notifikasi Booking & Promo',
                subtitle: 'Pemberitahuan check-in & diskon kilat',
                value: _notifEnabled,
                onChanged: (val) => setState(() => _notifEnabled = val),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),
              _buildMenuItemValue(
                icon: Icons.translate,
                title: 'Pilihan Bahasa',
                subtitle: 'Bahasa tampilan sistem',
                value: 'Bahasa Indonesia',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionLabel('BANTUAN & KEBIJAKAN'),
            _buildMenuCard([
              _buildMenuItemDot(
                icon: Icons.headset_mic_outlined,
                title: 'Pusat Bantuan & CS 24/7',
                subtitle: 'Respon cepat via WhatsApp resmi',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),
              _buildMenuItem(
                icon: Icons.policy_outlined,
                title: 'Kebijakan Privasi & Ketentuan',
                subtitle: 'Syarat penggunaan Go Ticket',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),
            _buildLogoutButton(),
            const SizedBox(height: 12),
            _buildFooter(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundImage:
                        const NetworkImage('https://i.pravatar.cc/100?img=11'),
                    backgroundColor: Colors.grey[200],
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B4D8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit,
                          size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Aditya Pratama',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified,
                            color: Color(0xFF00B4D8), size: 18),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'aditya.pratama@email.com',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.workspace_premium,
                              color: Color(0xFF0096C7), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'MEMBER PLATINUM GO TICKET',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0096C7),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Badge verifikasi
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.verified_user,
                    color: Color(0xFF00B4D8), size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaldoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.stars,
                    color: Color(0xFF00B4D8), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Poin Reward',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF6B7280)),
                    ),
                    Text(
                      '1.250 Poin',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4D8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'Tukar Poin',
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9CA3AF),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF00B4D8), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor ?? const Color(0xFF00B4D8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00B4D8), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00B4D8),
            activeTrackColor: const Color(0xFF00B4D8).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemValue({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF00B4D8), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF00B4D8),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Color(0xFFD1D5DB)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemDot({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF00B4D8), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Keluar dari Akun',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Go Ticket v3.12.0  •  Keamanan Terverifikasi',
        style: GoogleFonts.inter(
          fontSize: 11,
          color: const Color(0xFFD1D5DB),
        ),
      ),
    );
  }
}
