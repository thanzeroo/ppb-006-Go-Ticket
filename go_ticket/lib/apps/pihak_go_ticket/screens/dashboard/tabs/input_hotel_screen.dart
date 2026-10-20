import 'package:flutter/material.dart';

/// Form Input Hotel & Kamar (Section A - Section E)
/// Sesuai dengan desain visual pada Gambar 1 (Input Hotel).
class InputHotelScreen extends StatefulWidget {
  const InputHotelScreen({super.key});

  @override
  State<InputHotelScreen> createState() => _InputHotelScreenState();
}

class _InputHotelScreenState extends State<InputHotelScreen> {
  // Section A
  final _hotelNameController =
      TextEditingController(text: 'Royal Sunset Luxury Resort & Spa');
  final _nibController = TextEditingController(text: '9120005431100');
  final _npwpController = TextEditingController(text: '01.590.342.1-901.000');
  final _ptNameController =
      TextEditingController(text: 'PT Royal Sunset Hospitality Indonesia');
  final _addressController =
      TextEditingController(text: 'Jl. Sunset Road No. 88X, Seminyak');
  final _kecamatanController = TextEditingController(text: 'Kuta');
  final _cityController = TextEditingController(text: 'Badung, Bali');
  final _postalController = TextEditingController(text: '80361');
  final _phoneController = TextEditingController(text: '+62 361 889211');
  final _waController = TextEditingController(text: '+62 811-3829-001');
  final _emailController = TextEditingController(text: 'reservasi@royalsunset.id');

  int _selectedCategory = 0; // 0 = Resor Bintang 5

  // Section B: Facilities
  final Map<String, bool> _facilities = {
    'Infinity Pool': true,
    'WiFi 100Mbps': true,
    'Spa & Wellness': true,
    'Sarapan Buffet': true,
    'Parkir Valet Gratis': true,
    'Shuttle Bandara': true,
    'Resto & Bar 24 Jam': true,
    'Pet-Friendly': true,
  };

  // Section D: Room
  final _roomNameController =
      TextEditingController(text: 'Deluxe Ocean Panorama Suite');
  final _roomSizeController = TextEditingController(text: '48');
  final _bedTypeController = TextEditingController(text: '1 Super King');
  final _capacityController = TextEditingController(text: '2 Dws, 1 Anak');
  final _weekdayPriceController = TextEditingController(text: 'Rp 1.250.000');
  final _weekendPriceController = TextEditingController(text: 'Rp 1.550.000');
  final _extraBedController = TextEditingController(text: 'Rp 350.000');

  final Map<String, bool> _roomAmenities = {
    'Smart TV 55"': true,
    'Bathtub Ocean View': true,
    'Mesin Espresso': true,
    'Balkon Pribadi': true,
    'AC Inverter': true,
    'Safe Deposit Box': true,
  };

  // Section E: Policy
  final _checkInController = TextEditingController(text: '14:00 WIB');
  final _checkOutController = TextEditingController(text: '12:00 WIB');
  final _depositController = TextEditingController(text: 'Rp 200.000');
  int _cancellationPolicy = 0; // 0 = Bebas Pembatalan (H-3), 1 = Non-Refundable

