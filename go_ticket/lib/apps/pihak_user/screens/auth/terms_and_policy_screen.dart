import 'package:flutter/material.dart';

/// Halaman Syarat & Ketentuan (Terms & Policies) Go Ticket
class TermsAndPolicyScreen extends StatefulWidget {
  const TermsAndPolicyScreen({super.key});

  @override
  State<TermsAndPolicyScreen> createState() => _TermsAndPolicyScreenState();
}

class _TermsAndPolicyScreenState extends State<TermsAndPolicyScreen> {
  bool _agreed = true;

  void _handleAgree() {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap centang persetujuan syarat & ketentuan terlebih dahulu.'),
          backgroundColor: Color(0xFF0F172A),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Akun berhasil didaftarkan! Silakan masuk.'),
        backgroundColor: Color(0xFF00B4D8),
        duration: Duration(seconds: 2),
      ),
    );

    // Kembali ke login utama
    Navigator.of(context).pop(true);
  }

  void _handleReject() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(context),

            // Secondary Header: Syarat & Ketentuan + Hotel Policies badge
            _buildSubHeader(context),

            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  children: [
                    // Active Policy Notice Banner
                    _buildActivePolicyBanner(),
                    const SizedBox(height: 16),

                    // Card 1: Terms & Conditions (6 Butir)
                    _buildTermsCard(),
                    const SizedBox(height: 16),

                    // Card 2: Hotel Policies (7 Aturan)
                    _buildHotelPoliciesCard(),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  /// App Bar paling atas: Logo Go Ticket & User Circle
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFF00B4D8),
                  size: 26,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Go Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF0A5868),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Sub Header dengan tombol back, judul, dan badge "Hotel Policies"
  Widget _buildSubHeader(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFD),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF334155),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Syarat & Ketentuan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F4FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Hotel Policies',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0284C7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Banner status "Kebijakan Berlaku Aktif" | "Update Terakhir: 2025"
  Widget _buildActivePolicyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCEBFE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 18,
                color: Color(0xFF0284C7),
              ),
              SizedBox(width: 8),
              Text(
                'Kebijakan Berlaku Aktif',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Text(
            'Update Terakhir: 2025',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Card 1: Syarat dan Ketentuan Hotel (6 Butir)
  Widget _buildTermsCard() {
    final items = [
      (
        'Check-in dan Check-out: ',
        'Tamu wajib mengikuti waktu check-in dan check-out yang telah ditentukan oleh pihak hotel.'
      ),
      (
        'Pemesanan Kamar: ',
        'Setiap pemesanan harus menggunakan data tamu yang benar dan lengkap.'
      ),
      (
        'Pembayaran: ',
        'Tamu wajib menyelesaikan pembayaran sesuai dengan metode dan ketentuan yang berlaku.'
      ),
      (
        'Pembatalan Reservasi: ',
        'Pembatalan dan pengembalian dana mengikuti kebijakan pembatalan yang ditetapkan oleh pihak hotel.'
      ),
      (
        'Kerusakan Fasilitas: ',
        'Tamu bertanggung jawab atas kerusakan fasilitas hotel yang disebabkan oleh kelalaian atau tindakan tamu.'
      ),
      (
        'Persetujuan Ketentuan: ',
        'Dengan melakukan pemesanan, tamu dianggap telah membaca dan menyetujui syarat dan ketentuan hotel.'
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF0284C7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'TERMS & CONDITIONS',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0284C7),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Syarat dan Ketentuan Hotel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '6 Butir',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Items list
          for (int i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F4FB),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          height: 1.45,
                        ),
                        children: [
                          TextSpan(
                            text: items[i].$1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          TextSpan(text: items[i].$2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Card 2: Hotel Policies (7 Aturan)
  Widget _buildHotelPoliciesCard() {
    final policies = [
      (
        'Kebijakan Merokok: ',
        'Tamu hanya diperbolehkan merokok di area yang telah disediakan oleh pihak hotel.'
      ),
      (
        'Kebijakan Hewan Peliharaan: ',
        'Hewan peliharaan hanya diperbolehkan sesuai dengan kebijakan masing-masing hotel.'
      ),
      (
        'Kebijakan Anak-anak: ',
        'Tamu yang membawa anak-anak wajib mengikuti ketentuan kapasitas kamar dan fasilitas tambahan yang tersedia.'
      ),
      (
        'Penggunaan Fasilitas: ',
        'Seluruh fasilitas hotel harus digunakan sesuai dengan aturan dan jam operasional yang berlaku.'
      ),
      (
        'Keamanan dan Ketertiban: ',
        'Tamu wajib menjaga keamanan, kebersihan, dan ketertiban selama menginap.'
      ),
      (
        'Barang Hilang atau Rusak: ',
        'Tamu diharapkan segera melaporkan kehilangan atau kerusakan barang kepada petugas hotel.'
      ),
      (
        'Perubahan Kebijakan: ',
        'Pihak hotel berhak memperbarui kebijakan sesuai kebutuhan operasional dengan memberikan informasi kepada tamu.'
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Color(0xFF0284C7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'HOTEL POLICIES',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0284C7),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kebijakan Hotel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '7 Aturan',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Items list
          for (final policy in policies) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Color(0xFF00A8C6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          height: 1.45,
                        ),
                        children: [
                          TextSpan(
                            text: policy.$1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          TextSpan(text: policy.$2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Bottom sticky action bar dengan checkbox persetujuan dan tombol Tolak / Setuju
  Widget _buildBottomActionBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkbox agreement
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _agreed,
                  activeColor: const Color(0xFF00C2FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(color: Color(0xFF00C2FF), width: 1.6),
                  onChanged: (val) => setState(() => _agreed = val ?? false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: 'Saya telah membaca, memahami, dan menyetujui seluruh '),
                      TextSpan(
                        text: 'Syarat & Ketentuan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      TextSpan(text: ' serta '),
                      TextSpan(
                        text: 'Kebijakan Privasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      TextSpan(text: ' Go Ticket.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tombol Tolak & Setuju & Lanjutkan
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _handleReject,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Tolak',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _handleAgree,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C2FF),
                      elevation: 0,
                      shadowColor: const Color(0xFF00C2FF).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Setuju & Lanjutkan',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                      ],
                    ),
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
