import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../../core/config/supabase_config.dart';
import '../../../../../core/models/hotel_model.dart';
import '../../../../../core/services/hotel_service.dart';
import '../../../../../core/services/supabase_service.dart';
import 'package:go_ticket_admin/core/services/hotel_image_upload_service.dart';
import 'formatters.dart';

/// Data model form untuk tipe kamar di Section D
/// Model penampung form tipe kamar (Section D).
/// Mendukung penambahan fasilitas kamar secara dinamis (list kustom) per tipe kamar.
class RoomTypeFormData {
  final TextEditingController nameController;
  final TextEditingController sizeController;
  final TextEditingController capacityController;
  final TextEditingController weekdayPriceController;
  final TextEditingController weekendPriceController;
  final TextEditingController extraBedController;
  final TextEditingController totalUnitController;
  // Controller untuk mengetik fasilitas kamar kustom baru
  final TextEditingController amenityInputController;
  int guestCapacity;
  String selectedBedType;
  // Fasilitas kamar dinamis dalam bentuk List<String>
  List<String> roomAmenities;

  RoomTypeFormData({
    String name = '',
    String size = '',
    int capacity = 2,
    String weekdayPrice = '',
    String weekendPrice = '',
    String extraBed = '',
    String totalUnit = '10',
    String bedType = '1 King Bed (180x200)',
    List<String>? amenities,
  })  : nameController = TextEditingController(text: name),
        sizeController = TextEditingController(text: size),
        capacityController = TextEditingController(text: '$capacity'),
        weekdayPriceController = TextEditingController(text: weekdayPrice),
        weekendPriceController = TextEditingController(text: weekendPrice),
        extraBedController = TextEditingController(text: extraBed),
        totalUnitController = TextEditingController(text: totalUnit),
        amenityInputController = TextEditingController(),
        guestCapacity = capacity,
        selectedBedType = bedType,
        roomAmenities = amenities != null ? List<String>.from(amenities) : [];

