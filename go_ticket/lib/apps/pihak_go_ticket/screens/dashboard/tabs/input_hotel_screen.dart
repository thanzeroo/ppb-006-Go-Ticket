import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/config/supabase_config.dart';
import '../../../../../core/models/hotel_model.dart';
import '../../../../../core/services/hotel_service.dart';
import '../../../../../core/services/supabase_service.dart';
import 'formatters.dart';

/// Form Input & Edit Hotel & Kamar (Section A - Section E)
/// Sesuai dengan desain visual pada Gambar 1 (Input Hotel).
class InputHotelScreen extends StatefulWidget {
  final HotelModel? hotelToEdit;

  const InputHotelScreen({super.key, this.hotelToEdit});

  @override
  State<InputHotelScreen> createState() => _InputHotelScreenState();
}

class _InputHotelScreenState extends State<InputHotelScreen> {
  bool _isSubmitting = false;

  bool get _isEditMode => widget.hotelToEdit != null;

  // Section A: Informasi Properti
  late final TextEditingController _hotelNameController;
  late final TextEditingController _nibController;
  late final TextEditingController _npwpController;
  late final TextEditingController _ptNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _kecamatanController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalController;
  late final TextEditingController _phoneController;
  late final TextEditingController _waController;
  late final TextEditingController _emailController;

  // Koordinat Latitude & Longitude (Editable)
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

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

  // Section C: Foto Galeri
  List<String> _photoUrls = [
    'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=600&auto=format&fit=crop',
  ];

  // Section D: Room
  late final TextEditingController _roomNameController;
  late final TextEditingController _roomSizeController;
  late final TextEditingController _capacityController;
  late final TextEditingController _weekdayPriceController;
  late final TextEditingController _weekendPriceController;
  late final TextEditingController _extraBedController;

  int _guestCapacity = 2;
  String _selectedBedType = '1 Super King (200x200)';
  final List<String> _bedTypeOptions = [
    '1 Super King (200x200)',
    '1 King Bed (180x200)',
    '1 Queen Bed (160x200)',
    '2 Twin Bed (100x200)',
    '1 Double Bed (140x200)',
    '1 Single Bed (90x200)',
    'Bunk Bed (Tingkat)',
  ];

  final Map<String, bool> _roomAmenities = {
    'Smart TV 55"': true,
    'Bathtub Ocean View': true,
    'Mesin Espresso': true,
    'Balkon Pribadi': true,
    'AC Inverter': true,
    'Safe Deposit Box': true,
  };

  // Section E: Policy
  late final TextEditingController _checkInController;
  late final TextEditingController _checkOutController;
  late final TextEditingController _depositController;
  int _cancellationPolicy = 0; // 0 = Bebas Pembatalan (H-3), 1 = Non-Refundable

  @override
  void initState() {
    super.initState();
    final h = widget.hotelToEdit;

    _hotelNameController = TextEditingController(
      text: h?.name ?? 'Royal Sunset Luxury Resort & Spa',
    );
    _nibController = TextEditingController(text: '9120005431100');
    _npwpController = TextEditingController(text: '01.590.342.1-901.000');
    _ptNameController = TextEditingController(
      text: 'PT Royal Sunset Hospitality Indonesia',
    );
    _addressController = TextEditingController(
      text: h?.address ?? 'Jl. Sunset Road No. 88X, Seminyak',
    );
    _kecamatanController = TextEditingController(text: 'Kuta');
    _cityController = TextEditingController(
      text: h?.city ?? 'Badung, Bali',
    );
    _postalController = TextEditingController(text: '80361');
    _phoneController = TextEditingController(
      text: h?.phone ?? '+62 361 889211',
    );
    _waController = TextEditingController(
      text: h?.whatsapp ?? '+62 811-3829-001',
    );
    _emailController = TextEditingController(
      text: 'reservasi@royalsunset.id',
    );

    _latitudeController = TextEditingController(
      text: h?.latitude != null ? h!.latitude.toString() : '-8.691200',
    );
    _longitudeController = TextEditingController(
      text: h?.longitude != null ? h!.longitude.toString() : '115.168333',
    );

    if (h != null && h.photoUrls.isNotEmpty) {
      _photoUrls = List<String>.from(h.photoUrls);
    } else if (h != null && h.mainImageUrl != null && h.mainImageUrl!.isNotEmpty) {
      _photoUrls = [h.mainImageUrl!];
    }

    _roomNameController = TextEditingController(
      text: 'Deluxe Ocean Panorama Suite',
    );
    _roomSizeController = TextEditingController(text: '48');
    _capacityController = TextEditingController(text: '2');
    _weekdayPriceController = TextEditingController(
      text: ThousandsSeparatorInputFormatter.format(1250000),
    );
    _weekendPriceController = TextEditingController(
      text: ThousandsSeparatorInputFormatter.format(1550000),
    );
    _extraBedController = TextEditingController(
      text: ThousandsSeparatorInputFormatter.format(350000),
    );

    _checkInController = TextEditingController(
      text: h?.checkInTime ?? '14:00 WIB',
    );
    _checkOutController = TextEditingController(
      text: h?.checkOutTime ?? '12:00 WIB',
    );
    _depositController = TextEditingController(
      text: ThousandsSeparatorInputFormatter.format(200000),
    );

    _cancellationPolicy =
        (h?.cancellationPolicy?.contains('Non-Refundable') ?? false) ? 1 : 0;

    if (_isEditMode) {
      _fetchExistingRoomData();
    }
  }

