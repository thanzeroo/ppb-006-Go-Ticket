import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Form Tambah Promo (6 Sections)
/// Sesuai dengan desain visual pada Gambar 2 (Tambah Promo).
class TambahPromoScreen extends StatefulWidget {
  const TambahPromoScreen({super.key});

  @override
  State<TambahPromoScreen> createState() => _TambahPromoScreenState();
}

class _TambahPromoScreenState extends State<TambahPromoScreen> {
  // Section 1: Identitas & Kode Promo
  final _promoNameController = TextEditingController(
    text: 'Flash Sale Liburan Akhir Pekan (Weekend Getaway)',
  );
  final _promoCodeController = TextEditingController(text: 'AMORAHEBAT25');
  final _descController = TextEditingController(
    text:
        'Nikmati potongan harga eksklusif untuk staycation santai bersama keluarga di seluruh suite resort.',
  );

  // Section 2: Tipe & Skema Diskon
  int _discountType = 0; // 0 = Persentase, 1 = Nominal Flat, 2 = Gratis Ekstra
  final _discountValueController = TextEditingController(text: '25');
  final _maxDiscountController = TextEditingController(text: 'Rp 400.000');

  // Section 3: Masa Berlaku
  int _periodTab = 0; // 0 = Periode Booking, 1 = Periode Stay
  final _startDateController = TextEditingController(text: '28 Okt 2025');
  final _endDateController = TextEditingController(text: '10 Nov 2025');
  int _applicableDays = 0; // 0 = All Days, 1 = Weekday, 2 = Weekend

  // Section 4: Kuota & Batas Klaim
  final _totalQuotaController = TextEditingController(text: '150');
  final _limitPerAccountController = TextEditingController(text: '1x Klaim');
  final _minTxController = TextEditingController(text: 'Rp 800.000');
  final _minStayController = TextEditingController(text: 'Min. 2 Malam');

  // Section 5: Cakupan Kamar
  int _roomCoverage = 1; // 0 = Semua Kamar, 1 = Kamar Tertentu

  // Section 6: Visibilitas & Pendanaan
  bool _publicDiscovery = true;
  bool _secretCode = false;
  int _coFunding = 0; // 0 = 100% Hotel, 1 = 50:50

