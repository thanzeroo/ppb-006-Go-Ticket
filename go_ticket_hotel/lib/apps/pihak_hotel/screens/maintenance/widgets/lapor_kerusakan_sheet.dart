// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/models/maintenance_ticket_model.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/maintenance_service.dart';
import '../../../services/hotel_image_upload_service.dart';
import '../../../services/hotel_operations_store.dart';

/// Modal Bottom Sheet: Lapor Kerusakan Fasilitas Kamar Hotel
/// Sesuai instruksi:
/// 1. Flow simpel namun jelas: terjadi kerusakan di lantai berapa kamar apa.
/// 2. Input foto/gambar bukti kerusakan (kamera/galeri via ImagePicker).
/// 3. Time log submit otomatis tercatat saat dikirimkan.
void showLaporKerusakanModal(BuildContext context, {VoidCallback? onTicketCreated}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return LaporKerusakanModalContent(onTicketCreated: onTicketCreated);
    },
  );
}

/// Konten bottom sheet pelaporan kerusakan fasilitas kamar lengkap dengan unggah foto bukti.
class LaporKerusakanModalContent extends StatefulWidget {
  final VoidCallback? onTicketCreated;

  const LaporKerusakanModalContent({super.key, this.onTicketCreated});

  @override
  State<LaporKerusakanModalContent> createState() =>
      _LaporKerusakanModalContentState();
}

class _LaporKerusakanModalContentState extends State<LaporKerusakanModalContent> {
  int _selectedFloor = 2; // Default Lantai 2
  final _roomController = TextEditingController(text: '204');
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = TicketCategory.ac;
  MaintenancePriority _priority = MaintenancePriority.medium;

  File? _damagePhoto;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  final List<String> _categories = [
    TicketCategory.ac,
    TicketCategory.electrical,
    TicketCategory.plumbing,
    TicketCategory.repair,
    'Furnitur & Pintu',
  ];

