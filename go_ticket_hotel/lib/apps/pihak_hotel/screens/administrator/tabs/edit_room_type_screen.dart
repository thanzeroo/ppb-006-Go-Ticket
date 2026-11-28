import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/config/supabase_config.dart';
import '../../../../../../core/services/supabase_service.dart';
import '../../../services/hotel_image_upload_service.dart';
import 'add_room_type_screen.dart';

/// Halaman penyuntingan spesifikasi, kuota unit, tarif, dan foto tipe kamar yang sudah ada.
class EditRoomTypeScreen extends StatefulWidget {
  final String? roomId;
  final String roomName;
  final String category;
  final String? initialImageUrl;

  const EditRoomTypeScreen({
    super.key,
    this.roomId,
    this.roomName = 'Standar Twin Suite',
    this.category = 'Suite Mewah (Luxury Suite)',
    this.initialImageUrl,
  });

  @override
  State<EditRoomTypeScreen> createState() => _EditRoomTypeScreenState();
}

class _EditRoomTypeScreenState extends State<EditRoomTypeScreen> {
  static const Color _teal = Color(0xFF005E73);
  static const Color _bg = Color(0xFFF6F8FB);
  static const Color _cardBorder = Color(0xFFE5E9F0);

  int _selectedTab = 0; // 0: Spesifikasi & Kapasitas, 1: Tarif & Kuota
  bool _isLive = true;
  bool _extraBed = true;
  bool _surgePricing = true;
  int _cancellationPolicy = 0; // 0: Fleksibel H-2, 1: Non-Refundable
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _weekdayPriceController;
  late TextEditingController _weekendPriceController;
  late TextEditingController _depositController;
  String _selectedCategory = 'Suite Mewah (Luxury Suite)';

  final ImagePicker _picker = ImagePicker();
  final List<RoomPhotoItem> _galleryPhotos = [];

  final List<String> _categories = [
    'Suite Room',
    'Suite Mewah (Luxury Suite)',
    'Deluxe Series',
    'Deluxe Room (Executive)',
    'Standard Twin Room',
    'Villa Signature',
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

    if (!_categories.contains(widget.category)) {
      _categories.insert(0, widget.category);
    }
    _selectedCategory = widget.category;
    _selectedFacilities = Set.from(_facilities);

    // Initial default photos
    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      _galleryPhotos.add(RoomPhotoItem(url: widget.initialImageUrl!, label: 'Cover Utama'));
    } else {
      _galleryPhotos.add(RoomPhotoItem(
        url: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&auto=format&fit=crop',
        label: 'Cover Utama',
      ));
    }
    _galleryPhotos.add(RoomPhotoItem(
      url: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&auto=format&fit=crop',
      label: 'Kamar Mandi',
    ));
    _galleryPhotos.add(RoomPhotoItem(
      url: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=400&auto=format&fit=crop',
      label: 'Balkon',
    ));

