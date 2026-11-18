import 'package:flutter/material.dart';

import '../../../../../core/services/auth_service.dart';
import '../../../services/hotel_operations_store.dart';

/// Modal Form Pengajuan Penambahan Akun Administrator via Email ke Pihak Go Ticket.
/// Sesuai aturan:
/// Administrator hotel tidak bisa menambahkan akun administrator sendiri secara langsung.
/// Hanya Super Admin / Pihak Go Ticket yang memiliki wewenang tersebut.
void showRequestAdminEmailModal(BuildContext context, {VoidCallback? onSuccess}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => RequestAdminEmailSheet(onSuccess: onSuccess),
  );
}

class RequestAdminEmailSheet extends StatefulWidget {
  final VoidCallback? onSuccess;

  const RequestAdminEmailSheet({super.key, this.onSuccess});

  @override
  State<RequestAdminEmailSheet> createState() => _RequestAdminEmailSheetState();
}

class _RequestAdminEmailSheetState extends State<RequestAdminEmailSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hotelController = TextEditingController(text: 'The Grand Amora Resort');
  final _reasonController = TextEditingController();
  final _targetEmailController = TextEditingController(text: 'admin@goticket.id');

  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _hotelController.dispose();
    _reasonController.dispose();
    _targetEmailController.dispose();
    super.dispose();
  }

  void _submitEmailRequest() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final reason = _reasonController.text.trim();

    if (name.isEmpty) {
      _showWarning('Nama lengkap calon administrator wajib diisi');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showWarning('Email calon administrator tidak valid');
      return;
    }
    if (phone.isEmpty) {
      _showWarning('Nomor telepon/WhatsApp wajib diisi');
      return;
    }
    if (reason.isEmpty) {
      _showWarning('Silakan isi alasan / surat pengajuan permohonan akun');
      return;
    }

    setState(() => _isSending = true);

    HotelOperationsStore.instance.submitAdminAccountRequest(
      candidateName: name,
      candidateEmail: email,
      candidatePhone: phone,
      hotelName: _hotelController.text.trim(),
      reason: reason,
      targetEmail: _targetEmailController.text.trim(),
    );

    setState(() => _isSending = false);
    Navigator.pop(context);

    // Tampilkan konfirmasi dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.all(20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.mark_email_read_rounded,
                  color: Color(0xFF16A34A), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Permohonan Terkirim!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permohonan penambahan akun Administrator telah diteruskan via email ke:',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, size: 16, color: Color(0xFF00758F)),
                  const SizedBox(width: 8),
                  Text(
                    _targetEmailController.text.trim(),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Calon Admin: $name ($email)',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Super Admin / Pihak Go Ticket akan memverifikasi permohonan properti hotel Anda dalam 1x24 jam kerja.',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007A87),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );

    widget.onSuccess?.call();
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
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
                        color: const Color(0xFFE0F4FB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.forward_to_inbox_rounded,
                          color: Color(0xFF00758F), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Pengajuan Akun Administrator',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Kirim via email ke pihak Go Ticket',
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
                  // Info Banner Kebijakan Super Admin
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.shield_outlined, color: Color(0xFFD97706), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Demi keamanan data properti & transaksi, pembuatan akun Administrator hanya dapat diproses langsung oleh Super Admin / Pihak Go Ticket.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input 1: Nama Calon Admin
                  const Text('Nama Lengkap Calon Administrator *',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Bagus Kurniawan, S.E.',
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF0284C7)),
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

                  // Input 2: Email Calon Admin
                  const Text('Alamat Email Calon Administrator *',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Contoh: bagus.kurniawan@hotel.com',
                      prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFF0284C7)),
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

                  // Input 3: Nomor Telepon / WhatsApp
                  const Text('Nomor WhatsApp / Telepon Aktif *',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 081234567890',
                      prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF0284C7)),
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

                  // Input 4: Nama Properti Hotel
                  const Text('Nama Properti Hotel & Cabang',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _hotelController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.business_outlined, color: Color(0xFF0284C7)),
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

                  // Input 5: Alasan Permohonan / Catatan Pengajuan
                  const Text('Alasan / Kebutuhan Penambahan Akun Administrator *',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan alasan pengajuan, misalnya: Penambahan General Manager baru atau rotasi tim keuangan properti...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Input 6: Email Tujuan Pihak Go Ticket
                  const Text('Email Tujuan Pihak Go Ticket',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _targetEmailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.mail_lock_outlined, color: Color(0xFF00758F)),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Kirim Permohonan Email
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _submitEmailRequest,
                      icon: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        _isSending ? 'Mengirimkan...' : 'Kirim Pengajuan Email ke Pihak Go Ticket',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007A87),
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