  Future<void> _fetchExistingRoomData() async {
    final h = widget.hotelToEdit;
    if (h == null) return;
    try {
      final sb = SupabaseService.instance;
      final res = await sb
          .table(SupabaseConfig.tableTipeKamar)
          ?.select()
          .eq('id_penginapan', int.tryParse(h.id) ?? 0)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() {
          if (res['nama_tipe'] != null) {
            _roomNameController.text = res['nama_tipe'].toString();
          }
          if (res['luas_m2'] != null) {
            _roomSizeController.text = res['luas_m2'].toString();
          }
          if (res['kapasitas_tamu'] != null) {
            _guestCapacity = (res['kapasitas_tamu'] as num).toInt();
            _capacityController.text = '$_guestCapacity';
          }
          if (res['tipe_bed'] != null) {
            final b = res['tipe_bed'].toString();
            if (_bedTypeOptions.contains(b)) {
              _selectedBedType = b;
            } else {
              _bedTypeOptions.add(b);
              _selectedBedType = b;
            }
          }
          if (res['harga_dasar'] != null) {
            _weekdayPriceController.text =
                ThousandsSeparatorInputFormatter.format(res['harga_dasar']);
          }
          if (res['harga_weekend'] != null) {
            _weekendPriceController.text =
                ThousandsSeparatorInputFormatter.format(res['harga_weekend']);
          }
        });
      }
    } catch (_) {}
  }

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
    _latitudeController.dispose();
    _longitudeController.dispose();
    _roomNameController.dispose();
    _roomSizeController.dispose();
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
                  // Section A: Info Dasar & Koordinat
                  _buildSectionA(),
                  const SizedBox(height: 16),

                  // Section B: Fasilitas Unggulan
                  _buildSectionB(),
                  const SizedBox(height: 16),

                  // Section C: Galeri Media & Foto
                  _buildSectionC(),
                  const SizedBox(height: 16),

                  // Section D: Tipe Kamar, Ranjang & Harga
                  _buildSectionD(),
                  const SizedBox(height: 16),

                  // Section E: Kebijakan Check-In & Pembatalan
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
                  Text(
                    _isEditMode ? 'Kelola & Edit Hotel' : 'Input Hotel & Kamar',
                    style: const TextStyle(
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
                      Text(
                        _isEditMode
                            ? 'Mode Edit: ${widget.hotelToEdit!.name}'
                            : 'Pendaftaran Properti Baru',
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFCFFAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _isEditMode ? 'EDIT' : 'BARU',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0891B2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section A: Informasi Legalitas & Profil Properti
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
          Row(
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
                      'Section A: Informasi Legalitas\n& Profil Properti',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Identitas badan usaha dan izin operasional pariwisata',
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
                  'Wajib\nSuperAdmin',
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

          // Nama Hotel / Properti Komersial *
          const Text(
            'Nama Hotel / Properti Komersial *',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          _buildInputBox(
            controller: _hotelNameController,
            hint: 'Contoh: Grand Amora Hotel & Resort',
          ),
          const SizedBox(height: 12),

          // Kategori Penginapan
          const Text(
            'Kategori Penginapan',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          _buildCategoryGrid(),
          const SizedBox(height: 14),

          // Verifikasi Dokumen Badan Usaha Subcard
          _buildLegalVerificationSubcard(),
          const SizedBox(height: 14),

          // Alamat Fisik Lengkap
          const Text(
            'Alamat Fisik Lengkap & Wilayah Hukum *',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          _buildInputBox(
            controller: _addressController,
            hint: 'Nama Jalan, Nomor, RT/RW',
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildInputBox(
                  controller: _cityController,
                  hint: 'Kota / Kabupaten *',
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
          const SizedBox(height: 12),

          // Koordinat Latitude & Longitude (Point 3: Bisa diedit dan disambung Google Maps)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF007A94)),
                  SizedBox(width: 4),
                  Text(
                    'Koordinat GPS (Google Maps)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _showCoordinatesHelperDialog,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.content_paste_rounded, size: 12, color: Color(0xFF0284C7)),
                      SizedBox(width: 4),
                      Text(
                        'Tempel dari Maps',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildInputBox(
                  controller: _latitudeController,
                  hint: 'Latitude (mis. -8.691200)',
                  prefixIcon: Icons.my_location_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInputBox(
                  controller: _longitudeController,
                  hint: 'Longitude (mis. 115.168333)',
                  prefixIcon: Icons.explore_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Kontak Operasional & Concierge
          const Text(
            'Kontak Operasional & Concierge',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: _phoneController,
            hint: 'Nomor Telepon Kantor',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: _waController,
            hint: 'WhatsApp Layanan Tamu',
            prefixIcon: Icons.chat_bubble_outline_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: _emailController,
            hint: 'Email Reservasi',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  void _showCoordinatesHelperDialog() {
    final pasteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.pin_drop_rounded, color: Color(0xFF00758F)),
            SizedBox(width: 8),
            Text('Input Koordinat Google Maps',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tempel link Google Maps atau format "Latitude, Longitude" langsung:',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pasteCtrl,
              decoration: InputDecoration(
                hintText: 'Contoh: -8.691200, 115.168333 atau link Maps',
                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00758F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final raw = pasteCtrl.text.trim();
              Navigator.pop(ctx);
              _parseAndSetCoordinates(raw);
            },
            child: const Text('Terapkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _parseAndSetCoordinates(String raw) {
    if (raw.isEmpty) return;

    // Cek format "-8.123, 115.123"
    final directMatch =
        RegExp(r'(-?\d+\.\d+)[,\s]+(-?\d+\.\d+)').firstMatch(raw);
    if (directMatch != null) {
      setState(() {
        _latitudeController.text = directMatch.group(1)!;
        _longitudeController.text = directMatch.group(2)!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koordinat berhasil diterapkan!'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      return;
    }

    // Cek format link Google Maps @-8.123,115.123
    final linkMatch =
        RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)').firstMatch(raw);
    if (linkMatch != null) {
      setState(() {
        _latitudeController.text = linkMatch.group(1)!;
        _longitudeController.text = linkMatch.group(2)!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koordinat dari link Google Maps berhasil diserap!'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Format koordinat tidak dikenali. Masukkan contoh: -8.691200, 115.168333'),
        backgroundColor: Colors.orange,
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
                child: const Icon(Icons.stars_rounded, size: 18, color: Color(0xFF0096B4)),
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
                      'Fasilitas publik & layanan utama yang tampil di badge pencarian',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 8 Checklist Fasilitas
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _facilities.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final key = _facilities.keys.elementAt(index);
              final isChecked = _facilities[key] ?? false;
              final icon = facilityIcons[key] ?? Icons.check_circle_outline;

              return InkWell(
                onTap: () => setState(() => _facilities[key] = !isChecked),
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
                      Icon(icon, size: 14, color: const Color(0xFF64748B)),
                      const SizedBox(width: 4),
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
  // Section C: Galeri Media & Foto Resmi (Point 4: Berfungsi Penuh)
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
                      'Format JPG/PNG, rasio 16:9, foto pertama menjadi Cover Utama',
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
                child: Text(
                  '${_photoUrls.length}/10\nFoto',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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

          // Dashed border upload card (Bisa diklik untuk upload/tambah foto)
          InkWell(
            onTap: _showAddPhotoModal,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
                    'Unggah Foto Hotel / Tambah Gambar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ketuk untuk pilih dari galeri perangkat atau masukkan link URL foto',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dynamic Thumbnail Previews
          if (_photoUrls.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photoUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final url = _photoUrls[idx];
                  final isCover = idx == 0;
                  return Stack(
                    children: [
                      Container(
                        width: 140,
                        height: 105,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCover
                                ? const Color(0xFF00758F)
                                : const Color(0xFFE2E8F0),
                            width: isCover ? 2 : 1,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(url),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Badge
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCover
                                ? const Color(0xFF00758F).withOpacity(0.9)
                                : Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isCover ? 'Cover Utama ⭐' : 'Foto ${idx + 1}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Hapus tombol
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            setState(() => _photoUrls.removeAt(idx));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 13, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 12),

          // Tambah Foto Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: _showAddPhotoModal,
              icon: const Icon(Icons.add_photo_alternate_outlined,
                  size: 16, color: Color(0xFF007A94)),
              label: const Text(
                '+ Tambah Foto / URL Galeri',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF007A94)),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF2FE),
                side: const BorderSide(color: Color(0xFFBAE6FD)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPhotoModal() {
    final urlCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tambah Foto Hotel',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Opsi 1: Dari Galeri Perangkat via ImagePicker
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_camera_back_outlined,
                    color: Color(0xFF007A94)),
              ),
              title: const Text('Pilih dari Galeri Perangkat',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
              subtitle: const Text('Pilih file gambar langsung dari HP/Komputer',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final picker = ImagePicker();
                  final picked =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() {
                      _photoUrls.add(picked.path);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Foto berhasil ditambahkan!'),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Picker error: $e');
                }
              },
            ),
            const Divider(),

            // Opsi 2: Input URL Foto
            const Text(
              'Atau Masukkan URL Gambar (Direct Link):',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: urlCtrl,
              decoration: InputDecoration(
                hintText: 'https://example.com/foto-hotel.jpg',
                hintStyle: const TextStyle(fontSize: 11),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00758F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final url = urlCtrl.text.trim();
                  if (url.isNotEmpty) {
                    setState(() => _photoUrls.add(url));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Foto URL berhasil ditambahkan!'),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  }
                },
                child: const Text('Tambahkan URL Foto',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section D: Master Tipe Kamar Pertama (Point 5, 6, 7)
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
          _buildInputBox(
            controller: _roomNameController,
            hint: 'Contoh: Deluxe Ocean Panorama Suite',
          ),
          const SizedBox(height: 10),

          // 3 Columns: Luas Kamar, Tipe Ranjang (Dropdown), Kapasitas Tamu (+/-)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Luas Kamar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Luas Kamar', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildInputBox(
                      controller: _roomSizeController,
                      suffixText: 'm²',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Tipe Ranjang: Dropdown Pilihan Nyata (Point 5)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tipe Ranjang (Pilih)', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _bedTypeOptions.contains(_selectedBedType)
                              ? _selectedBedType
                              : _bedTypeOptions.first,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 18, color: Color(0xFF64748B)),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          items: _bedTypeOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text(opt, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedBedType = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Kapasitas Tamu (Point 6: Menggunakan inputan + / - atau bisa diketik manual)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kapasitas Tamu (Dewasa / Anak)',
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Tombol Minus [-]
                    InkWell(
                      onTap: () {
                        if (_guestCapacity > 1) {
                          setState(() {
                            _guestCapacity--;
                            _capacityController.text = '$_guestCapacity';
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Icon(Icons.remove, size: 16, color: Color(0xFF00758F)),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Teks manual input di tengah
                    Expanded(
                      child: TextField(
                        controller: _capacityController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          suffixText: 'Tamu',
                          suffixStyle: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), ''));
                          if (parsed != null && parsed > 0) {
                            _guestCapacity = parsed;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tombol Plus [+]
                    InkWell(
                      onTap: () {
                        setState(() {
                          _guestCapacity++;
                          _capacityController.text = '$_guestCapacity';
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Icon(Icons.add, size: 16, color: Color(0xFF00758F)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Alokasi Kuota & Skema Tarif Subcard (Point 7: Angka Otomatis Ada Titik Pemisah Ribuan)
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
                const SizedBox(height: 10),
                const Text('Harga Weekday (Sen–Kam) *',
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                _buildPriceInputBox(controller: _weekdayPriceController),
                const SizedBox(height: 8),
                const Text('Harga Weekend (Jum–Min) *',
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                _buildPriceInputBox(controller: _weekendPriceController),
                const SizedBox(height: 8),
                const Text('Biaya Tambahan Extra Bed',
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                _buildPriceInputBox(controller: _extraBedController),
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
  // Section E: Kebijakan Check-In & Pembatalan (Point 8: showTimePicker Bulat)
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
            ],
          ),
          const SizedBox(height: 14),

          // 3 Columns: Waktu Check-in, Waktu Check-out, Deposit Jaminan
          Row(
            children: [
              // Waktu Check-in (showTimePicker bulat)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Waktu Check-in *',
                        style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => showRoundTimePicker(
                        context: context,
                        controller: _checkInController,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: IgnorePointer(
                        child: _buildInputBox(
                          controller: _checkInController,
                          suffixIcon: Icons.access_time_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Waktu Check-out (showTimePicker bulat)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Waktu Check-out *',
                        style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => showRoundTimePicker(
                        context: context,
                        controller: _checkOutController,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: IgnorePointer(
                        child: _buildInputBox(
                          controller: _checkOutController,
                          suffixIcon: Icons.access_time_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Deposit Jaminan (Format titik)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Deposit Jaminan',
                        style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    _buildPriceInputBox(controller: _depositController),
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
  // Submit Form: Create or Update Hotel (Point 9)
  // ---------------------------------------------------------------------------
  Future<void> _submitForm() async {
    final name = _hotelNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama hotel / properti wajib diisi!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    if (address.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat dan kota wajib diisi!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final weekdayPrice =
          ThousandsSeparatorInputFormatter.parse(_weekdayPriceController.text);
      final weekendPrice =
          ThousandsSeparatorInputFormatter.parse(_weekendPriceController.text);
      final deposit =
          ThousandsSeparatorInputFormatter.parse(_depositController.text);

      String formatTime(String text, String fallback) {
        final match = RegExp(r'\b(\d{1,2}):(\d{2})\b').firstMatch(text);
        if (match != null) {
          final h = match.group(1)!.padLeft(2, '0');
          final m = match.group(2)!;
          return '$h:$m:00';
        }
        return fallback;
      }

      final checkInTime = formatTime(_checkInController.text, '14:00:00');
      final checkOutTime = formatTime(_checkOutController.text, '12:00:00');

      final activeFacilities = _facilities.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      final activeAmenities = _roomAmenities.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      final lat = double.tryParse(_latitudeController.text.trim());
      final long = double.tryParse(_longitudeController.text.trim());
      final mainImage = _photoUrls.isNotEmpty ? _photoUrls.first : null;

      if (_isEditMode) {
        // MODE EDIT HOTEL
        final hotelId = widget.hotelToEdit!.id;
        final ok = await HotelService.instance.updateHotel(
          hotelId: hotelId,
          name: name,
          city: city,
          address: address,
          phone: _phoneController.text.trim(),
          whatsapp: _waController.text.trim(),
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
          deposit: deposit,
          cancellationPolicy: _cancellationPolicy == 0
              ? 'Bebas Pembatalan (H-3)'
              : 'Non-Refundable',
          latitude: lat,
          longitude: long,
          mainImageUrl: mainImage,
          ptName: _ptNameController.text.trim(),
          npwp: _npwpController.text.trim(),
          nib: _nibController.text.trim(),
        );

        if (!mounted) return;
        setState(() => _isSubmitting = false);

        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil! Perubahan data hotel telah disimpan.'),
              backgroundColor: Color(0xFF16A34A),
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('Gagal memperbarui data hotel di database.');
        }
      } else {
        // MODE INPUT HOTEL BARU
        await HotelService.instance.createHotel(
          name: name,
          address: address,
          city: city,
          ptName: _ptNameController.text.trim(),
          nib: _nibController.text.trim(),
          npwp: _npwpController.text.trim(),
          phone: _phoneController.text.trim(),
          whatsapp: _waController.text.trim(),
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
          deposit: deposit,
          cancellationPolicy: _cancellationPolicy == 0
              ? 'Bebas Pembatalan (H-3)'
              : 'Non-Refundable',
          facilities: activeFacilities,
          latitude: lat,
          longitude: long,
          mainImageUrl: mainImage,
          imageUrls: _photoUrls,
          roomName: _roomNameController.text.trim(),
          roomCapacity: _guestCapacity,
          roomSizeM2: double.tryParse(
                  _roomSizeController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ??
              36.0,
          bedType: _selectedBedType,
          weekdayPrice: weekdayPrice > 0 ? weekdayPrice : 500000.0,
          weekendPrice: weekendPrice > 0 ? weekendPrice : 600000.0,
          roomAmenities: activeAmenities,
        );

        if (!mounted) return;
        setState(() => _isSubmitting = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Berhasil! Hotel dan data kamar berhasil disimpan ke database Supabase.'),
            backgroundColor: Color(0xFF00758F),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan hotel: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
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
          onPressed: _isSubmitting ? null : _submitForm,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.cloud_done_rounded, size: 18, color: Colors.white),
          label: Text(
            _isSubmitting
                ? 'Menyimpan ke Database...'
                : (_isEditMode
                    ? 'Simpan Perubahan Hotel ➔'
                    : 'Lanjutkan & Daftarkan Hotel ➔'),
            style: const TextStyle(
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
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
            fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
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
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    )
                  : null),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }

  /// Input box khusus nominal angka dengan otomatis titik ribuan (Point 7)
  Widget _buildPriceInputBox({
    required TextEditingController controller,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          ThousandsSeparatorInputFormatter(),
        ],
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          prefixText: 'Rp ',
          prefixStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF007A94)),
          hintText: hint ?? '0',
          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }
}
