import 'package:flutter/material.dart';

class AddRoomTypeScreen extends StatefulWidget {
  const AddRoomTypeScreen({super.key});

  @override
  State<AddRoomTypeScreen> createState() => _AddRoomTypeScreenState();
}

class _AddRoomTypeScreenState extends State<AddRoomTypeScreen> {
  static const Color _teal = Color(0xFF005E73);
  static const Color _bg = Color(0xFFF6F8FB);
  static const Color _cardBorder = Color(0xFFE5E9F0);

  int _selectedTab = 0; // 0: Info & Kapasitas, 1: Kuota & Tarif
  bool _extraBed = true;
  bool _surgePricing = true;
  int _cancellationPolicy = 0;

  late TextEditingController _nameController;
  late TextEditingController _weekdayPriceController;
  late TextEditingController _weekendPriceController;
  late TextEditingController _depositController;
  String _selectedCategory = 'Suite Mewah (Luxury Suite)';

  final List<String> _categories = [
    'Suite Mewah (Luxury Suite)',
    'Deluxe Room (Executive)',
    'Standard Twin Room',
    'Presidential Villa',
  ];

  final List<String> _facilities = [
    'Bathtub Ocean View',
    'Balkon Pribadi',
    'Smart TV 55" Netflix',
    'Mesin Kopi Espresso',
    'Walk-in Wardrobe',
    'Safe Deposit Box',
    'Minibar Gratis Harian',
    'WiFi 100Mbps',
  ];
  late Set<String> _selectedFacilities;