    _fetchRoomDataFromSupabase();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weekdayPriceController.dispose();
    _weekendPriceController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  Future<void> _fetchRoomDataFromSupabase() async {
    final sb = SupabaseService.instance;
    if (!sb.isReady) return;
    try {
      Map<String, dynamic>? data;
      if (widget.roomId != null && widget.roomId!.isNotEmpty) {
        final res = await sb.table(SupabaseConfig.tableTipeKamar)?.select().eq('id_tipe_kamar', widget.roomId!).maybeSingle();
        if (res != null) data = Map<String, dynamic>.from(res);
      } else {
        final res = await sb.table(SupabaseConfig.tableTipeKamar)?.select().eq('nama_tipe', widget.roomName).maybeSingle();
        if (res != null) data = Map<String, dynamic>.from(res);
      }

      if (data != null && mounted) {
        setState(() {
          if (data!['nama_tipe'] != null) {
            _nameController.text = data['nama_tipe'].toString();
          }
          if (data['harga_dasar'] != null) {
            final hg = (data['harga_dasar'] as num).toInt();
            _weekdayPriceController.text = 'Rp ${_formatRupiah(hg)}';
          }
          if (data['harga_weekend'] != null) {
            final hg = (data['harga_weekend'] as num).toInt();
            _weekendPriceController.text = 'Rp ${_formatRupiah(hg)}';
          }
          final mainImg = data['main_image_url'] ?? data['image'];
          if (mainImg != null && mainImg.toString().isNotEmpty) {
            _galleryPhotos.removeWhere((p) => p.label == 'Cover Utama');
            _galleryPhotos.insert(0, RoomPhotoItem(url: mainImg.toString(), label: 'Cover Utama'));
          }
          final dynamic extraImgs = data['image_urls'] ?? data['photo_urls'];
          if (extraImgs is List && extraImgs.isNotEmpty) {
            for (final u in extraImgs) {
              final urlStr = u.toString();
              if (urlStr.isNotEmpty && !_galleryPhotos.any((p) => p.displayPath == urlStr)) {
                _galleryPhotos.add(RoomPhotoItem(url: urlStr, label: 'Foto Kamar #${_galleryPhotos.length + 1}'));
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint('ℹ️ [EditRoomTypeScreen] Info fetch room data: $e');
    }
  }

  String _formatRupiah(int val) {
    final s = val.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  /// Buka kamera atau galeri untuk tambah foto kamar resolusi tinggi
  Future<void> _pickGalleryImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto kamar berhasil ditambahkan dari perangkat lokal!'),
              backgroundColor: Color(0xFF007A87),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil foto: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  void _showAddPhotoUrlDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah URL Foto Kamar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://images.unsplash.com/...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                setState(() {
                  final count = _galleryPhotos.length + 1;
                  _galleryPhotos.add(
                    RoomPhotoItem(
                      url: url,
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

  void _setAsCover(int index) {
    if (index == 0 || index >= _galleryPhotos.length) return;
    setState(() {
      final selected = _galleryPhotos.removeAt(index);
      selected.label = 'Cover Utama';
      _galleryPhotos.insert(0, selected);
      for (int i = 1; i < _galleryPhotos.length; i++) {
        _galleryPhotos[i].label = 'Foto Kamar #${i + 1}';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto berhasil dijadikan Cover Utama kamar!'),
        backgroundColor: Color(0xFF007A87),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removePhoto(int index) {
    if (index < 0 || index >= _galleryPhotos.length) return;
    setState(() {
      _galleryPhotos.removeAt(index);
      if (_galleryPhotos.isNotEmpty) {
        _galleryPhotos[0].label = 'Cover Utama';
        for (int i = 1; i < _galleryPhotos.length; i++) {
          _galleryPhotos[i].label = 'Foto Kamar #${i + 1}';
        }
      }
    });
  }

  Future<void> _submitUpdateRoom() async {
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
      final rawWeekday =
          _weekdayPriceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final rawWeekend =
          _weekendPriceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final weekdayPrice = double.tryParse(rawWeekday) ?? 500000.0;
      final weekendPrice =
          double.tryParse(rawWeekend) ?? (weekdayPrice * 1.15);

      // Upload local photo files to Supabase Storage if any
      for (int i = 0; i < _galleryPhotos.length; i++) {
        final item = _galleryPhotos[i];
        if (item.file != null && (item.url == null || item.url!.isEmpty)) {
          final uploadedUrl = await HotelImageUploadService.instance.uploadFile(
            item.file!,
            prefix: 'room_type_${widget.roomId ?? "room"}',
          );
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            _galleryPhotos[i] = RoomPhotoItem(
              url: uploadedUrl,
              file: item.file,
              label: item.label,
            );
          }
        }
      }

      final coverUrl = _galleryPhotos.isNotEmpty ? _galleryPhotos.first.displayPath : null;
      final allUrls = _galleryPhotos.map((p) => p.displayPath).where((u) => u.isNotEmpty).toList();

      final sb = SupabaseService.instance;
      if (sb.isReady) {
        final Map<String, dynamic> updateData = {
          'nama_tipe': name,
          'harga_dasar': weekdayPrice,
          'harga_weekend': weekendPrice,
        };
        if (coverUrl != null && coverUrl.isNotEmpty) {
          updateData['main_image_url'] = coverUrl;
          updateData['image'] = coverUrl;
        }
        if (allUrls.isNotEmpty) {
          updateData['image_urls'] = allUrls;
        }

        if (widget.roomId != null && widget.roomId!.isNotEmpty) {
          await sb.table(SupabaseConfig.tableTipeKamar)?.update(updateData).eq('id_tipe_kamar', widget.roomId!);
        } else {
          await sb.table(SupabaseConfig.tableTipeKamar)?.update(updateData).eq('nama_tipe', widget.roomName);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan tipe kamar & foto berhasil disimpan ke database!'),
          backgroundColor: Color(0xFF007A87),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan perubahan: $e'),
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
              'Edit Tipe Kamar',
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
                value: _categories.contains(_selectedCategory)
                    ? _selectedCategory
                    : _categories.first,
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
        child: Text('${_galleryPhotos.length} Foto',
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Unggah Foto
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE6FAFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF00D1FF).withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_upload_outlined,
                    size: 32, color: Color(0xFF005E73)),
                const SizedBox(height: 6),
                const Text(
                  'Unggah / Ganti Foto Kamar Resolusi Tinggi',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Pilih foto dari kamera ponsel, galeri file lokal, atau tautan URL.',
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickGalleryImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, size: 14),
                      label: const Text('Kamera',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007A87),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickGalleryImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, size: 14),
                      label: const Text('Galeri HP',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C2FF),
                        foregroundColor: const Color(0xFF003847),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _showAddPhotoUrlDialog,
                      icon: const Icon(Icons.link, size: 14),
                      label: const Text('URL Link',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF007A87)),
                        foregroundColor: const Color(0xFF007A87),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tampilan Foto Kamar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Foto Kamar (Cover di posisi paling kiri):',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569)),
              ),
              if (_galleryPhotos.isNotEmpty)
                Text(
                  '${_galleryPhotos.length} item',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (_galleryPhotos.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _cardBorder),
              ),
              child: const Center(
                child: Text(
                  'Belum ada foto kamar. Silakan tambah foto di atas.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _galleryPhotos.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  final photo = _galleryPhotos[i];
                  final isCover = i == 0;

                  return Stack(
                    children: [
                      Container(
                        width: 135,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCover
                                ? const Color(0xFF00C2FF)
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: HotelImageUploadService.instance.buildSafeImage(
                            photo.displayPath,
                            width: 135,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.75),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Label / Cover badge
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCover
                                ? const Color(0xFF007A87)
                                : Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isCover ? 'Cover Utama' : photo.label,
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),

                      // Set As Cover Button (jika bukan cover)
                      if (!isCover)
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: GestureDetector(
                            onTap: () => _setAsCover(i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C2FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Jadikan Cover',
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF003847)),
                              ),
                            ),
                          ),
                        ),

                      // Tombol Hapus Foto
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _removePhoto(i),
                          child: const CircleAvatar(
                            radius: 11,
                            backgroundColor: Colors.black54,
                            child:
                                Icon(Icons.close, size: 12, color: Colors.white),
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
            onPressed: _isSaving ? null : _submitUpdateRoom,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, size: 16),
            label: Text(
              _isSaving ? 'Menyimpan...' : 'Simpan Perubahan Kamar',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007A87),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