  @override
  void dispose() {
    _roomController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (file != null) {
        setState(() {
          _damagePhoto = File(file.path);
        });
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: \$e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _submitReport() async {
    final title = _titleController.text.trim();
    final room = _roomController.text.trim();
    if (room.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor kamar wajib diisi'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul / jenis kerusakan wajib diisi'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final submitTime = DateTime.now(); // Auto Time-Log saat submit

    try {
      final user = AuthService.instance.currentUser;
      final hotelId = user?.managedHotelId ?? '1';

      final roomStr = 'Kamar $room (Lt. $_selectedFloor)';

      // 1. Upload foto bukti kerusakan ke Supabase Storage (agar bisa dilihat di komputer lain)
      List<String> photoUrls = [];
      if (_damagePhoto != null && _damagePhoto!.existsSync()) {
        try {
          final uploadedUrl = await HotelImageUploadService.instance.uploadFile(
            _damagePhoto!,
            prefix: 'damage_lt${_selectedFloor}_kmr$room',
          );
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            photoUrls.add(uploadedUrl);
          } else {
            photoUrls.add(_damagePhoto!.path);
          }
        } catch (_) {
          photoUrls.add(_damagePhoto!.path);
        }
      }

      final ticket = MaintenanceTicketModel(
        id: 'TKT-${submitTime.millisecondsSinceEpoch}',
        hotelId: hotelId,
        roomId: room,
        roomNumber: roomStr,
        title: title,
        description: _descController.text.trim(),
        priority: _priority,
        status: MaintenanceStatus.open,
        category: _selectedCategory,
        reportedById: (user != null && user.id.isNotEmpty) ? user.id : 'MT-2025-001',
        reportedByName: user?.fullName ?? 'Petugas Maintenance',
        damagePhotoUrls: photoUrls,
        createdAt: submitTime, // Exact time log
      );

      // Simpan ke reactive store lokal agar langsung muncul di UI seketika
      HotelOperationsStore.instance.addDamageTicket(ticket);

      // Sinkronkan ke server backend
      try {
        await MaintenanceService.instance.createTicket(ticket);
      } catch (e) {
        debugPrint('⚠️ [LaporKerusakan] Gagal sinkron ke backend (offline fallback aktif): $e');
      }

      if (!mounted) return;
      Navigator.pop(context);

      final timeFormatted =
          '${submitTime.hour.toString().padLeft(2, '0')}:${submitTime.minute.toString().padLeft(2, '0')} WIB';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Laporan kerusakan di Lantai $_selectedFloor Kamar #$room berhasil dikirim! Tercatat pada $timeFormatted.',
          ),
          backgroundColor: const Color(0xFF00758F),
          behavior: SnackBarBehavior.floating,
        ),
      );

      widget.onTicketCreated?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat tiket: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.build_circle_rounded,
                          color: Color(0xFFDC2626), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Lapor Kerusakan Fasilitas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Formulir cepat & bukti foto kerusakan',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: Lokasi Lantai Berapa & Kamar Berapa (Sesuai instruksi: jelas lantai & kamar)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF0284C7)),
                            SizedBox(width: 6),
                            Text(
                              'Lokasi Terjadinya Kerusakan *',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Pilih Lantai Berapa
                        const Text(
                          'Terjadi di Lantai Berapa?',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [1, 2, 3, 4, 5].map((fl) {
                            final isSel = _selectedFloor == fl;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text('Lantai $fl'),
                                selected: isSel,
                                selectedColor: const Color(0xFF007A87),
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : const Color(0xFF334155),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                                onSelected: (_) => setState(() => _selectedFloor = fl),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),

                        // Nomor Kamar
                        const Text(
                          'Nomor Kamar Berapa?',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _roomController,
                          decoration: InputDecoration(
                            hintText: 'Contoh: 101, 204, atau Area Koridor',
                            prefixIcon: const Icon(Icons.meeting_room_outlined, color: Color(0xFF0284C7)),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Step 2: Kategori Kerusakan & Judul Masalah
                  const Text(
                    'Kategori Kerusakan *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Judul Kerusakan Singkat *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: AC tidak dingin & mengeluarkan air, Saklar lampu rusak',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Deskripsi / Rincian Kerusakan',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan catatan teknis untuk mempermudah teknisi membawa alat...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Step 3: Bukti Foto Kerusakan (Hanya untuk kerusakan sebagai bukti)
                  const Text(
                    'Bukti Foto Kerusakan Fasilitas (Kamera / Galeri)',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ambil foto langsung titik kerusakan sebagai dokumen pelaporan engineering.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),

                  if (_damagePhoto != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _damagePhoto!,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, size: 16, color: Colors.white),
                              onPressed: () => setState(() => _damagePhoto = null),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_rounded, size: 16),
                            label: const Text('Foto Kamera', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C2FF),
                              foregroundColor: const Color(0xFF003847),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined, size: 16),
                            label: const Text('Dari Galeri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              foregroundColor: const Color(0xFF334155),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Step 4: Prioritas Kerusakan
                  const Text(
                    'Tingkat Prioritas Perbaikan',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityChip('Rendah', MaintenancePriority.low, const Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      _buildPriorityChip('Sedang', MaintenancePriority.medium, const Color(0xFFF59E0B)),
                      const SizedBox(width: 8),
                      _buildPriorityChip('Darurat', MaintenancePriority.urgent, const Color(0xFFEF4444)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info Time Log Otomatis
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF00758F)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Waktu dan time log submit akan otomatis tersemat saat Anda menekan tombol Kirim Tiket.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF005E73)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Tombol Kirim Laporan
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007A87),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _isSubmitting ? 'Mengirim...' : 'Kirim Tiket Laporan Kerusakan',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
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

  Widget _buildPriorityChip(String label, MaintenancePriority p, Color color) {
    final isSel = _priority == p;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _priority = p),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? color.withValues(alpha: 0.15) : const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSel ? color : const Color(0xFFE2E8F0), width: isSel ? 1.5 : 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
              color: isSel ? color : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