  void dispose() {
    nameController.dispose();
    sizeController.dispose();
    capacityController.dispose();
    weekdayPriceController.dispose();
    weekendPriceController.dispose();
    extraBedController.dispose();
    totalUnitController.dispose();
    amenityInputController.dispose();
  }
}

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

  // Section A: Informasi Properti (kosongan saat buat mitra baru)
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

  // Koordinat Latitude & Longitude serta Link Google Maps
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _mapsUrlController;

  // Kategori: 0 = Resor, 1 = Hotel, 2 = Vila
  int _selectedCategory = 0;

  // Section B: Controller input fasilitas properti kustom & list dinamis
  final TextEditingController _facilityInputController = TextEditingController();
  List<String> _facilities = [];

  // Section C: Foto Galeri/Utama hotel (Hanya 1 foto per hotel)
  List<String> _photoUrls = [];

  // Section D: List Tipe Kamar (bisa banyak tipe kamar)
  List<RoomTypeFormData> _roomTypes = [];

  final List<String> _bedTypeOptions = [
    '1 Super King (200x200)',
    '1 King Bed (180x200)',
    '1 Queen Bed (160x200)',
    '2 Twin Bed (100x200)',
    '1 Double Bed (140x200)',
    '1 Single Bed (90x200)',
    'Bunk Bed (Tingkat)',
  ];

  // Section E: Policy
  late final TextEditingController _checkInController;
  late final TextEditingController _checkOutController;
  late final TextEditingController _depositController;
  int _cancellationPolicy = 0; // 0 = Bebas Pembatalan (H-3), 1 = Non-Refundable

  bool _isLocalFile(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return false;
    return path.startsWith('/') ||
        path.startsWith('file://') ||
        RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(path);
  }

  @override
  void initState() {
    super.initState();
    final h = widget.hotelToEdit;

    // Section A: Kosongkan semua data saat awal buat mitra baru
    _hotelNameController = TextEditingController(text: h?.name ?? '');
    _nibController = TextEditingController(text: '');
    _npwpController = TextEditingController(text: '');
    _ptNameController = TextEditingController(text: '');
    _addressController = TextEditingController(text: h?.address ?? '');
    _kecamatanController = TextEditingController(text: '');
    _cityController = TextEditingController(text: h?.city ?? '');
    _postalController = TextEditingController(text: '');
    _phoneController = TextEditingController(text: h?.phone ?? '');
    _waController = TextEditingController(text: h?.whatsapp ?? '');
    _emailController = TextEditingController(text: '');

    _latitudeController = TextEditingController(
      text: h?.latitude != null ? h!.latitude.toString() : '',
    );
    _longitudeController = TextEditingController(
      text: h?.longitude != null ? h!.longitude.toString() : '',
    );
    final double? initLat = h?.latitude;
    final double? initLng = h?.longitude;
    _mapsUrlController = TextEditingController(
      text: (initLat != null && initLng != null)
          ? 'https://www.google.com/maps?q=$initLat,$initLng'
          : '',
    );

    // Kategori: Resor (0), Hotel (1), Vila (2)
    _selectedCategory = 0;
    if (h != null) {
      final name = h.name.toLowerCase();
      if (name.contains('vila') || name.contains('villa')) {
        _selectedCategory = 2;
      } else if (name.contains('resor') || name.contains('resort')) {
        _selectedCategory = 0;
      } else {
        _selectedCategory = 1;
      }
    }

    // Section B: Fasilitas kustom hotel (list dinamis)
    if (h != null && h.amenities.isNotEmpty) {
      _facilities = List<String>.from(h.amenities);
    } else {
      _facilities = [];
    }

    // Section C: Foto Utama hotel (Maksimal 1 foto saja per hotel)
    if (h != null && h.photoUrls.isNotEmpty) {
      _photoUrls = [h.photoUrls.first];
    } else if (h != null && h.mainImageUrl != null && h.mainImageUrl!.isNotEmpty) {
      _photoUrls = [h.mainImageUrl!];
    } else {
      _photoUrls = [];
    }

    // Section D: Tipe Kamar (bisa banyak tipe kamar)
    if (_isEditMode) {
      _fetchExistingRoomData();
    } else {
      _roomTypes = [
        RoomTypeFormData(), // 1 tipe kamar kosong di awal
      ];
    }

    // Section E: Policy (kosongan saat buat baru)
    _checkInController = TextEditingController(text: h?.checkInTime ?? '');
    _checkOutController = TextEditingController(text: h?.checkOutTime ?? '');
    _depositController = TextEditingController(text: '');
    _cancellationPolicy =
        (h?.cancellationPolicy?.contains('Non-Refundable') ?? false) ? 1 : 0;
  }

  Future<void> _fetchExistingRoomData() async {
    final h = widget.hotelToEdit;
    if (h == null) return;
    try {
      final sb = SupabaseService.instance;

      // Ambil data legalitas & deposit dari tabel mitra_penginapan
      final hotelRow = await sb
          .table(SupabaseConfig.tableMitraPenginapan)
          ?.select()
          .eq('id_penginapan', int.tryParse(h.id) ?? 0)
          .maybeSingle();

      if (hotelRow != null && mounted) {
        setState(() {
          if (hotelRow['nib_perusahaan'] != null) {
            _nibController.text = hotelRow['nib_perusahaan'].toString();
          }
          if (hotelRow['npwp_perusahaan'] != null) {
            _npwpController.text = hotelRow['npwp_perusahaan'].toString();
          }
          if (hotelRow['nama_pt'] != null) {
            _ptNameController.text = hotelRow['nama_pt'].toString();
          }
          if (hotelRow['deposit_nominal'] != null) {
            _depositController.text =
                ThousandsSeparatorInputFormatter.format(hotelRow['deposit_nominal']);
          }
        });
      }

      final dbRooms = await HotelService.instance.getRoomsByHotel(h.id);
      if (dbRooms.isNotEmpty && mounted) {
        setState(() {
          _roomTypes = dbRooms.map((r) {
            final bed = r.bedType ?? '1 King Bed (180x200)';
            if (!_bedTypeOptions.contains(bed)) {
              _bedTypeOptions.add(bed);
            }
            return RoomTypeFormData(
              name: r.name,
              size: r.roomSizeM2 != null ? '${r.roomSizeM2!.toInt()}' : '',
              capacity: r.capacity > 0 ? r.capacity : 2,
              weekdayPrice: ThousandsSeparatorInputFormatter.format(r.priceWeekday),
              weekendPrice: ThousandsSeparatorInputFormatter.format(
                  r.weekendPrice ?? (r.priceWeekday * 1.2).toInt()),
              extraBed: '',
              totalUnit: '${r.totalUnits}',
              bedType: bed,
              amenities: List<String>.from(r.amenities),
            );
          }).toList();
        });
        return;
      }

      final res = await sb
          .table(SupabaseConfig.tableTipeKamar)
          ?.select()
          .eq('id_penginapan', int.tryParse(h.id) ?? 0)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() {
          final bed = res['tipe_bed']?.toString() ?? '1 King Bed (180x200)';
          if (!_bedTypeOptions.contains(bed)) {
            _bedTypeOptions.add(bed);
          }
          List<String> loadedAmenities = [];
          if (res['fasilitas_kamar'] != null) {
            loadedAmenities = res['fasilitas_kamar']
                .toString()
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
          }
          final room = RoomTypeFormData(
            name: res['nama_tipe']?.toString() ?? '',
            size: res['luas_m2']?.toString() ?? '',
            capacity: (res['kapasitas_tamu'] as num?)?.toInt() ?? 2,
            weekdayPrice: res['harga_dasar'] != null
                ? ThousandsSeparatorInputFormatter.format(res['harga_dasar'])
                : '',
            weekendPrice: res['harga_weekend'] != null
                ? ThousandsSeparatorInputFormatter.format(res['harga_weekend'])
                : '',
            totalUnit: res['total_unit']?.toString() ?? '10',
            bedType: bed,
            amenities: loadedAmenities,
          );
          _roomTypes = [room];
        });
      } else if (mounted && _roomTypes.isEmpty) {
        setState(() {
          _roomTypes = [RoomTypeFormData()];
        });
      }
    } catch (_) {
      if (mounted && _roomTypes.isEmpty) {
        setState(() {
          _roomTypes = [RoomTypeFormData()];
        });
      }
    }
  }

  @override
  void dispose() {
    _facilityInputController.dispose();
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
    _mapsUrlController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    for (final room in _roomTypes) {
      room.dispose();
    }
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

          // Koordinat & Google Maps (Mendukung link Maps, input manual, dan titik pokok populer)
          _buildCoordinatesSubcard(),
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

  /// Subcard Koordinat GPS & Google Maps
  /// Menyediakan hal-hal pokok dari Google Maps langsung:
  /// 1. Input/Tempel Link Google Maps langsung
  /// 2. Input manual Latitude & Longitude
  /// 3. Tombol pemilihan cepat titik lokasi pokok destinasi wisata hotel di Indonesia
  /// 4. Indikator status koordinat terhubung
  Widget _buildCoordinatesSubcard() {
    final hasCoords = _latitudeController.text.trim().isNotEmpty &&
        _longitudeController.text.trim().isNotEmpty;

    // Titik lokasi pokok Google Maps untuk destinasi hotel terpopuler di Indonesia
    final quickLocations = [
      {'label': '🏝️ Bali (Seminyak)', 'lat': '-8.691200', 'lng': '115.168333'},
      {'label': '🏖️ Bali (Kuta)', 'lat': '-8.721800', 'lng': '115.169500'},
      {'label': '🌿 Bali (Ubud)', 'lat': '-8.506900', 'lng': '115.262500'},
      {'label': '🏢 Jakarta', 'lat': '-6.175400', 'lng': '106.827200'},
      {'label': '☕ Bandung', 'lat': '-6.917500', 'lng': '107.619100'},
      {'label': '🏛️ Yogyakarta', 'lat': '-7.795600', 'lng': '110.369500'},
      {'label': '🏝️ Lombok', 'lat': '-8.583300', 'lng': '116.333300'},
      {'label': '🏙️ Surabaya', 'lat': '-7.257500', 'lng': '112.752100'},
    ];

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on_rounded, size: 15, color: Color(0xFF007A94)),
                  SizedBox(width: 6),
                  Text(
                    'Koordinat GPS & Google Maps',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _showCoordinatesHelperDialog,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
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
          const SizedBox(height: 4),
          const Text(
            'Tempel tautan Google Maps atau pilih titik pokok destinasi di bawah',
            style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),

          // 1. Input Langsung Link / URL Google Maps
          TextField(
            controller: _mapsUrlController,
            onChanged: (val) {
              if (val.trim().isNotEmpty) {
                _parseAndSetCoordinates(val.trim(), isSilent: true);
              }
            },
            style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Tempel link Google Maps (misal: https://maps.app.goo.gl/...)',
              hintStyle: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.link_rounded, size: 16, color: Color(0xFF007A94)),
              suffixIcon: _mapsUrlController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 14, color: Color(0xFF94A3B8)),
                      onPressed: () {
                        setState(() {
                          _mapsUrlController.clear();
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0096B4), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Row Input Manual Latitude & Longitude
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
          const SizedBox(height: 10),

          // 3. Pilihan Cepat Titik Lokasi Pokok Google Maps (Mudah saat buat hotel baru)
          const Text(
            'Titik Lokasi Pokok dari Maps (Pilih Cepat):',
            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quickLocations.map((loc) {
                final isCurrent = _latitudeController.text.trim() == loc['lat'] &&
                    _longitudeController.text.trim() == loc['lng'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _latitudeController.text = loc['lat']!;
                        _longitudeController.text = loc['lng']!;
                        _mapsUrlController.text =
                            'https://www.google.com/maps?q=${loc['lat']},${loc['lng']}';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Titik Maps ${loc['label']} berhasil diterapkan!'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: const Color(0xFF00758F),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF00758F) : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isCurrent ? const Color(0xFF00758F) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Text(
                        loc['label']!,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                          color: isCurrent ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 4. Indikator Titik Koordinat Aktif
          if (hasCoords) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF16A34A)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Titik Maps: ${_latitudeController.text.trim()}, ${_longitudeController.text.trim()} (Tersambung)',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                      overflow: TextOverflow.ellipsis,
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

  /// Dialog modal bantuan untuk menempel koordinat atau link Google Maps
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

  /// Parser cerdas untuk mengekstrak koordinat dari link / teks Google Maps apapun
  void _parseAndSetCoordinates(String raw, {bool isSilent = false}) {
    if (raw.trim().isEmpty) return;
    final text = raw.trim();

    String? lat;
    String? lng;

    // 1. Cek format @lat,long
    final m1 = RegExp(r'@(-?\d{1,3}\.\d+),(-?\d{1,3}\.\d+)').firstMatch(text);
    if (m1 != null) {
      lat = m1.group(1);
      lng = m1.group(2);
    }

    // 2. Cek query q=lat,long atau query=lat,long
    if (lat == null) {
      final m2 = RegExp(r'[?&](?:q|query)=(-?\d{1,3}\.\d+)[,+](-?\d{1,3}\.\d+)').firstMatch(text);
      if (m2 != null) {
        lat = m2.group(1);
        lng = m2.group(2);
      }
    }

    // 3. Cek format Google Maps embed !3dlat!4dlong atau !2dlong!3dlat
    if (lat == null) {
      final m3 = RegExp(r'!3d(-?\d{1,3}\.\d+).*?!4d(-?\d{1,3}\.\d+)').firstMatch(text);
      if (m3 != null) {
        lat = m3.group(1);
        lng = m3.group(2);
      }
    }
    if (lat == null) {
      final m3b = RegExp(r'!2d(-?\d{1,3}\.\d+).*?!3d(-?\d{1,3}\.\d+)').firstMatch(text);
      if (m3b != null) {
        lat = m3b.group(2);
        lng = m3b.group(1);
      }
    }

    // 4. Cek parameter ll=lat,long
    if (lat == null) {
      final m4 = RegExp(r'[?&]ll=(-?\d{1,3}\.\d+)[,+](-?\d{1,3}\.\d+)').firstMatch(text);
      if (m4 != null) {
        lat = m4.group(1);
        lng = m4.group(2);
      }
    }

    // 5. Cek pasangan angka desimal latitude & longitude langsung dalam teks
    if (lat == null) {
      final m5 = RegExp(r'(-?\d{1,3}\.\d+)[^\d\-]+(-?\d{1,3}\.\d+)').firstMatch(text);
      if (m5 != null) {
        lat = m5.group(1);
        lng = m5.group(2);
      }
    }

    if (lat != null && lng != null) {
      setState(() {
        _latitudeController.text = lat!;
        _longitudeController.text = lng!;
        if (_mapsUrlController.text != text && (text.startsWith('http://') || text.startsWith('https://'))) {
          _mapsUrlController.text = text;
        }
      });
      if (!isSilent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Koordinat dari Maps ($lat, $lng) berhasil diterapkan!'),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
      return;
    }

    if (!isSilent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format link/koordinat Maps tidak dikenali. Contoh: -8.691200, 115.168333 atau link Google Maps'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Section A: Pilihan Kategori Hotel (Resor, Hotel, Vila)
  /// Ditata secara rapi dalam satu baris (3 kolom) untuk mencegah overflow di layar HP.
  Widget _buildCategoryGrid() {
    final categories = [
      {'label': 'Resor', 'icon': Icons.apartment_rounded},
      {'label': 'Hotel', 'icon': Icons.hotel_rounded},
      {'label': 'Vila', 'icon': Icons.holiday_village_rounded},
    ];

    return Row(
      children: List.generate(categories.length, (index) {
        final isSelected = _selectedCategory == index;
        final cat = categories[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == categories.length - 1 ? 0 : 4,
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = index),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF006678) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF006678) : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        cat['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
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
          _buildInputBox(
            controller: _nibController,
            hint: '',
          ),
          const SizedBox(height: 8),
          const Text(
            'NPWP Perusahaan / PT',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          _buildInputBox(
            controller: _npwpController,
            hint: '',
          ),
          const SizedBox(height: 8),
          const Text(
            'Nama PT / CV Penanggung Jawab Hukum',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          _buildInputBox(
            controller: _ptNameController,
            hint: '',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section B: Fasilitas Unggulan Properti
  // ---------------------------------------------------------------------------
  // Fungsi untuk menambahkan fasilitas hotel baru ke dalam daftar
  void _addCustomFacility() {
    final text = _facilityInputController.text.trim();
    if (text.isEmpty) return;
    if (!_facilities.contains(text)) {
      setState(() {
        _facilities.add(text);
      });
    }
    _facilityInputController.clear();
  }

  /// Section B: Fasilitas Unggulan Properti
  /// Pengguna dapat mengetik dan mendaftarkan fasilitas kustom sendiri tanpa batasan checklist kaku.
  Widget _buildSectionB() {
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
                      'Section B: Fasilitas Unggulan Properti',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ketik fasilitas publik & layanan hotel lalu tekan tombol Tambah',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Input field untuk mengetik fasilitas kustom hotel
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _facilityInputController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addCustomFacility(),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ketik fasilitas properti (misal: Kolam Renang, Gym)...',
                      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF0096B4), width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: _addCustomFacility,
                  icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    'Tambah',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00758F),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daftar fasilitas kustom yang telah ditambahkan (menggunakan Wrap agar responsive di layar HP)
          if (_facilities.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Belum ada fasilitas yang ditambahkan. Ketik nama fasilitas di atas lalu tekan Tambah.',
                style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _facilities.map((fac) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0096B4).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF007A94)),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Text(
                          fac,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _facilities.remove(fac);
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.close_rounded, size: 14, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section C: Galeri Media & Foto Resmi (Point 4: Berfungsi Penuh)
  // ---------------------------------------------------------------------------
  /// Section C: Galeri & Foto Utama Hotel (Dibatasi 1 Foto Saja)
  /// Pengguna hanya dapat menambahkan/mengunggah 1 foto utama per hotel.
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
                child: const Icon(Icons.photo_library_outlined, size: 18, color: Color(0xFF0096B4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Section C : Foto Utama Hotel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Format JPG/PNG, rasio 16:9, foto tunggal untuk profil hotel',
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
                  '${_photoUrls.length}/1 Foto',
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

          // Tampilan jika foto masih kosong: Tombol unggah besar
          if (_photoUrls.isEmpty)
            InkWell(
              onTap: _showAddPhotoModal,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
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
                      child: const Icon(Icons.cloud_upload_outlined, size: 26, color: Color(0xFF0284C7)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Unggah Foto Hotel (Maksimal 1 Foto)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ketuk untuk pilih dari kamera, galeri HP, atau masukkan URL foto',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            )
          else
            // Tampilan jika sudah ada 1 foto: Preview 16:9 + opsi Ganti & Hapus
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF00758F), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: HotelImageUploadService.instance.buildSafeImage(
                          _photoUrls.first,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Badge Foto Utama
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00758F).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Foto Utama ⭐',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showAddPhotoModal,
                        icon: const Icon(Icons.photo_camera_back_outlined, size: 15, color: Color(0xFF00758F)),
                        label: const Text(
                          'Ganti Foto',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF00758F)),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0F9FF),
                          side: const BorderSide(color: Color(0xFFBAE6FD)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _photoUrls.clear();
                          });
                        },
                        icon: const Icon(Icons.delete_outline, size: 15, color: Color(0xFFDC2626)),
                        label: const Text(
                          'Hapus Foto',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEF2F2),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Dialog modal pemilihan sumber foto (Kamera, Galeri, atau URL)
  /// Karena hanya boleh 1 foto, foto baru akan langsung menggantikan foto sebelumnya.
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
                  'Pilih Foto Hotel (1 Foto)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Opsi 1: Dari Kamera Fisik
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF007A94)),
              ),
              title: const Text('Ambil dari Kamera',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
              subtitle: const Text('Gunakan kamera perangkat untuk mengambil foto',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final picker = ImagePicker();
                  final picked =
                      await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                  if (picked != null) {
                    setState(() {
                      // Ganti foto yang ada dengan 1 foto baru
                      _photoUrls = [picked.path];
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto kamera berhasil dipilih!'),
                          backgroundColor: Color(0xFF16A34A),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  debugPrint('Picker error: $e');
                }
              },
            ),
            const Divider(height: 1),

            // Opsi 2: Dari Galeri Perangkat via ImagePicker
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library_outlined, color: Color(0xFF007A94)),
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
                      await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (picked != null) {
                    setState(() {
                      // Ganti foto yang ada dengan 1 foto baru
                      _photoUrls = [picked.path];
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto galeri berhasil dipilih!'),
                          backgroundColor: Color(0xFF16A34A),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  debugPrint('Picker error: $e');
                }
              },
            ),
            const Divider(height: 1),

            // Opsi 3: Input URL Foto
            const SizedBox(height: 8),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00758F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final url = urlCtrl.text.trim();
                  if (url.isNotEmpty) {
                    setState(() => _photoUrls = [url]);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Foto URL berhasil ditambahkan!'),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  }
                },
                child: const Text('Simpan URL Foto',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section D: Master Tipe Kamar (Bisa Tambah Banyak Tipe Kamar)
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
                      'Section D: Master Tipe Kamar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Setup tipe kamar, ranjang, dan skema tarif (dapat menambah lebih dari 1 tipe kamar)',
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
                  '${_roomTypes.length} Tipe\nKamar',
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

          // Render list of room types
          for (int i = 0; i < _roomTypes.length; i++) ...[
            _buildRoomTypeCard(i),
            if (i < _roomTypes.length - 1) const SizedBox(height: 14),
          ],

          const SizedBox(height: 14),

          // Tombol Tambah Tipe Kamar Lain
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _roomTypes.add(RoomTypeFormData());
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tipe Kamar #${_roomTypes.length} berhasil ditambahkan!'),
                    backgroundColor: const Color(0xFF00758F),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text(
                '+ Tambah Tipe Kamar Lain',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0F7FA),
                foregroundColor: const Color(0xFF006678),
                elevation: 0,
                side: const BorderSide(color: Color(0xFF0096B4), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTypeCard(int i) {
    final room = _roomTypes[i];
    final roomNumberStr = (i + 1).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card Kamar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00758F),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Tipe Kamar #$roomNumberStr',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (room.nameController.text.trim().isNotEmpty)
                    Text(
                      room.nameController.text.trim(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                ],
              ),
              if (_roomTypes.length > 1)
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Tipe Kamar?'),
                        content: Text('Apakah Anda yakin ingin menghapus Tipe Kamar #$roomNumberStr?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              setState(() {
                                final removed = _roomTypes.removeAt(i);
                                removed.dispose();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tipe kamar berhasil dihapus'),
                                  backgroundColor: Color(0xFFEF4444),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.delete_outline, size: 13, color: Color(0xFFDC2626)),
                        SizedBox(width: 3),
                        Text(
                          'Hapus',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Nama Tipe Kamar
          const Text(
            'Nama Tipe Kamar *',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          _buildInputBox(
            controller: room.nameController,
            hint: 'Contoh: Deluxe Ocean Panorama Suite',
          ),
          const SizedBox(height: 10),

          // Luas Kamar & Tipe Ranjang
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
                      controller: room.sizeController,
                      hint: '48',
                      suffixText: 'm²',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Tipe Ranjang Dropdown
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _bedTypeOptions.contains(room.selectedBedType)
                              ? room.selectedBedType
                              : _bedTypeOptions.first,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
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
                              setState(() => room.selectedBedType = val);
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
          const SizedBox(height: 10),

          // Kapasitas Tamu (+ / -)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kapasitas Tamu (Dewasa / Anak)',
                  style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (room.guestCapacity > 1) {
                          setState(() {
                            room.guestCapacity--;
                            room.capacityController.text = '${room.guestCapacity}';
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.remove, size: 15, color: Color(0xFF00758F)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: room.capacityController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          suffixText: 'Tamu',
                          suffixStyle: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), ''));
                          if (parsed != null && parsed > 0) {
                            room.guestCapacity = parsed;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          room.guestCapacity++;
                          room.capacityController.text = '${room.guestCapacity}';
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, size: 15, color: Color(0xFF00758F)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Alokasi Kuota & Skema Tarif
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
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
                          'Alokasi Kuota & Skema Tarif',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 85,
                      child: _buildInputBox(
                        controller: room.totalUnitController,
                        hint: '10',
                        suffixText: 'Unit',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Harga Weekday (Sen–Kam) *',
                    style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                _buildPriceInputBox(controller: room.weekdayPriceController),
                const SizedBox(height: 8),
                const Text('Harga Weekend (Jum–Min) *',
                    style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                _buildPriceInputBox(controller: room.weekendPriceController),
                const SizedBox(height: 8),
                const Text('Biaya Tambahan Extra Bed',
                    style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                _buildPriceInputBox(controller: room.extraBedController),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Fasilitas Kamar Eksklusif (Bisa dilist sendiri secara dinamis)
          const Text(
            'Fasilitas Kamar Eksklusif Terpasang',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ketik fasilitas kamar (misal: Bathtub, Balkon, Smart TV) lalu tekan Tambah',
            style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: room.amenityInputController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      final val = room.amenityInputController.text.trim();
                      if (val.isNotEmpty && !room.roomAmenities.contains(val)) {
                        setState(() => room.roomAmenities.add(val));
                        room.amenityInputController.clear();
                      }
                    },
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ketik fasilitas kamar baru...',
                      hintStyle: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0096B4), width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final val = room.amenityInputController.text.trim();
                    if (val.isNotEmpty && !room.roomAmenities.contains(val)) {
                      setState(() => room.roomAmenities.add(val));
                      room.amenityInputController.clear();
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                  label: const Text(
                    'Tambah',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00758F),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Daftar fasilitas kamar dalam bentuk Chips yang bisa dihapus
          if (room.roomAmenities.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Belum ada fasilitas kamar. Masukkan fasilitas kamar di atas.',
                style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: room.roomAmenities.map((amenity) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF16A34A)),
                      const SizedBox(width: 5),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          amenity,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () {
                          setState(() {
                            room.roomAmenities.remove(amenity);
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.close_rounded, size: 13, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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

    // Validasi kamar terisi di Section D
    final validRooms = _roomTypes
        .where((r) => r.nameController.text.trim().isNotEmpty)
        .toList();
    if (!_isEditMode && validRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi minimal 1 tipe kamar di Section D!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
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

      // Fasilitas kustom hotel dari Section B
      final activeFacilities = List<String>.from(_facilities);

      final lat = double.tryParse(_latitudeController.text.trim());
      final long = double.tryParse(_longitudeController.text.trim());

      // Unggah foto lokal ke Supabase Storage (hanya 1 foto sesuai ketentuan)
      final List<String> finalPhotoUrls = [];
      for (final p in _photoUrls.take(1)) {
        if (_isLocalFile(p)) {
          final file = File(p.replaceFirst('file://', ''));
          if (file.existsSync()) {
            final uploaded = await HotelImageUploadService.instance.uploadFile(
              file,
              prefix: 'hotel_galeri',
            );
            if (uploaded != null && uploaded.isNotEmpty) {
              finalPhotoUrls.add(uploaded);
              continue;
            }
          }
        }
        finalPhotoUrls.add(p);
      }
      final mainImage = finalPhotoUrls.isNotEmpty ? finalPhotoUrls.first : null;

      // Siapkan payload seluruh tipe kamar di Section D
      final List<Map<String, dynamic>> roomTypesPayload = [];
      for (final room in validRooms) {
        final rName = room.nameController.text.trim();
        final wPrice =
            ThousandsSeparatorInputFormatter.parse(room.weekdayPriceController.text);
        final ePrice =
            ThousandsSeparatorInputFormatter.parse(room.weekendPriceController.text);
        final size = double.tryParse(
                room.sizeController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ??
            30.0;
        final totalU = int.tryParse(
                room.totalUnitController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            10;
        // Fasilitas kustom tipe kamar dari Section D
        final activeRoomAmenities = List<String>.from(room.roomAmenities);

        roomTypesPayload.add({
          'name': rName,
          'capacity': room.guestCapacity,
          'sizeM2': size,
          'bedType': room.selectedBedType,
          'weekdayPrice': wPrice > 0 ? wPrice : 500000.0,
          'weekendPrice':
              ePrice > 0 ? ePrice : (wPrice > 0 ? wPrice * 1.2 : 600000.0),
          'totalUnit': totalU > 0 ? totalU : 10,
          'amenities': activeRoomAmenities,
        });
      }

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
          imageUrls: finalPhotoUrls,
          facilities: activeFacilities,
          ptName: _ptNameController.text.trim(),
          npwp: _npwpController.text.trim(),
          nib: _nibController.text.trim(),
        );

        // Update/insert kamar baru jika diedit
        final parsedHotelId = int.tryParse(hotelId) ?? 0;
        if (parsedHotelId > 0 && roomTypesPayload.isNotEmpty) {
          final svcKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
              ? SupabaseConfig.supabaseServiceRoleKey
              : SupabaseConfig.activeApiKey;
          for (int i = 0; i < roomTypesPayload.length; i++) {
            final r = roomTypesPayload[i];
            final rName = r['name'] as String;
            final uniqueRoomTypeId =
                '${parsedHotelId}_${i + 1}_${DateTime.now().millisecondsSinceEpoch % 100000}';
            final activeRoomAmenities =
                (r['amenities'] as List<String>).join(', ');
            try {
              final uri = Uri.parse(
                  '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableTipeKamar}');
              await http.post(uri, headers: {
                'apikey': svcKey,
                'Authorization': 'Bearer $svcKey',
                'Content-Type': 'application/json',
                'Prefer': 'return=minimal',
              }, body: jsonEncode({
                'id_tipe_kamar': uniqueRoomTypeId,
                'id_penginapan': parsedHotelId,
                'nama_tipe': rName,
                'kapasitas_tamu': r['capacity'],
                'luas_m2': r['sizeM2'],
                'tipe_bed': r['bedType'],
                'harga_dasar': r['weekdayPrice'],
                'harga_weekend': r['weekendPrice'],
                'total_unit': r['totalUnit'],
                'fasilitas_kamar': activeRoomAmenities,
              }));
            } catch (_) {}
          }
        }

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
        final firstRoom =
            roomTypesPayload.isNotEmpty ? roomTypesPayload.first : null;
        final createdHotel = await HotelService.instance.createHotel(
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
          imageUrls: finalPhotoUrls,
          roomTypes: roomTypesPayload,
          roomName: firstRoom != null ? firstRoom['name'] as String : null,
          roomCapacity:
              firstRoom != null ? firstRoom['capacity'] as int : null,
          roomSizeM2:
              firstRoom != null ? firstRoom['sizeM2'] as double : null,
          bedType: firstRoom != null ? firstRoom['bedType'] as String : null,
          weekdayPrice:
              firstRoom != null ? firstRoom['weekdayPrice'] as double : null,
          weekendPrice:
              firstRoom != null ? firstRoom['weekendPrice'] as double : null,
          roomAmenities:
              firstRoom != null ? firstRoom['amenities'] as List<String> : null,
        );

        if (!mounted) return;
        setState(() => _isSubmitting = false);

        // Jika akun administrator hotel berhasil digenerate otomatis, tampilkan kredensialnya
        if (createdHotel.generatedAdminEmail != null &&
            createdHotel.generatedAdminPassword != null) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hotel & Akun Admin Berhasil Dibuat',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kredensial login administrator hotel untuk portal pihak hotel:',
                    style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      children: [
                        _buildAdminCredentialItem('Email Admin', createdHotel.generatedAdminEmail!),
                        const Divider(height: 14, color: Color(0xFFDCFCE7)),
                        _buildAdminCredentialItem('Password', createdHotel.generatedAdminPassword!),
                        const Divider(height: 14, color: Color(0xFFDCFCE7)),
                        _buildAdminCredentialItem('ID Petugas', createdHotel.generatedAdminStaffId ?? '-'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Simpan atau salin kredensial di atas untuk diserahkan kepada pihak mitra hotel.',
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              actions: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 14, color: Colors.white),
                  label: const Text('Salin Kredensial',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00758F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final cText = 'Email: ${createdHotel.generatedAdminEmail}\nPassword: ${createdHotel.generatedAdminPassword}\nID Petugas: ${createdHotel.generatedAdminStaffId}';
                    Clipboard.setData(ClipboardData(text: cText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kredensial akun admin berhasil disalin ke clipboard!'),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Selesai',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Berhasil! Mitra hotel baru dengan ${roomTypesPayload.length} tipe kamar berhasil disimpan ke database.'),
              backgroundColor: const Color(0xFF00758F),
            ),
          );
        }

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

  Widget _buildAdminCredentialItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        ),
        SelectableText(
          value,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        ),
      ],
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
