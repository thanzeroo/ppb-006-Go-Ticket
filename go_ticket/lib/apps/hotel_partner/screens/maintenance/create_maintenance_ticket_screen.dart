// =============================================================================
// FILE: lib/apps/hotel_partner/screens/maintenance/create_maintenance_ticket_screen.dart
// RESPONSIBILITY: Form laporan kerusakan fasilitas kamar oleh Staff Maintenance.
// Staff melaporkan kerusakan yang ditemukan saat membersihkan kamar:
// - Pilih kamar yang bermasalah
// - Kategori kerusakan (Listrik, Air, Furnitur, AC, dll.)
// - Foto bukti kerusakan
// - Deskripsi detail dan prioritas
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

/// Form laporan kerusakan / maintenance ticket.
class CreateMaintenanceTicketScreen extends StatefulWidget {
  final dynamic arguments;

  const CreateMaintenanceTicketScreen({super.key, this.arguments});

  @override
  State<CreateMaintenanceTicketScreen> createState() =>
      _CreateMaintenanceTicketScreenState();
}

class _CreateMaintenanceTicketScreenState
    extends State<CreateMaintenanceTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String _selectedPriority = 'medium';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Listrik / Lampu',
    'Air / Ledeng',
    'AC / Ventilasi',
    'Furnitur',
    'TV / Elektronik',
    'Kunci / Pintu',
    'Kebocoran',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori kerusakan')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    // TODO: Integrasikan dengan MaintenanceRepository.createTicket()
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laporan kerusakan berhasil dikirim!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Laporan Kerusakan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Judul laporan
            _buildCard(children: [
              GoTicketTextField(
                label: 'Judul Kerusakan',
                hint: 'Contoh: Lampu kamar mandi mati',
                controller: _titleController,
                validator: (v) =>
                    v!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              GoTicketTextField(
                label: 'Deskripsi Detail',
                hint: 'Jelaskan kerusakan secara detail...',
                controller: _descriptionController,
                maxLines: 4,
                validator: (v) =>
                    v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
            ]),
            const SizedBox(height: 16),

            // Kategori kerusakan
            _buildCard(children: [
              Text('Kategori Kerusakan', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: AppTextStyles.labelSmall.copyWith(
                      color: isSelected ? AppColors.primary : null,
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 16),

            // Prioritas
            _buildCard(children: [
              Text('Tingkat Prioritas', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              ...[
                ('low', 'Rendah', 'Tidak mendesak', AppColors.info),
                ('medium', 'Sedang', 'Perlu ditangani segera', AppColors.warning),
                ('high', 'Tinggi', 'Mempengaruhi operasional', AppColors.error),
              ].map((p) {
                final isSelected = _selectedPriority == p.$1;
                return RadioListTile<String>(
                  value: p.$1,
                  groupValue: _selectedPriority,
                  onChanged: (v) =>
                      setState(() => _selectedPriority = v ?? 'medium'),
                  title: Text(p.$2, style: AppTextStyles.labelMedium),
                  subtitle: Text(p.$3, style: AppTextStyles.bodySmall),
                  activeColor: p.$4,
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ]),
            const SizedBox(height: 16),

            // Upload foto
            _buildCard(children: [
              Text('Foto Kerusakan', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  // TODO: Implementasi image picker
                },
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.grey300,
                        style: BorderStyle.solid),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          color: AppColors.grey400, size: 32),
                      SizedBox(height: 8),
                      Text('Tap untuk tambah foto'),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 24),

            GoTicketButton(
              label: 'Kirim Laporan Kerusakan',
              onPressed: _isSubmitting ? null : _submitTicket,
              isLoading: _isSubmitting,
              icon: Icons.send_rounded,
              backgroundColor: AppColors.error,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
