import 'package:flutter/material.dart';

import '../../../../../core/services/auth_service.dart';
import '../../../services/hotel_operations_store.dart';

/// Modal Bottom Sheet: Form Cek Kebersihan & Sanitasi Kamar
/// Flow yang simpel namun jelas tanpa input foto/gambar
/// (Foto hanya untuk kerusakan sebagai bukti).
/// Otomatis mencatat time log saat petugas mengirimkannya/submit.
void showFormCekKebersihanModal(
  BuildContext context, {
  required CleaningTaskItem task,
  VoidCallback? onFinished,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => FormCekKebersihanSheet(task: task, onFinished: onFinished),
  );
}

/// Konten bottom sheet checklist sanitasi dan kebersihan kamar untuk tim Maintenance.
class FormCekKebersihanSheet extends StatefulWidget {
  final CleaningTaskItem task;
  final VoidCallback? onFinished;

  const FormCekKebersihanSheet({
    super.key,
    required this.task,
    this.onFinished,
  });

  @override
  State<FormCekKebersihanSheet> createState() => _FormCekKebersihanSheetState();
}

class _FormCekKebersihanSheetState extends State<FormCekKebersihanSheet> {
  // Checklist sanitasi standar housekeeping
  final Map<String, bool> _checklist = {
    'Ganti sprei kasur & sarung bantal bersih baru': true,
    'Sanitasi & disinfeksi kloset, wastafel, & shower': true,
    'Sapu, pel, & vakum debu seluruh lantai kamar': true,
    'Ganti handuk bersih & isi ulang amenities (sabun, sampo, air mineral)': true,
    'Pengecekan fungsi AC dingin, lampu penerangan, & remote TV': true,
  };

  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitCleaning() {
    // Validasi apakah semua checklist telah dicentang
    final uncompleted = _checklist.entries.where((e) => !e.value).toList();
    if (uncompleted.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi dan centang seluruh checklist sanitasi kebersihan.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final currentUser = AuthService.instance.currentUser;
    final staffName = currentUser?.fullName ?? 'Petugas Housekeeping';
    final notes = <String>[];
    if (_notesController.text.trim().isNotEmpty) {
      notes.add(_notesController.text.trim());
    }

    // Eksekusi penyelesaian kebersihan di store (time log otomatis tercatat DateTime.now())
    HotelOperationsStore.instance.finishCleaning(
      taskId: widget.task.id,
      cleanedBy: staffName,
      checklistNotes: notes,
    );

    setState(() => _isSubmitting = false);
    Navigator.pop(context);

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Kamar #${widget.task.roomNumber} (Lt. ${widget.task.floorNumber}) telah BERSIH & SIAP HUNI! Tercatat pukul $timeStr.',
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );

    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final currentUser = AuthService.instance.currentUser;
    final staffName = currentUser?.fullName ?? 'Petugas Housekeeping';

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Form Cek Kebersihan
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
                        color: const Color(0xFFE0F4FB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.cleaning_services_outlined,
                          color: Color(0xFF00758F), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Form Cek Kebersihan Kamar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Kamar #${task.roomNumber} • Lantai ${task.floorNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0284C7),
                          ),
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
                  // Box Info Kamar & Check-Out Tamu
                  Container(
                    padding: const EdgeInsets.all(14),
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
                            Text(
                              task.roomTypeName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task.checkoutType == CheckoutType.forcedExpulsion
                                    ? 'Keluar Paksa'
                                    : (task.checkoutType == CheckoutType.early
                                        ? 'Check-out Awal'
                                        : 'Normal Selesai'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (task.previousGuestName != null)
                          Text(
                            'Tamu Sebelumnya: ${task.previousGuestName}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                          ),
                        Text(
                          'Waktu Check-Out: ${task.checkoutTime.hour.toString().padLeft(2, '0')}:${task.checkoutTime.minute.toString().padLeft(2, '0')} WIB',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                        if (task.checkoutReason != null && task.checkoutReason!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Catatan FO: ${task.checkoutReason}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFB45309),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Info Petugas & Auto Time-Log
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 20, color: Color(0xFF00758F)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Petugas: $staffName',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const Text(
                                'Time log submit akan otomatis tercatat saat formulir ini dikirimkan.',
                                style: TextStyle(fontSize: 10.5, color: Color(0xFF005E73)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Checklist Kebersihan & Sanitasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daftar Periksa Sanitasi Kamar *',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            final allChecked = _checklist.values.every((v) => v);
                            _checklist.updateAll((key, val) => !allChecked);
                          });
                        },
                        child: const Text('Pilih Semua', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  ..._checklist.keys.map((item) {
                    final isChecked = _checklist[item] ?? false;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _checklist[item] = !isChecked;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isChecked ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isChecked ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              color: isChecked ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                                  color: isChecked ? const Color(0xFF14532D) : const Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 14),

                  // Catatan Tambahan Petugas
                  const Text(
                    'Catatan Tambahan Housekeeping (Opsional)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Karpet sudah difragrance, tirai diganti baru, dll.',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Kirim & Tandai Siap Huni
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitCleaning,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(
                        _isSubmitting
                            ? 'Menyimpan...'
                            : 'Kirim & Tandai Kamar Bersih (Siap Huni)',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
