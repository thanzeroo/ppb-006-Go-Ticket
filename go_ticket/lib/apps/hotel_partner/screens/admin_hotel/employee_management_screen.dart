// =============================================================================
// FILE: lib/apps/hotel_partner/screens/admin_hotel/employee_management_screen.dart
// RESPONSIBILITY: Halaman manajemen akun karyawan hotel oleh Admin Hotel.
// Admin dapat mengelola akun Staff FO dan Staff Maintenance:
// - Tambah akun staff baru (username, role, password awal)
// - Lihat daftar staff aktif / nonaktif
// - Nonaktifkan/aktifkan akun staff
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

/// Halaman manajemen karyawan hotel.
class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  // TODO: Muat dari UserRepository / EmployeeRepository

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    String selectedRole = 'staff_fo';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Karyawan'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GoTicketTextField(
                label: 'Nama Lengkap',
                hint: 'Nama karyawan',
                controller: nameController,
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              GoTicketTextField(
                label: 'Username',
                hint: 'Username untuk login',
                controller: usernameController,
                prefixIcon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (ctx, setInnerState) {
                  return DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'staff_fo', child: Text('Staff Front Office')),
                      DropdownMenuItem(
                          value: 'maintenance', child: Text('Staff Maintenance')),
                    ],
                    onChanged: (v) =>
                        setInnerState(() => selectedRole = v ?? 'staff_fo'),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          GoTicketButton(
            label: 'Tambah',
            onPressed: () {
              // TODO: Integrasikan dengan EmployeeRepository.addEmployee()
              Navigator.pop(ctx);
            },
            width: 100,
            height: 40,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Manajemen Karyawan')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _buildEmployeeCard(index),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEmployeeDialog,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Tambah Staff'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildEmployeeCard(int index) {
    final roles = ['staff_fo', 'staff_fo', 'maintenance', 'maintenance', 'staff_fo'];
    final role = roles[index];
    final isFo = role == 'staff_fo';
    final isActive = index != 4;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isFo ? AppColors.info : AppColors.warning)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isFo ? Icons.support_agent_rounded : Icons.cleaning_services_rounded,
                color: isFo ? AppColors.info : AppColors.warning,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Karyawan ${index + 1}', style: AppTextStyles.titleSmall),
                Text(isFo ? 'Staff Front Office' : 'Staff Maintenance',
                    style: AppTextStyles.bodySmall),
                Text('@user_${index + 1}', style: AppTextStyles.caption),
              ],
            ),
          ),

          // Status badge + menu
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.successLight : AppColors.grey100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActive ? 'Aktif' : 'Nonaktif',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive ? AppColors.success : AppColors.grey500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
