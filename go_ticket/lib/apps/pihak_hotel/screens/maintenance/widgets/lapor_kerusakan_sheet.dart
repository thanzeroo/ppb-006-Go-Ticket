import 'package:flutter/material.dart';

import '../../../../../core/models/maintenance_ticket_model.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/maintenance_service.dart';

/// Modal Bottom Sheet: Lapor Kerusakan Fasilitas (Terkoneksi langsung ke Supabase)
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

class LaporKerusakanModalContent extends StatefulWidget {
  final VoidCallback? onTicketCreated;

  const LaporKerusakanModalContent({super.key, this.onTicketCreated});

  @override
  State<LaporKerusakanModalContent> createState() =>
      _LaporKerusakanModalContentState();
}

class _LaporKerusakanModalContentState extends State<LaporKerusakanModalContent> {
  final _roomController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  MaintenancePriority _priority = MaintenancePriority.medium;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _roomController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final title = _titleController.text.trim();
    final room = _roomController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul masalah wajib diisi'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = AuthService.instance.currentUser;
      final hotelId = user?.managedHotelId ?? '1';

      final ticket = MaintenanceTicketModel(
        id: '',
        hotelId: hotelId,
        roomId: room,
        roomNumber: room.isNotEmpty ? 'Kamar $room' : 'Area Umum',
        title: title,
        description: _descController.text.trim(),
        priority: _priority,
        status: MaintenanceStatus.open,
        category: TicketCategory.ac,
        reportedById: (user != null && user.id.isNotEmpty)
            ? user.id
            : 'MT-2025-001',
        reportedByName: user?.fullName ?? 'Petugas Maintenance',
        createdAt: DateTime.now(),
      );

      await MaintenanceService.instance.createTicket(ticket);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tiket perbaikan "$title" berhasil dikirim ke database!'),
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
          // Header Lapor Kerusakan Fasilitas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Color(0xFF0F172A)),
                  onPressed: () => Navigator.pop(context),
                ),
                Image.asset(
                  'assets/logo.png',
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.confirmation_number_outlined,
                      color: Color(0xFF00B4D8)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Lapor Kerusakan Fasilitas',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Sistem Tiket Pemeliharaan & Engineering',
                        style: TextStyle(
                            fontSize: 10.5, color: Color(0xFF0284C7)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                      color: Color(0xFF0A5868), shape: BoxShape.circle),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),

          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge: Live Database Sync
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(14),
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
                                Text('TIKET MAINTENANCE BARU',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF64748B))),
                                SizedBox(width: 6),
                                Text('Live DB Sync',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0284C7))),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('● Drafting',
                                  style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E40AF))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.engineering_outlined,
                                size: 13, color: Color(0xFF0284C7)),
                            const SizedBox(width: 4),
                            Text(
                              'Pelapor: ${AuthService.instance.currentUser?.fullName ?? "Staf Ops"}',
                              style: const TextStyle(
                                  fontSize: 10.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Step 1: Nomor Kamar / Lokasi
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                  color: Color(0xFFDBEAFE),
                                  shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: const Text('1',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E40AF))),
                            ),
                            const SizedBox(width: 8),
                            const Text('Nomor Kamar / Unit',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _roomController,
                          decoration: InputDecoration(
                            hintText: 'Contoh: 101, 202, atau Lobby',
                            prefixIcon: const Icon(Icons.meeting_room_outlined,
                                color: Color(0xFF0284C7)),
                            filled: true,
                            fillColor: const Color(0xFFF1F5FD),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Step 2: Prioritas Kerusakan
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                  color: Color(0xFFDBEAFE),
                                  shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: const Text('2',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E40AF))),
                            ),
                            const SizedBox(width: 8),
                            const Text('Tingkat Prioritas',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildPriorityOption(
                              label: 'Normal',
                              priority: MaintenancePriority.low,
                              color: const Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 8),
                            _buildPriorityOption(
                              label: 'Sedang',
                              priority: MaintenancePriority.medium,
                              color: const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 8),
                            _buildPriorityOption(
                              label: 'Tinggi',
                              priority: MaintenancePriority.high,
                              color: const Color(0xFFEA580C),
                            ),
                            const SizedBox(width: 8),
                            _buildPriorityOption(
                              label: 'Darurat',
                              priority: MaintenancePriority.critical,
                              color: const Color(0xFFDC2626),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Step 3: Detail Keluhan Kerusakan
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                  color: Color(0xFFDBEAFE),
                                  shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: const Text('3',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E40AF))),
                            ),
                            const SizedBox(width: 8),
                            const Text('Detail Keluhan Kerusakan',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Judul Singkat Masalah',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Contoh: AC Menetes / Kran Bocor',
                            filled: true,
                            fillColor: const Color(0xFFF1F5FD),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                            'Deskripsi Rinci Masalah • Temuan Lapangan',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Jelaskan kondisi kerusakan secara detail...',
                            filled: true,
                            fillColor: const Color(0xFFF1F5FD),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Action Bar: [Batal / Reset] [Terbitkan • Kirim >]
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEEF2FE),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)),
                      ),
                      child: const Text('Batal',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitReport,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 16),
                      label: Text(
                        _isSubmitting ? 'Mengirim...' : 'Terbitkan • Kirim',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C2FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOption({
    required String label,
    required MaintenancePriority priority,
    required Color color,
  }) {
    final isSelected = _priority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = priority),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : const Color(0xFFF1F5FD),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? color : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