  @override
  void dispose() {
    _promoNameController.dispose();
    _promoCodeController.dispose();
    _descController.dispose();
    _discountValueController.dispose();
    _maxDiscountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _totalQuotaController.dispose();
    _limitPerAccountController.dispose();
    _minTxController.dispose();
    _minStayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopAppBar(),

            // Form Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Title & Stepper Header
                  _buildHeaderTitleAndSteps(),
                  const SizedBox(height: 16),

                  // Section 1: Identitas & Kode Promo
                  _buildSection1(),
                  const SizedBox(height: 16),

                  // Section 2: Tipe & Skema Diskon
                  _buildSection2(),
                  const SizedBox(height: 16),

                  // Section 3: Masa Berlaku & Periode
                  _buildSection3(),
                  const SizedBox(height: 16),

                  // Section 4: Kuota & Batas Klaim
                  _buildSection4(),
                  const SizedBox(height: 16),

                  // Section 5: Cakupan Tipe Kamar
                  _buildSection5(),
                  const SizedBox(height: 16),

                  // Section 6: Visibilitas & Pendanaan
                  _buildSection6(),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top App Bar
  // ---------------------------------------------------------------------------
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.confirmation_number_rounded,
                    color: Color(0xFF00B4D8),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Tambah Promo',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'The Grand Amora Resort & Spa',
                    style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Draft promo berhasil disimpan!')),
                  );
                },
                icon: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                label: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C2FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 0,
                  minimumSize: Size.zero,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF006678),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header Title & Steps Indicator
  // ---------------------------------------------------------------------------
  Widget _buildHeaderTitleAndSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00B4D8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'FORM PROMO & DISKON HOTEL',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF007A94),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Draft #VCH-2025-08',
              style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Buat Kampanye Promo',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'The Grand Amora Resort & Spa • Promo Engine Yield v2.4',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),

        // 3 Step Tabs
        Row(
          children: [
            _buildStepTab(label: '1. Detail & Kupon', isActive: true),
            const SizedBox(width: 8),
            _buildStepTab(label: '2. Nilai Diskon', isActive: false),
            const SizedBox(width: 8),
            _buildStepTab(label: '3. Syarat & Kamar', isActive: false),
          ],
        ),
      ],
    );
  }

  Widget _buildStepTab({required String label, required bool isActive}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF00C2FF) : const Color(0xFFE2E8F0),
              width: 2,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 1: Identitas & Kode Promo
  // ---------------------------------------------------------------------------
  Widget _buildSection1() {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bookmark_outline_rounded,
                    size: 18, color: Color(0xFF0096B4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '1. Identitas & Kode Promo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Penamaan publik dan kode kupon tamu',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Nama Kampanye Promo
          const Text(
            'Nama Kampanye Promo *',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          _buildInputBox(controller: _promoNameController),
          const SizedBox(height: 12),

          // Kode Promo / Kupon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Kode Promo / Kupon *',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              Text(
                'Maks. 16 Karakter',
                style: TextStyle(fontSize: 9.5, color: Color(0xFF007A94)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _promoCodeController.text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _promoCodeController.text = 'AMORA${(10 + (DateTime.now().millisecond % 90))}PROMO';
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFFAFE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.casino_outlined, size: 14, color: Color(0xFF0891B2)),
                      SizedBox(width: 4),
                      Text(
                        'Acak',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0891B2)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF64748B)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _promoCodeController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kode kupon berhasil disalin!')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Deskripsi Singkat untuk Tamu
          const Text(
            'Deskripsi Singkat untuk Tamu',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _descController,
              maxLines: 2,
              style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '104 / 200 karakter',
              style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 2: Tipe & Skema Diskon
  // ---------------------------------------------------------------------------
  Widget _buildSection2() {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.percent_rounded, size: 18, color: Color(0xFF0096B4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '2. Tipe & Skema Diskon',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Metode potongan dan simulasi live harga',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Discount Type Cards
          Row(
            children: [
              Expanded(
                child: _buildDiscountTypeCard(
                  icon: Icons.percent_rounded,
                  title: 'Persentase',
                  sub: '(%) Potongan',
                  isSelected: _discountType == 0,
                  onTap: () => setState(() => _discountType = 0),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildDiscountTypeCard(
                  icon: Icons.payments_outlined,
                  title: 'Nominal Flat',
                  sub: '(Rp) Tetap',
                  isSelected: _discountType == 1,
                  onTap: () => setState(() => _discountType = 1),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildDiscountTypeCard(
                  icon: Icons.card_giftcard_rounded,
                  title: 'Gratis Ekstra',
                  sub: 'Add-on Item',
                  isSelected: _discountType == 2,
                  onTap: () => setState(() => _discountType = 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2 fields: Besaran Diskon & Maks. Plafon Diskon
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Besaran Diskon (%) *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    _buildInputBox(controller: _discountValueController, suffixText: '%'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Maks. Plafon Diskon', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    _buildInputBox(controller: _maxDiscountController),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // SIMULASI NILAI RIIL Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.calculate_outlined, size: 15, color: Color(0xFF2563EB)),
                        SizedBox(width: 6),
                        Text(
                          'SIMULASI NILAI RIIL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E40AF),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Tipe: Grand Deluxe',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Harga Dasar per Malam:', style: TextStyle(fontSize: 10.5, color: Color(0xFF475569))),
                    Text('Rp 1.450.000', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Diskon 25% (Hemat):', style: TextStyle(fontSize: 10.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                    Text('-Rp 362.500', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
                  ],
                ),
                const SizedBox(height: 6),
                const Divider(height: 1, color: Color(0xFFBFDBFE)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Total Pembayaran Tamu:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    Text('Rp 1.087.500', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF00758F))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFF64748B)),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Platform fee & revenue sharing hotel dihitung dari nilai bersih transaksi setelah potongan promo diterapkan.',
                        style: TextStyle(fontSize: 9, color: Color(0xFF64748B), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountTypeCard({
    required IconData icon,
    required String title,
    required String sub,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F7FA) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF00B4D8) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: isSelected ? const Color(0xFF007A94) : const Color(0xFF64748B)),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF007A94) : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              sub,
              style: TextStyle(
                fontSize: 8.5,
                color: isSelected ? const Color(0xFF007A94) : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 3: Masa Berlaku & Periode
  // ---------------------------------------------------------------------------
  Widget _buildSection3() {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF0096B4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '3. Masa Berlaku & Periode',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Jadwal reservasi dan batas check-in',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Period Switcher Toggle
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _periodTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _periodTab == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _periodTab == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Periode Booking',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: _periodTab == 0 ? FontWeight.w800 : FontWeight.w600,
                          color: _periodTab == 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _periodTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _periodTab == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Periode Stay / Menginap',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: _periodTab == 1 ? FontWeight.w800 : FontWeight.w600,
                          color: _periodTab == 1 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2 Date Fields: Mulai Promo & Berakhir Promo
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mulai Promo', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildInputBox(
                      controller: _startDateController,
                      suffixIcon: Icons.calendar_today_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Berakhir Promo', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildInputBox(
                      controller: _endDateController,
                      suffixIcon: Icons.calendar_today_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Ketentuan Hari Berlaku
          const Text(
            'Ketentuan Hari Berlaku',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),

          _buildApplicableDayOption(
            index: 0,
            title: 'Berlaku Setiap Hari (All Days)',
            sub: 'Dapat dipakai reservasi Weekday maupun Weekend',
          ),
          const SizedBox(height: 6),
          _buildApplicableDayOption(
            index: 1,
            title: 'Hanya Weekday (Senin - Kamis)',
            sub: 'Meningkatkan okupansi low-traffic weekday',
          ),
          const SizedBox(height: 6),
          _buildApplicableDayOption(
            index: 2,
            title: 'Eksklusif Weekend (Jumat - Minggu)',
            sub: 'Khusus reservasi paket akhir pekan',
          ),
        ],
      ),
    );
  }

  Widget _buildApplicableDayOption({
    required int index,
    required String title,
    required String sub,
  }) {
    final isSelected = _applicableDays == index;
    return InkWell(
      onTap: () => setState(() => _applicableDays = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              size: 16,
              color: isSelected ? const Color(0xFF007A94) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 4: Kuota & Batas Klaim
  // ---------------------------------------------------------------------------
  Widget _buildSection4() {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF0096B4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '4. Kuota & Batas Klaim',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Kontrol alokasi voucher platform',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 1: Total Kuota & Batas per Akun
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Total Kuota', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        Text('Uncapped', style: TextStyle(fontSize: 9.5, color: Color(0xFF007A94))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildInputBox(controller: _totalQuotaController, suffixText: 'Kupon'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Batas per Akun', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildInputBox(controller: _limitPerAccountController),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Min. Transaksi & Min. Menginap
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Min. Transaksi', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildInputBox(controller: _minTxController),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Min. Menginap', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildInputBox(
                      controller: _minStayController,
                      suffixIcon: Icons.keyboard_arrow_down_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 5: Cakupan Tipe Kamar
  // ---------------------------------------------------------------------------
  Widget _buildSection5() {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.hotel_rounded, size: 18, color: Color(0xFF0096B4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '5. Cakupan Tipe Kamar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Tentukan suite yang berhak menerima promo',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Radio 1: Berlaku untuk Semua Tipe Kamar
          InkWell(
            onTap: () => setState(() => _roomCoverage = 0),
            child: Row(
              children: [
                Icon(
                  _roomCoverage == 0 ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 16,
                  color: _roomCoverage == 0 ? const Color(0xFF007A94) : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Berlaku untuk Semua Tipe Kamar',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Radio 2: Hanya Tipe Kamar Tertentu
          InkWell(
            onTap: () => setState(() => _roomCoverage = 1),
            child: Row(
              children: [
                Icon(
                  _roomCoverage == 1 ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 16,
                  color: _roomCoverage == 1 ? const Color(0xFF007A94) : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Hanya Tipe Kamar Tertentu (Kustomisasi)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Selected Room Chips
          const Text(
            'KAMAR TERPILIH (3 UNIT)',
            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildRoomChip('Executive Ocean Panorama', isChecked: true),
              _buildRoomChip('Grand Deluxe Pool View', isChecked: true),
              _buildRoomChip('Royal Garden Villa', isChecked: true),
              _buildAddRoomChip('Standard Superior Room'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomChip(String label, {required bool isChecked}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFCFFAFE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF67E8F9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF0891B2)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0891B2)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRoomChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_rounded, size: 13, color: Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 6: Visibilitas & Pendanaan
  // ---------------------------------------------------------------------------
  Widget _buildSection6() {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF0096B4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '6. Visibilitas & Pendanaan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Katalog publik dan subsidi beban biaya',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Switch 1: Tayang Publik
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tayang Publik di Go Ticket Discovery',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      'Tampil di banner home app & katalog voucher tamu',
                      style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _publicDiscovery,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF00C2FF),
                onChanged: (val) => setState(() => _publicDiscovery = val),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Switch 2: Kode Rahasia
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Kode Rahasia (Direct Concierge Only)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      'Sembunyikan dari listing publik, hanya input manual',
                      style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _secretCode,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF00C2FF),
                onChanged: (val) => setState(() => _secretCode = val),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Beban Subsidi Diskon
          const Text(
            'Beban Subsidi Diskon (Co-Funding):',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),

          // Co-funding Option 1
          InkWell(
            onTap: () => setState(() => _coFunding = 0),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _coFunding == 0 ? const Color(0xFFF0FDF4) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _coFunding == 0 ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _coFunding == 0 ? Icons.radio_button_checked : Icons.radio_button_off,
                    size: 16,
                    color: _coFunding == 0 ? const Color(0xFF007A94) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '100% Ditanggung Hotel (Internal Marketing)',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'Alokasi penuh dari budget sales & marketing The Grand Amora',
                          style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Co-funding Option 2
          InkWell(
            onTap: () => setState(() => _coFunding = 1),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _coFunding == 1 ? const Color(0xFFF0FDF4) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _coFunding == 1 ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _coFunding == 1 ? Icons.radio_button_checked : Icons.radio_button_off,
                    size: 16,
                    color: _coFunding == 1 ? const Color(0xFF007A94) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Co-Sharing 50:50 dengan Promo Nasional Go Ticket',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'Memerlukan persetujuan verifikasi regional HQ (1x24 jam)',
                          style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Action Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Voucher Promo berhasil diterbitkan dan aktif di platform!'),
                backgroundColor: Color(0xFF00758F),
              ),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00758F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Terbitkan Promo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    String? hint,
    IconData? suffixIcon,
    String? suffixText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, size: 16, color: const Color(0xFF64748B))
              : (suffixText != null
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        suffixText,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    )
                  : null),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }
}