  @override
  void dispose() {
    _hotelNameController.dispose();
    _nibController.dispose();
    _npwpController.dispose();
    _ptNameController.dispose();
    _addressController.dispose();
    _kecamatanController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _phoneController.dispose();
    _waController.dispose();
    _emailController.dispose();
    _roomNameController.dispose();
    _roomSizeController.dispose();
    _bedTypeController.dispose();
    _capacityController.dispose();
    _weekdayPriceController.dispose();
    _weekendPriceController.dispose();
    _extraBedController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();
    _depositController.dispose();
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
                  // Section A
                  _buildSectionA(),
                  const SizedBox(height: 16),

                  // Section B
                  _buildSectionB(),
                  const SizedBox(height: 16),

                  // Section C
                  _buildSectionC(),
                  const SizedBox(height: 16),

                  // Section D
                  _buildSectionD(),
                  const SizedBox(height: 16),

                  // Section E
                  _buildSectionE(),
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
                children: [
                  const Text(
                    'Input Hotel & Kamar',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Tersimpan otomatis 10:41 WIB',
                        style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFCFFAFE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: Color(0xFF0891B2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section A: Profil & Legalitas Usaha
  // ---------------------------------------------------------------------------
  Widget _buildSectionA() {
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
          // Section Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.apartment_rounded,
                    size: 18, color: Color(0xFF0096B4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Section A : Profil & Legalitas\nUsaha',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Identitas resmi perizinan operasional hotel di Go Ticket',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'OSS\nTerhubung',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Nama Resmi Hotel / Properti
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Nama Resmi Hotel / Properti *',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              Text(
                'Sesuai Akta & Papan Nama',
                style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildInputBox(
            controller: _hotelNameController,
            suffixIcon: Icons.explore_outlined,
          ),
          const SizedBox(height: 14),

          // Kategori & Sertifikasi Bintang
          const Text(
            'Kategori & Sertifikasi Bintang *',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          _buildCategoryGrid(),
          const SizedBox(height: 14),

          // Subcard: Verifikasi Dokumen Badan Usaha
          _buildLegalVerificationSubcard(),
          const SizedBox(height: 14),

          // Lokasi Lengkap & Pinpoint Maps
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lokasi Lengkap & Pinpoint Maps\n*',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              Row(
                children: const [
                  Icon(Icons.location_on, size: 13, color: Color(0xFF007A94)),
                  SizedBox(width: 3),
                  Text(
                    'Set Titik GPS\nAkurat',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF007A94),
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: _addressController,
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 8),

          // Row 3 fields (Kecamatan, Kota, Kode Pos)
          Row(
            children: [
              Expanded(
                child: _buildInputBox(
                  controller: _kecamatanController,
                  hint: 'Kecamatan',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildInputBox(
                  controller: _cityController,
                  hint: 'Kota/Kabupaten',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildInputBox(
                  controller: _postalController,
                  hint: 'Kode Pos',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Coordinates Box with Validasi button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.navigation_outlined, size: 14, color: Color(0xFF007A94)),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Lat: -8.691200 , Long: 115.168333',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00758F),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Validasi',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Kontak Operasional & Concierge
          const Text(
            'Kontak Operasional & Concierge',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: _phoneController,
            prefixIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: _waController,
            prefixIcon: Icons.chat_bubble_outline_rounded,
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'label': 'Resor Bintang 5', 'icon': Icons.apartment_rounded},
      {'label': 'Hotel Butik Modern', 'icon': Icons.hotel_rounded},
      {'label': 'Villa Mewah Privat', 'icon': Icons.holiday_village_rounded},
      {'label': 'Glamping Eksklusif', 'icon': Icons.terrain_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final isSelected = _selectedCategory == index;
        final cat = categories[index];
        return InkWell(
          onTap: () => setState(() => _selectedCategory = index),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF006678) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? const Color(0xFF006678) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  cat['icon'] as IconData,
                  size: 15,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegalVerificationSubcard() {
    return Container(
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
            children: const [
              Icon(Icons.verified_outlined, size: 14, color: Color(0xFF007A94)),
              SizedBox(width: 6),
              Text(
                'Verifikasi Dokumen Badan Usaha\n(Kemeninves/BKPM)',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Nomor Induk Berusaha (NIB OSS)',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          _buildInputBox(controller: _nibController),
          const SizedBox(height: 8),
          const Text(
            'NPWP Perusahaan / PT',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          _buildInputBox(controller: _npwpController),
          const SizedBox(height: 8),
          const Text(
            'Nama PT / CV Penanggung Jawab Hukum',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          _buildInputBox(controller: _ptNameController),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section B: Fasilitas Unggulan Properti
  // ---------------------------------------------------------------------------
  Widget _buildSectionB() {
    final facilityIcons = {
      'Infinity Pool': Icons.pool_rounded,
      'WiFi 100Mbps': Icons.wifi_rounded,
      'Spa & Wellness': Icons.spa_rounded,
      'Sarapan Buffet': Icons.restaurant_rounded,
      'Parkir Valet Gratis': Icons.local_parking_rounded,
      'Shuttle Bandara': Icons.directions_bus_rounded,
      'Resto & Bar 24 Jam': Icons.local_bar_rounded,
      'Pet-Friendly': Icons.pets_rounded,
    };

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
                child: const Icon(Icons.star_outline_rounded,
                    size: 18, color: Color(0xFF0096B4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Section B: Fasilitas Unggulan\nProperti',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Checklist fasilitas utama yang tampil pada filter pencarian tamu',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFBAE6FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '8\nTerpilih',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0284C7),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 8 Checklist Cards in 2 columns
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _facilities.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final key = _facilities.keys.elementAt(index);
              final isChecked = _facilities[key] ?? false;
              final icon = facilityIcons[key] ?? Icons.check_circle_outline;

              return InkWell(
                onTap: () {
                  setState(() => _facilities[key] = !isChecked);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isChecked ? const Color(0xFF0096B4) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                        size: 16,
                        color: isChecked ? const Color(0xFF0096B4) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Icon(icon, size: 14, color: const Color(0xFF007A94)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          key,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section C: Galeri Media & Foto Resmi
  // ---------------------------------------------------------------------------
  Widget _buildSectionC() {
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
                child: const Icon(Icons.photo_library_outlined,
                    size: 18, color: Color(0xFF0096B4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Section C : Galeri Media &\nFoto Resmi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Min. 1920x1080px, format JPG/PNG, rasio 16:9',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFBAE6FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '3/10\nFoto',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0284C7),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dashed border upload card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF7DD3FC),
                style: BorderStyle.solid,
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFBAE6FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_upload_outlined,
                      size: 24, color: Color(0xFF0284C7)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unggah Foto Resolusi Tinggi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tarik & lepas berkas di sini atau ketuk untuk telusuri (Maks. 10MB/per foto)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3 Thumbnail previews row
          Row(
            children: [
              Expanded(
                child: _buildPhotoThumbnail(
                  imageUrl:
                      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=300&auto=format&fit=crop',
                  badge: 'Cover Utama ⭐',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPhotoThumbnail(
                  imageUrl:
                      'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=300&auto=format&fit=crop',
                  badge: "Kamar '01'",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPhotoThumbnail(
                  imageUrl:
                      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=300&auto=format&fit=crop',
                  badge: 'Balkon Panorama',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tambah Foto Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_photo_alternate_outlined,
                  size: 16, color: Color(0xFF007A94)),
              label: const Text(
                'Tambah Foto (+5 Slot Galeri)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF007A94)),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF2FE),
                side: const BorderSide(color: Color(0xFFBAE6FD)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail({required String imageUrl, required String badge}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 70,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFE2E8F0),
                child: const Icon(Icons.photo, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section D: Master Tipe Kamar Pertama
  // ---------------------------------------------------------------------------
  Widget _buildSectionD() {
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
                child: const Icon(Icons.bed_rounded, size: 18, color: Color(0xFF0096B4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Section D: Master Tipe\nKamar Pertama',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Setup kamar awal untuk ketersediaan reservasi instan',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFBAE6FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Slot\nKamar 01',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0284C7),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Nama Tipe Kamar
          const Text(
            'Nama Tipe Kamar *',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          _buildInputBox(controller: _roomNameController),
          const SizedBox(height: 10),

          // 3 Columns: Luas Kamar, Tipe Ranjang, Kapasitas Tamu
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Luas Kamar', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildInputBox(
                      controller: _roomSizeController,
                      suffixText: 'm²',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tipe Ranjang', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildInputBox(
                      controller: _bedTypeController,
                      suffixIcon: Icons.keyboard_arrow_down_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kapasitas Tamu', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildInputBox(controller: _capacityController),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Alokasi Kuota & Skema Tarif Subcard
          Container(
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
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.payments_outlined, size: 14, color: Color(0xFF007A94)),
                        SizedBox(width: 6),
                        Text(
                          'Alokasi Kuota & Skema\nTarif',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Kuota\nDijual',
                          style: TextStyle(fontSize: 9, color: Color(0xFF64748B), height: 1.1),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBAE6FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '15 Unit',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Harga Weekday (Sen–Kam)', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                _buildInputBox(controller: _weekdayPriceController),
                const SizedBox(height: 8),
                const Text('Harga Weekend (Jum–Min)', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                _buildInputBox(controller: _weekendPriceController),
                const SizedBox(height: 8),
                const Text('Biaya Tambahan Extra Bed', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                _buildInputBox(controller: _extraBedController),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Fasilitas Kamar Eksklusif Terpasang
          const Text(
            'Fasilitas Kamar Eksklusif Terpasang',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _roomAmenities.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final key = _roomAmenities.keys.elementAt(index);
              final isChecked = _roomAmenities[key] ?? false;
              return InkWell(
                onTap: () => setState(() => _roomAmenities[key] = !isChecked),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isChecked ? const Color(0xFF0096B4) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                        size: 15,
                        color: isChecked ? const Color(0xFF0096B4) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          key,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section E: Kebijakan Check-In & Pembatalan
  // ---------------------------------------------------------------------------
  Widget _buildSectionE() {
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
                child: const Icon(Icons.verified_user_outlined,
                    size: 18, color: Color(0xFF0096B4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Section E: Kebijakan Check-\nIn & Pembatalan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Aturan kedatangan tamu dan ketentuan pengembalian dana',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Standard\nOTA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Columns: Waktu Check-in, Waktu Check-out, Deposit Jaminan
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Waktu Check-in', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildInputBox(controller: _checkInController),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Waktu Check-out', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildInputBox(controller: _checkOutController),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Deposit Jaminan', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildInputBox(controller: _depositController),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Kebijakan Pembatalan Pesanan Tamu
          const Text(
            'Kebijakan Pembatalan Pesanan Tamu',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),

          // Option 1
          InkWell(
            onTap: () => setState(() => _cancellationPolicy = 0),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cancellationPolicy == 0 ? const Color(0xFFF0FDF4) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _cancellationPolicy == 0 ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _cancellationPolicy == 0
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 16,
                    color: _cancellationPolicy == 0 ? const Color(0xFF007A94) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Bebas Pembatalan (H-3)',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pengembalian dana 100% jika dibatalkan 3 hari sebelum jam check-in.',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Option 2
          InkWell(
            onTap: () => setState(() => _cancellationPolicy = 1),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cancellationPolicy == 1 ? const Color(0xFFFEF2F2) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _cancellationPolicy == 1 ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _cancellationPolicy == 1
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 16,
                    color: _cancellationPolicy == 1 ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Non-Refundable (Harga Promo)',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tidak ada pengembalian uang setelah reservasi terkonfirmasi.',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.3),
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
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Berhasil! Hotel & Kamar berhasil didaftarkan ke sistem.'),
                backgroundColor: Color(0xFF00758F),
              ),
            );
            Navigator.pop(context);
          },
          icon: const Icon(Icons.cloud_done_rounded, size: 18, color: Colors.white),
          label: const Text(
            'Lanjutkan & Daftarkan Hotel ➔',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00758F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
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
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 15, color: const Color(0xFF007A94))
              : null,
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
