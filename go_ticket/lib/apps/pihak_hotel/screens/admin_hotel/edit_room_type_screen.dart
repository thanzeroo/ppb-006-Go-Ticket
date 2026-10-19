import 'package:flutter/material.dart';

class EditRoomTypeScreen extends StatefulWidget {
  final String roomName;
  final String category;

  const EditRoomTypeScreen({
    super.key,
    this.roomName = 'Standar Twin Suite',
    this.category = 'Suite Mewah (Luxury Suite)',
  });

  @override
  State<EditRoomTypeScreen> createState() => _EditRoomTypeScreenState();
}

class _EditRoomTypeScreenState extends State<EditRoomTypeScreen> {
  static const Color _teal = Color(0xFF007A87);
  static const Color _bg = Color(0xFFF6F8FB);
  static const Color _cardBorder = Color(0xFFE5E9F0);

  int _selectedTab = 0; // 0: Spesifikasi & Kapasitas, 1: Tarif & Kuota
  bool _isLive = true;
  bool _extraBed = true;
  bool _surgePricing = true;
  int _cancellationPolicy = 0; // 0: Fleksibel H-2, 1: Non-Refundable

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
    'WiFi 100 Mbps',
  ];
  late Set<String> _selectedFacilities;

  final List<Map<String, dynamic>> _roomsFloor2 = [
    {'num': '#201', 'active': true},
    {'num': '#202', 'active': true},
    {'num': '#203', 'active': true},
    {'num': '#204', 'active': true},
  ];

  final List<Map<String, dynamic>> _roomsFloor3 = [
    {'num': '#301', 'active': true},
    {'num': '#302', 'active': true},
    {'num': '#303', 'active': true},
    {'num': '#304', 'active': true},
  ];

  final List<Map<String, dynamic>> _roomsFloor4 = [
    {'num': '#401', 'active': true},
    {'num': '#402', 'active': true},
    {'num': '#403', 'active': true},
    {'num': '#404', 'active': true},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.roomName);
    _weekdayPriceController = TextEditingController(text: 'Rp 1.450.000');
    _weekendPriceController = TextEditingController(text: 'Rp 1.750.000');
    _depositController = TextEditingController(text: 'Rp 300.000');
    _selectedCategory = widget.category;
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
        title: const Text(
          'Edit Tipe Kamar',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF475569)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu opsi lainnya')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Banner
            _buildUpdateBanner(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Aktif Live Card
                  _buildLiveStatusCard(),

                  const SizedBox(height: 16),
                  // Sub-tab switcher
                  _buildTabSwitcher(),

                  const SizedBox(height: 16),
                  // Section 1: Informasi Dasar & Spesifikasi Fisik
                  _buildBasicInfoSection(),

                  const SizedBox(height: 16),
                  // Section 2: Alokasi Kuota & Inventaris
                  _buildQuotaInventorySection(),

                  const SizedBox(height: 16),
                  // Section 3: Tarif & Dynamic Pricing
                  _buildPricingSection(),

                  const SizedBox(height: 16),
                  // Section 4: Fasilitas Kamar Unggulan
                  _buildFacilitiesSection(),

                  const SizedBox(height: 16),
                  // Section 5: Galeri Foto Resolusi Tinggi
                  _buildPhotoGallerySection(),

                  const SizedBox(height: 16),
                  // Section 6: Kebijakan Pembatalan & Deposit
                  _buildCancellationPolicySection(),

                  const SizedBox(height: 24),
                  // Bottom Actions
                  _buildBottomActions(),

                  const SizedBox(height: 12),
                  // Archive / Deactivate link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tipe kamar berhasil diarsipkan'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: const Text(
                        'Arsipkan atau Nonaktifkan Tipe Kamar ini',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFE0F7FA).withValues(alpha: 0.6),
      child: Row(
        children: [
          const Icon(Icons.sync, size: 16, color: Color(0xFF007A87)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 11, color: Color(0xFF334155)),
                children: [
                  TextSpan(text: 'Terakhir diperbarui: Kemarin 14:15 WIB • '),
                  TextSpan(
                    text: 'Riwayat Penyuntingan',
                    style: TextStyle(
                      color: Color(0xFF007A87),
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
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

  Widget _buildLiveStatusCard() {
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
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.wifi_tethering, color: Color(0xFF007A87), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Aktif Live',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Pemasaran Aktif',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tampilkan kamar ini dalam hasil pencarian Go Ticket',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isLive,
                onChanged: (val) => setState(() => _isLive = val),
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF007A87),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Okupansi Rtn', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 2),
                    const Text(
                      '88%',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF007A87)),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: const [
                        Icon(Icons.arrow_upward, size: 10, color: Color(0xFF16A34A)),
                        Text('+6% vs bln lalu', style: TextStyle(fontSize: 9, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Reservasi Aktif', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    SizedBox(height: 2),
                    Text(
                      '14 Booking',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    SizedBox(height: 2),
                    Text('Check-in 7 hari ke dlm', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Rating Tamu', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    SizedBox(height: 2),
                    Text(
                      '4.9 / 5.0',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    SizedBox(height: 2),
                    Text('⭐ 128 Ulasan', style: TextStyle(fontSize: 9, color: Color(0xFFD97706), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
                    Icon(
                      Icons.tune,
                      size: 15,
                      color: _selectedTab == 0 ? Colors.white : const Color(0xFF475569),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '1. Spesifikasi & Kapasitas',
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
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 15,
                      color: _selectedTab == 1 ? Colors.white : const Color(0xFF475569),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '2. Tarif & Kuota',
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

  Widget _buildBasicInfoSection() {
    return _buildSectionContainer(
      icon: Icons.hotel,
      title: 'Informasi Dasar & Spesifikasi Fisik',
      subtitle: 'Detail identitas & kapasitas unit kamar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Tipe Kamar
          Row(
            children: const [
              Text(
                'Nama Tipe Kamar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
              ),
              Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nama yang akan ditampilkan di aplikasi tamu Go Ticket',
            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),

          const SizedBox(height: 14),
          // Kategori Kamar
          Row(
            children: const [
              Text(
                'Kategori Kamar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
              ),
              Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
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
          // 3 Column specs boxes
          Row(
            children: [
              Expanded(
                child: _buildSpecBox(
                  icon: Icons.square_foot,
                  title: 'Luas Kamar',
                  value: '52 m²',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSpecBox(
                  icon: Icons.bed,
                  title: 'Tipe Ranjang',
                  value: '1 Super King',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSpecBox(
                  icon: Icons.bathtub,
                  title: 'Kamar Mandi',
                  value: '1 Bathtub',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Kapasitas Tamu Maksimal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Kapasitas Tamu Maksimal',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                  ),
                  Text(
                    'Batas occupancy sebelum biaya tambahan',
                    style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  ),
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
                    child: Row(
                      children: const [
                        Icon(Icons.person, size: 14, color: Color(0xFF007A87)),
                        SizedBox(width: 4),
                        Text('2 Dewasa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF007A87))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.child_care, size: 14, color: Color(0xFF007A87)),
                        SizedBox(width: 4),
                        Text('1 Anak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF007A87))),
                      ],
                    ),
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
                const Icon(Icons.hotel, size: 18, color: Color(0xFF007A87)),
                const SizedBox(width: 10),
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
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaInventorySection() {
    return _buildSectionContainer(
      icon: Icons.layers_outlined,
      title: 'Alokasi Kuota & Inventaris',
      subtitle: 'Distribusi unit fisik dan channel OTA',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F7FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Total 12 Unit',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF007A87)),
        ),
      ),
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
                          Text('Di Go Ticket (OTA)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
                          Icon(Icons.public, size: 14, color: Color(0xFF0284C7)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(text: '10 ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                            TextSpan(text: 'Unit', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.circle, size: 6, color: Color(0xFF16A34A)),
                          SizedBox(width: 4),
                          Text('Kuota Online Terbuka', style: TextStyle(fontSize: 9, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                        ],
                      ),
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
                          Text('Cadangan FO / Direct', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                          Icon(Icons.lock_outline, size: 14, color: Color(0xFF475569)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(text: '2 ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                            TextSpan(text: 'Unit', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Buffer direct booking', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Text('Nomor Kamar Fisik Terpasang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 8),

          _buildFloorRooms('Lantai 2:', _roomsFloor2),
          const SizedBox(height: 6),
          _buildFloorRooms('Lantai 3:', _roomsFloor3),
          const SizedBox(height: 6),
          _buildFloorRooms('Lantai 4:', _roomsFloor4),

          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dialog tambah nomor kamar fisik')),
              );
            },
            icon: const Icon(Icons.add, size: 14, color: Color(0xFF007A87)),
            label: const Text('Hubungkan No. Kamar Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF007A87))),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(38),
              side: const BorderSide(color: Color(0xFFBAE6FD)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorRooms(String floorTitle, List<Map<String, dynamic>> rooms) {
    return Row(
      children: [
        SizedBox(
          width: 55,
          child: Text(floorTitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: rooms.map((r) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(r['num'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                    const SizedBox(width: 4),
                    const Icon(Icons.close, size: 10, color: Color(0xFF64748B)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return _buildSectionContainer(
      icon: Icons.monetization_on_outlined,
      title: 'Tarif & Dynamic Pricing',
      subtitle: 'Konfigurasi harga jual dan simulasi pendapatan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weekday (Sen – Kam)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _weekdayPriceController,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('/ malam', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weekend (Jum – Min)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _weekendPriceController,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('/ malam', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Kalkulasi Bersih
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
                    Text('Tarif Weekday:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    Text('Rp 1.450.000', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Komisi Go Ticket OTA (10%):', style: TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
                    Text('-Rp 145.000', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                  ],
                ),
                const Divider(height: 14, color: Color(0xFFE0F2FE)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Penerimaan bersih hotel:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF007A87))),
                    Text('Rp 1.305.000 / malam', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF007A87))),
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
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, size: 18, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Smart Surge Pricing Otomatis', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                      Text('Naikkan harga +15% otomatis saat okupansi resort > 85%', style: TextStyle(fontSize: 9, color: Color(0xFFB45309))),
                    ],
                  ),
                ),
                Switch(
                  value: _surgePricing,
                  onChanged: (val) => setState(() => _surgePricing = val),
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFFD97706),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_month_outlined, size: 14, color: Color(0xFF007A87)),
            label: const Text('Atur Kalender Tarif Khusus Musiman (Peak Season)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF007A87))),
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

  Widget _buildFacilitiesSection() {
    return _buildSectionContainer(
      icon: Icons.star_border,
      title: 'Fasilitas Kamar Unggulan',
      subtitle: 'Fasilitas terpilih yang muncul pada filter pencarian tamu',
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

  Widget _buildPhotoGallerySection() {
    return _buildSectionContainer(
      icon: Icons.photo_camera_back_outlined,
      title: 'Galeri Foto Resolusi Tinggi',
      subtitle: 'Rasio 16:9 atau 4:3, min. 1920x1080px',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text('Min 3 Foto', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildPhotoThumb('Cover Utama', Icons.bed)),
              const SizedBox(width: 8),
              Expanded(child: _buildPhotoThumb('Kamar Mandi', Icons.bathtub)),
              const SizedBox(width: 8),
              Expanded(child: _buildPhotoThumb('Balkon', Icons.deck)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBAE6FD), style: BorderStyle.solid),
            ),
            child: Column(
              children: const [
                Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xFF007A87)),
                SizedBox(height: 6),
                Text('Tarik & Lepaskan foto baru di sini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                SizedBox(height: 2),
                Text('Maksimal 10 foto (PNG, JPG, WEBP hingga 5MB)', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumb(String label, IconData icon) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 32),
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                  child: const Icon(Icons.edit, size: 10, color: Colors.white),
                ),
                const SizedBox(width: 3),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 10, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicySection() {
    return _buildSectionContainer(
      icon: Icons.shield_outlined,
      title: 'Kebijakan Pembatalan & Deposit',
      subtitle: 'Syarat pembatalan tamu & deposit check-in',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPolicyRadio(
            index: 0,
            title: 'Fleksibel: Bebas Pembatalan H-2',
            desc: 'Tamu dapat refund penuh hingga 48 jam sebelum jadwal check-in hotel.',
          ),
          const SizedBox(height: 8),
          _buildPolicyRadio(
            index: 1,
            title: 'Non-Refundable: Diskon Khusus 10%',
            desc: 'Tidak dapat dibatalkan atau dikembalikan setelah reservasi terkonfirmasi.',
          ),
          const SizedBox(height: 14),
          const Text('Deposit Jaminan Kerusakan (Security Deposit)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          TextFormField(
            controller: _depositController,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dikenakan saat check-in via pre-auth kartu kredit atau tunai di Front Office',
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

  Widget _buildBottomActions() {
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
            child: const Text('Batal / Reset', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perubahan tipe kamar berhasil disimpan!'),
                  backgroundColor: Color(0xFF007A87),
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Simpan Perubahan Kamar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007A87),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
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
