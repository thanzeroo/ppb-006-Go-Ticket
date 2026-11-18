import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/models/room_model.dart';
import '../../../../../../core/services/auth_service.dart';
import '../../../../../../core/services/hotel_service.dart';

/// Item foto di galeri kamar (bisa berasal dari file lokal kamera/galeri atau URL internet)
class RoomPhotoItem {
  final File? file;
  final String? url;
  String label;

  RoomPhotoItem({this.file, this.url, required this.label});

  String get displayPath => url ?? file?.path ?? '';
}

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
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _weekdayPriceController;
  late TextEditingController _weekendPriceController;
  late TextEditingController _depositController;
  String _selectedCategory = 'Suite Mewah (Luxury Suite)';

  // Controllers untuk Alokasi Kuota, Jumlah Lantai, dan Nomor Kamar
  late TextEditingController _unitCountController;
  late TextEditingController _floorCountController;
  int _unitCount = 10;
  int _floorCount = 2;

  // 0: Otomatis dari 001, dst | 1: Otomatis per Lantai (101, 201..) | 2: Manual 1 per 1
  int _numberingMode = 0;
  List<String> _roomNumbers = [];

  // Galeri Foto Resolusi Tinggi
  final ImagePicker _picker = ImagePicker();
  final List<RoomPhotoItem> _galleryPhotos = [];

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _weekdayPriceController = TextEditingController(text: '750.000');
    _weekendPriceController = TextEditingController(text: '850.000');
    _depositController = TextEditingController(text: '200.000');
    _selectedFacilities = Set.from(_facilities);

    _unitCountController = TextEditingController(text: '$_unitCount');
    _floorCountController = TextEditingController(text: '$_floorCount');

    // Inisialisasi nomor kamar awal
    _generateRoomNumbers();

    // Inisialisasi sampel galeri foto resolusi tinggi
    _galleryPhotos.addAll([
      RoomPhotoItem(
        url: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&auto=format&fit=crop',
        label: 'Cover Utama',
      ),
      RoomPhotoItem(
        url: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&auto=format&fit=crop',
        label: 'Kamar Mandi',
      ),
      RoomPhotoItem(
        url: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=400&auto=format&fit=crop',
        label: 'Balkon / Teras',
      ),
    ]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weekdayPriceController.dispose();
    _weekendPriceController.dispose();
    _depositController.dispose();
    _unitCountController.dispose();
    _floorCountController.dispose();
    super.dispose();
  }

  /// Generator nomor kamar dinamis sesuai pilihan mode:
  /// Mode 0: Otomatis dari 001, 002, 003, dst.
  /// Mode 1: Otomatis Berdasarkan Lantai (Lantai 1: 101, 102..; Lantai 2: 201, 202..)
  /// Mode 2: Input manual 1 per 1
  void _generateRoomNumbers() {
    if (_numberingMode == 2) return; // Mode manual tidak di-overwrite

    final List<String> list = [];
    if (_numberingMode == 0) {
      // 001, 002, 003, dst
      for (int i = 1; i <= _unitCount; i++) {
        list.add(i.toString().padLeft(3, '0'));
      }
    } else if (_numberingMode == 1) {
      // Sesuai pembagian lantai
      final floors = _floorCount > 0 ? _floorCount : 1;
      final unitsPerFloor = (_unitCount / floors).ceil();
      int currentUnit = 0;

      for (int fl = 1; fl <= floors; fl++) {
        for (int u = 1; u <= unitsPerFloor && currentUnit < _unitCount; u++) {
          final roomNum = '$fl${u.toString().padLeft(2, '0')}';
          list.add(roomNum);
          currentUnit++;
        }
      }
    }

    setState(() {
      _roomNumbers = list;
    });
  }

  void _updateUnitCount(int delta) {
    int val = _unitCount + delta;
    if (val < 1) val = 1;
    if (val > 200) val = 200;
    setState(() {
      _unitCount = val;
      _unitCountController.text = '$val';
      _generateRoomNumbers();
    });
  }

  void _updateFloorCount(int delta) {
    int val = _floorCount + delta;
    if (val < 1) val = 1;
    if (val > 50) val = 50;
    setState(() {
      _floorCount = val;
      _floorCountController.text = '$val';
      _generateRoomNumbers();
    });
  }

  /// Tambah nomor kamar manual 1 per 1
  void _showAddManualRoomDialog() {
    final controller = TextEditingController(
      text: '${_roomNumbers.length + 1}'.padLeft(3, '0'),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Nomor Kamar Manual', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Contoh: 101, 204A, Penthouse-1',
            labelText: 'Nomor Kamar Fisik',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _roomNumbers.add(text);
                  _unitCount = _roomNumbers.length;
                  _unitCountController.text = '$_unitCount';
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007A87)),
            child: const Text('Tambah', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Edit nomor kamar yang sudah ada
  void _editRoomNumberDialog(int index) {
    final controller = TextEditingController(text: _roomNumbers[index]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Nomor Kamar #${_roomNumbers[index]}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nomor Kamar Baru'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _roomNumbers.removeAt(index);
                _unitCount = _roomNumbers.length;
                _unitCountController.text = '$_unitCount';
              });
              Navigator.pop(ctx);
            },
            child: const Text('Hapus Kamar', style: TextStyle(color: Color(0xFFDC2626))),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _roomNumbers[index] = text;
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007A87)),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Buka kamera atau galeri untuk tambah foto kamar resolusi tinggi
  Future<void> _pickGalleryImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (file != null) {
        setState(() {
          final count = _galleryPhotos.length + 1;
          _galleryPhotos.add(
            RoomPhotoItem(
              file: File(file.path),
              label: count == 1 ? 'Cover Utama' : 'Foto Kamar #$count',
            ),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e'), backgroundColor: const Color(0xFFEF4444)),
      );
    }
  }

  /// Tambah foto kamar via URL web
  void _showAddPhotoUrlDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah URL Foto Resolusi Tinggi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://images.unsplash.com/...',
            labelText: 'URL Gambar',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  final count = _galleryPhotos.length + 1;
                  _galleryPhotos.add(
                    RoomPhotoItem(
                      url: text,
                      label: count == 1 ? 'Cover Utama' : 'Foto Kamar #$count',
                    ),
                  );
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007A87)),
            child: const Text('Tambah', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRoom() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tipe kamar wajib diisi'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final hotelId = AuthService.instance.currentUser?.managedHotelId ?? '1';
      final rawWeekday =
          _weekdayPriceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final rawWeekend =
          _weekendPriceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final weekdayPrice = double.tryParse(rawWeekday) ?? 500000.0;
      final weekendPrice =
          double.tryParse(rawWeekend) ?? (weekdayPrice * 1.15);

      final photosList = _galleryPhotos.map((p) => p.displayPath).where((s) => s.isNotEmpty).toList();
      final mainPhoto = photosList.isNotEmpty ? photosList.first : null;
      final roomNo = _roomNumbers.isNotEmpty ? _roomNumbers.first : '101';

      final newRoom = RoomModel(
        id: '',
        hotelId: hotelId,
        roomNumber: roomNo,
        typeName: name,
        pricePerNight: weekdayPrice.round(),
        weekendPrice: weekendPrice.round(),
        maxGuests: 2,
        roomSizeM2: 28.0,
        bedType: 'King Bed',
        totalUnits: _unitCount > 0 ? _unitCount : 10,
        floorNumber: _floorCount,
        facilities: _selectedFacilities.toList(),
        mainImageUrl: mainPhoto,
        imageUrls: photosList,
      );

      await HotelService.instance.addRoom(newRoom);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tipe kamar "$name" ($roomNo, $_unitCount unit di $_floorCount lantai) berhasil diterbitkan!'),
          backgroundColor: const Color(0xFF007A87),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan tipe kamar: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTabSelector(),
            const SizedBox(height: 16),

            // Card 1: Informasi Dasar
            _buildBasicInfoCard(),
            const SizedBox(height: 16),

            // Card 2: Alokasi Kuota & Inventaris (Sesuai instruksi: Simpel, input unit -/+, lantai -/+, nomor kamar auto/manual)
            _buildQuotaInventoryCard(),
            const SizedBox(height: 16),

            // Card 3: Pengaturan Tarif & Pricing
            _buildPricingCard(),
            const SizedBox(height: 16),

            // Card 4: Fasilitas & Kenyamanan
            _buildFacilitiesCard(),
            const SizedBox(height: 16),

            // Card 5: Galeri Foto Resolusi Tinggi (Sesuai instruksi: Berfungsi dengan kamera/galeri)
            _buildPhotoGalleryCard(),
            const SizedBox(height: 16),

            // Card 6: Kebijakan & Deposit
            _buildPolicyDepositCard(),
            const SizedBox(height: 24),

            // Bottom Action
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _submitRoom,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.publish, size: 18),
              label: Text(
                _isSaving ? 'Menerbitkan...' : 'Terbitkan Tipe Kamar',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(0, 'Info & Kapasitas'),
          ),
          Expanded(
            child: _buildTabButton(1, 'Kuota & Tarif'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSel = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSel
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
            color: isSel ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildSectionContainer(
      icon: Icons.hotel_outlined,
      title: 'Informasi Dasar Kamar',
      subtitle: 'Nama kategori dan spesifikasi fisik',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Nama Tipe Kamar *'),
          _buildInput(
            controller: _nameController,
            hint: 'Contoh: Deluxe Ocean View Suite',
          ),
          const SizedBox(height: 12),
          _buildFieldLabel('Kategori Kamar'),
          _buildDropdown(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Luas Kamar (m²)'),
                    _buildInput(
                      hint: '36',
                      prefixText: '',
                      suffixText: 'm²',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Tipe Ranjang'),
                    _buildBedDropdown(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// -------------------------------------------------------------------------
  /// CARD ALOKASI KUOTA & INVENTARIS
  /// Sesuai instruksi:
  /// - Total input berapa unit dengan -()+ atau ketik manual
  /// - Input berapa lantai dengan -()+ atau ketik manual
  /// - Nomor kamar bisa otomatis dari 001, dst atau manual 1 per 1
  /// -------------------------------------------------------------------------
  Widget _buildQuotaInventoryCard() {
    return _buildSectionContainer(
      icon: Icons.layers_outlined,
      title: 'Alokasi Kuota & Inventaris',
      subtitle: 'Kelola lantai, jumlah unit, dan nomor kamar fisik',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. INPUT BERAPA LANTAI HOTEL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Jumlah Lantai / Loteng',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text('Kamar tersebar di berapa lantai?', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () => _updateFloorCount(-1),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    SizedBox(
                      width: 44,
                      child: TextField(
                        controller: _floorCountController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        onSubmitted: (val) {
                          final parsed = int.tryParse(val) ?? 1;
                          _updateFloorCount(parsed - _floorCount);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => _updateFloorCount(1),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. INPUT TOTAL UNIT KAMAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Total Unit Kamar *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text('Berapa unit tipe kamar ini tersedia?', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () => _updateUnitCount(-1),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    SizedBox(
                      width: 44,
                      child: TextField(
                        controller: _unitCountController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        onSubmitted: (val) {
                          final parsed = int.tryParse(val) ?? 1;
                          _updateUnitCount(parsed - _unitCount);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => _updateUnitCount(1),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. PILIHAN MODE PENOMORAN KAMAR
          const Text(
            'Format Nomor Kamar',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildNumberingModeChip('Otomatis (001, dst)', 0),
              const SizedBox(width: 6),
              _buildNumberingModeChip('Per Lantai (101, 201)', 1),
              const SizedBox(width: 6),
              _buildNumberingModeChip('Manual 1 per 1', 2),
            ],
          ),
          const SizedBox(height: 14),

          // Summary Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: $_unitCount Unit di $_floorCount Lantai',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00758F)),
                ),
                Text(
                  '${_roomNumbers.length} nomor aktif',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // DAFTAR CHIPS NOMOR KAMAR FISIK
          const Text(
            'Daftar Nomor Kamar (Ketuk nomor untuk ubah/hapus):',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (int i = 0; i < _roomNumbers.length; i++)
                InkWell(
                  onTap: () => _editRoomNumberDialog(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#${_roomNumbers[i]}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit, size: 10, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Tombol + Tambah Nomor Kamar Manual
          OutlinedButton.icon(
            onPressed: _showAddManualRoomDialog,
            icon: const Icon(Icons.add, size: 15, color: Color(0xFF007A87)),
            label: const Text('Tambah No. Kamar Manual', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF007A87))),
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

  Widget _buildNumberingModeChip(String label, int mode) {
    final isSel = _numberingMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _numberingMode = mode;
            _generateRoomNumbers();
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF007A87) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSel ? const Color(0xFF007A87) : const Color(0xFFCBD5E1)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSel ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  /// -------------------------------------------------------------------------
  /// CARD GALERI FOTO RESOLUSI TINGGI
  /// Sesuai instruksi:
  /// - Berfungsi upload foto via kamera atau galeri
  /// - Menampilkan thumbnail dengan aksi cover & delete
  /// -------------------------------------------------------------------------
  Widget _buildPhotoGalleryCard() {
    return _buildSectionContainer(
      icon: Icons.photo_camera_back_outlined,
      title: 'Galeri Foto Resolusi Tinggi',
      subtitle: 'Upload foto kamar via kamera atau berkas galeri',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Upload Area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6FAFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00D1FF).withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 30, color: Color(0xFF005E73)),
                const SizedBox(height: 6),
                const Text(
                  'Unggah Foto Kamar Beresolusi Tinggi',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Telah terunggah ${_galleryPhotos.length} foto kamar.',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickGalleryImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, size: 14),
                      label: const Text('Kamera', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007A87),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _pickGalleryImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, size: 14),
                      label: const Text('Galeri HP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C2FF),
                        foregroundColor: const Color(0xFF003847),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _showAddPhotoUrlDialog,
                      icon: const Icon(Icons.link, size: 14),
                      label: const Text('URL Link', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF007A87)),
                        foregroundColor: const Color(0xFF007A87),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tampilan Foto yang Sudah Ada di Galeri
          const Text(
            'Pratinjau Foto Kamar (Foto pertama akan menjadi cover):',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _galleryPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final photo = _galleryPhotos[i];
                final isCover = i == 0;

                return Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCover ? const Color(0xFF00C2FF) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: photo.url != null
                            ? Image.network(
                                photo.url!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.white38),
                                ),
                              )
                            : Image.file(
                                photo.file!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),

                    // Label Cover
                    if (isCover)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007A87),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Cover', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),

                    // Tombol Hapus Foto
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _galleryPhotos.removeAt(i);
                          });
                        },
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return _buildSectionContainer(
      icon: Icons.monetization_on_outlined,
      title: 'Pengaturan Tarif & Dynamic Pricing',
      subtitle: 'Strategi harga hari kerja dan akhir pekan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Tarif Weekday (Sen-Kam) *'),
                    _buildInput(
                      controller: _weekdayPriceController,
                      prefixText: 'Rp ',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Tarif Weekend (Jum-Min) *'),
                    _buildInput(
                      controller: _weekendPriceController,
                      prefixText: 'Rp ',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Dynamic Pricing AI Go Ticket', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  Text('Auto-surge saat peak season liburan', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
              Switch(
                value: _surgePricing,
                onChanged: (val) => setState(() => _surgePricing = val),
                activeColor: const Color(0xFF007A87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesCard() {
    return _buildSectionContainer(
      icon: Icons.room_service_outlined,
      title: 'Fasilitas & Layanan Kamar',
      subtitle: 'Pilih kenyamanan yang tersedia di tipe ini',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _facilities.map((f) {
          final isSel = _selectedFacilities.contains(f);
          return FilterChip(
            label: Text(f),
            selected: isSel,
            selectedColor: const Color(0xFFE0F4FB),
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
              color: isSel ? const Color(0xFF007A87) : const Color(0xFF475569),
            ),
            checkmarkColor: const Color(0xFF007A87),
            onSelected: (val) {
              setState(() {
                if (val) {
                  _selectedFacilities.add(f);
                } else {
                  _selectedFacilities.remove(f);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPolicyDepositCard() {
    return _buildSectionContainer(
      icon: Icons.policy_outlined,
      title: 'Kebijakan Reservasi & Deposit',
      subtitle: 'Ketentuan pembatalan dan jaminan check-in',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Deposit Jaminan Check-in (Rp)'),
          _buildInput(
            controller: _depositController,
            prefixText: 'Rp ',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildFieldLabel('Kebijakan Pembatalan'),
          DropdownButtonFormField<int>(
            value: _cancellationPolicy,
            items: const [
              DropdownMenuItem(value: 0, child: Text('Gratis Batal s/d H-1 Check-in')),
              DropdownMenuItem(value: 1, child: Text('Non-Refundable (Tidak Dapat Dibatalkan)')),
              DropdownMenuItem(value: 2, child: Text('Biaya 50% jika batal di bawah H-3')),
            ],
            onChanged: (val) => setState(() => _cancellationPolicy = val ?? 0),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFD),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F4FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF007A87), size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
      ),
    );
  }

  Widget _buildInput({
    TextEditingController? controller,
    String? hint,
    String? prefixText,
    String? suffixText,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        suffixText: suffixText,
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12.5)))).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val ?? _selectedCategory),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildBedDropdown() {
    return DropdownButtonFormField<String>(
      value: '1 King Bed',
      items: const [
        DropdownMenuItem(value: '1 King Bed', child: Text('1 King Bed (200x200)', style: TextStyle(fontSize: 12))),
        DropdownMenuItem(value: '2 Twin Bed', child: Text('2 Twin Bed (100x200)', style: TextStyle(fontSize: 12))),
        DropdownMenuItem(value: '1 Queen Bed', child: Text('1 Queen Bed (160x200)', style: TextStyle(fontSize: 12))),
      ],
      onChanged: (_) {},
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