  final List<Map<String, dynamic>> _roomsFloor2 = [
    {'num': '#201'}, {'num': '#202'}, {'num': '#203'}, {'num': '#204'},
  ];
  final List<Map<String, dynamic>> _roomsFloor3 = [
    {'num': '#301'}, {'num': '#302'}, {'num': '#303'}, {'num': '#304'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Standar Twin Suite');
    _weekdayPriceController = TextEditingController(text: 'Rp 550.000');
    _weekendPriceController = TextEditingController(text: 'Rp 680.000');
    _depositController = TextEditingController(text: 'Rp 300.000');
    _selectedFacilities = Set.from(_facilities);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weekdayPriceController.dispose();
    _weekendPriceController.dispose();
    _depositController.dispose();
    super.dispose();
  }

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
            Image.asset(
              'assets/logo.png',
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
            const SizedBox(width: 8),
            const Text(
              'Tambah Kamar',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF475569)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Top Badges
            _buildTopBadges(),

            const SizedBox(height: 12),
            // Sub Tabs
            _buildTabSwitcher(),

            const SizedBox(height: 16),
            // Card 1: Informasi Dasar & Spesifikasi
            _buildBasicInfoCard(),

            const SizedBox(height: 16),
            // Card 2: Alokasi Kuota & Inventaris
            _buildQuotaInventoryCard(),

            const SizedBox(height: 16),
            // Card 3: Pengaturan Tarif & Dynamic Pricing
            _buildPricingCard(),

            const SizedBox(height: 16),
            // Card 4: Fasilitas Kamar
            _buildFacilitiesCard(),

            const SizedBox(height: 16),
            // Card 5: Galeri Foto Resolusi Tinggi
            _buildPhotoGalleryCard(),

            const SizedBox(height: 16),
            // Card 6: Kebijakan & Deposit
            _buildPolicyDepositCard(),

            const SizedBox(height: 24),
            // Bottom Action
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tipe kamar baru berhasil diterbitkan!'),
                    backgroundColor: Color(0xFF007A87),
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.publish, size: 18),
              label: const Text(
                'Terbitkan Tipe Kamar →',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF007A87),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFBAE6FD).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              Icon(Icons.circle, size: 6, color: Color(0xFF0284C7)),
              SizedBox(width: 6),
              Text(
                'Mode Setup Properti & Master Kamar',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0369A1)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              Icon(Icons.description_outlined, size: 12, color: Color(0xFF64748B)),
              SizedBox(width: 4),
              Text(
                'Draft #RMT-2025-04',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? _teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: _selectedTab == 0 ? Colors.white : const Color(0xFF475569)),
                    const SizedBox(width: 6),
                    Text(
                      '1. Info & Kapasitas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _selectedTab == 0 ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? _teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 14, color: _selectedTab == 1 ? Colors.white : const Color(0xFF475569)),
                    const SizedBox(width: 6),
                    Text(
                      '2. Kuota & Tarif',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _selectedTab == 1 ? Colors.white : const Color(0xFF475569),
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

  Widget _buildBasicInfoCard() {
    return _buildSectionContainer(
      icon: Icons.hotel,
      title: 'Informasi Dasar & Spesifikasi',
      subtitle: 'Atribut fisik dan klasifikasi kamar hotel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Tipe Kamar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Nama Tipe Kamar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              Text('*Wajib', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Icon(Icons.info_outline, size: 12, color: Color(0xFF007A87)),
              SizedBox(width: 4),
              Text('Nama yang akan ditampilkan di aplikasi tamu Go Ticket', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),

          const SizedBox(height: 14),
          const Text('Kategori Kamar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
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
                value: _selectedCategory,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 14),
          // 3 Column Specs
          Row(
            children: [
              Expanded(
                child: _buildSpecBox(icon: Icons.square_foot, title: 'Luas', value: '52 m²'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSpecBox(icon: Icons.bed, title: 'Ranjang', value: '1 Super King'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSpecBox(icon: Icons.bathtub, title: 'Mandi', value: '1 Bathtub'),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Kapasitas Tamu Maksimal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.group_outlined, size: 16, color: Color(0xFF007A87)),
                  SizedBox(width: 6),
                  Text('Kapasitas Maksimal\nTamu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Text('2 Dewasa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF007A87))),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Text('1 Anak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF007A87))),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          // Opsi Extra Bed
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Opsi Extra Bed (Kasur Tambahan)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                      Text('+ Rp 350.000 / malam', style: TextStyle(fontSize: 10, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Switch(
                  value: _extraBed,
                  onChanged: (val) => setState(() => _extraBed = val),
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF007A87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecBox({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCCFBF1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF007A87)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildQuotaInventoryCard() {
    return _buildSectionContainer(
      icon: Icons.layers_outlined,
      title: 'Alokasi Kuota & Inventaris',
      subtitle: 'Sinkronisasi nomor kamar dan OTA',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Dijual di Go Ticket', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
                          Icon(Icons.public, size: 14, color: Color(0xFF0284C7)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(text: '10 Unit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Kuota Online Terbuka', style: TextStyle(fontSize: 9, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Cadangan FO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                          Icon(Icons.lock_outline, size: 14, color: Color(0xFF475569)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(text: '2 Unit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Buffer Direct Booking', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Hubungkan Nomor Kamar Fisik', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
              Text('8 terpasang', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 8),

          _buildFloorRoomsPills('Lt. 2:', _roomsFloor2),
          const SizedBox(height: 6),
          _buildFloorRoomsPills('Lt. 3:', _roomsFloor3),

          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 14, color: Color(0xFF007A87)),
            label: const Text('Tambah No. Kamar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF007A87))),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(36),
              side: const BorderSide(color: Color(0xFFBAE6FD)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorRoomsPills(String floorTitle, List<Map<String, dynamic>> rooms) {
    return Row(
      children: [
        SizedBox(
          width: 45,
          child: Text(floorTitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: rooms.map((r) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(r['num'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCard() {
    return _buildSectionContainer(
      icon: Icons.monetization_on_outlined,
      title: 'Pengaturan Tarif & Dynamic Pricing',
      subtitle: 'Strategi pendapatan & AI yield manager',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tarif Dasar Weekday (Sen – Kam)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          TextFormField(
            controller: _weekdayPriceController,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              suffixText: '/malam',
              suffixStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),

          const SizedBox(height: 12),
          const Text('Tarif Weekend (Jum – Min)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          TextFormField(
            controller: _weekendPriceController,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              suffixText: '/malam',
              suffixStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Estimasi Komisi Go Ticket OTA (10%):', style: TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
                    Text('-Rp 145.000', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                  ],
                ),
                const Divider(height: 14, color: Color(0xFFE0F2FE)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.account_balance_wallet_outlined, size: 14, color: Color(0xFF007A87)),
                        SizedBox(width: 4),
                        Text('Penerimaan Bersih Hotel:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF007A87))),
                      ],
                    ),
                    const Text('Rp 1.305.000', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF007A87))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          // Smart Surge Pricing
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up, size: 18, color: Color(0xFF007A87)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Smart Surge Pricing Otomatis', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF007A87))),
                      Text('Ditenagai AI Demand Predictor', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                      Text('Naikkan harga +15% otomatis saat okupansi resort > 85%', style: TextStyle(fontSize: 9, color: Color(0xFF0369A1))),
                    ],
                  ),
                ),
                Switch(
                  value: _surgePricing,
                  onChanged: (val) => setState(() => _surgePricing = val),
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF007A87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesCard() {
    return _buildSectionContainer(
      icon: Icons.star_border,
      title: 'Fasilitas Kamar',
      subtitle: 'Pilih fasilitas utama tipe kamar ini',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F7FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('8 Terpilih', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF007A87))),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _facilities.map((fac) {
              final isSel = _selectedFacilities.contains(fac);
              return FilterChip(
                label: Text(fac),
                selected: isSel,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedFacilities.add(fac);
                    } else {
                      _selectedFacilities.remove(fac);
                    }
                  });
                },
                selectedColor: const Color(0xFFE0F7FA),
                checkmarkColor: const Color(0xFF007A87),
                backgroundColor: const Color(0xFFF1F5F9),
                labelStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSel ? const Color(0xFF007A87) : const Color(0xFF475569),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: isSel ? const Color(0xFF80DEEA) : Colors.transparent),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 14, color: Color(0xFF007A87)),
            label: const Text('Tambah Fasilitas Kustom', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF007A87))),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(36),
              side: const BorderSide(color: Color(0xFFBAE6FD)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGalleryCard() {
    return _buildSectionContainer(
      icon: Icons.photo_camera_back_outlined,
      title: 'Galeri Foto Resolusi Tinggi',
      subtitle: 'Upload minimal 3 foto kamar beresolusi tinggi',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE6FAFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00D1FF).withValues(alpha: 0.4)),
            ),
            child: Column(
              children: const [
                Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xFF005E73)),
                SizedBox(height: 6),
                Text('Tarik & Lepaskan foto kamar di sini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                SizedBox(height: 2),
                Text('Minimal 3 foto: sudut kamar tidur, kamar mandi, atau pemandangan teras', style: TextStyle(fontSize: 9, color: Color(0xFF64748B)), textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPhotoThumb(
                  'Cover',
                  Icons.bed,
                  'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&auto=format&fit=crop',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPhotoThumb(
                  'K. Mandi',
                  Icons.bathtub,
                  'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&auto=format&fit=crop',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPhotoThumb(
                  'Balkon',
                  Icons.deck,
                  'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=400&auto=format&fit=crop',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumb(String label, IconData icon, String imageUrl) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 32),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(label, style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 10, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyDepositCard() {
    return _buildSectionContainer(
      icon: Icons.shield_outlined,
      title: 'Kebijakan & Deposit',
      subtitle: 'Aturan pembatalan dan keamanan kamar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPolicyRadio(
            index: 0,
            title: 'Fleksibel: Bebas Pembatalan H-2',
            desc: 'Standard Amora - Tamu dapat refund penuh hingga 48 jam sebelum check-in',
          ),
          const SizedBox(height: 8),
          _buildPolicyRadio(
            index: 1,
            title: 'Non-Refundable: Diskon Khusus 10%',
            desc: 'Tanpa opsi refund atau perubahan tanggal setelah reservasi dibuat',
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Deposit Jaminan Kerusakan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
              Text('Rp 300.000', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Pre-auth kartu kredit / tunai FO',
            style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRadio({required int index, required String title, required String desc}) {
    final isSel = _cancellationPolicy == index;
    return GestureDetector(
      onTap: () => setState(() => _cancellationPolicy = index),
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
                  Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
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
