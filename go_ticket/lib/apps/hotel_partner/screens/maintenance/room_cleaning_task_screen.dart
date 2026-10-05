// =============================================================================
// FILE: lib/apps/hotel_partner/screens/maintenance/room_cleaning_task_screen.dart
// RESPONSIBILITY: Halaman detail tugas pembersihan kamar untuk Staff Maintenance.
// Staff mengupdate status kamar melalui alur:
// Dirty → Cleaning → Clean & Ready (Available)
// Staff juga bisa melaporkan kerusakan yang ditemukan saat bersih-bersih.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../router/hotel_router.dart';

/// Halaman tugas pembersihan kamar untuk Staff Maintenance.
class RoomCleaningTaskScreen extends StatefulWidget {
  final dynamic arguments;

  const RoomCleaningTaskScreen({super.key, this.arguments});

  @override
  State<RoomCleaningTaskScreen> createState() =>
      _RoomCleaningTaskScreenState();
}

class _RoomCleaningTaskScreenState extends State<RoomCleaningTaskScreen> {
  // Status kamar saat ini — dimulai dari dirty
  String _currentStatus = 'dirty';
  bool _isUpdating = false;

  final List<_CleaningStep> _steps = const [
    _CleaningStep('Perlu Dibersihkan', 'dirty', AppColors.roomDirty,
        Icons.cleaning_services_outlined),
    _CleaningStep('Sedang Dibersihkan', 'cleaning', AppColors.roomCleaning,
        Icons.hourglass_top_rounded),
    _CleaningStep('Siap / Available', 'available', AppColors.roomAvailable,
        Icons.check_circle_outline_rounded),
  ];

  int get _currentStepIndex =>
      _steps.indexWhere((s) => s.statusKey == _currentStatus);

  Future<void> _nextStep() async {
    final nextIndex = _currentStepIndex + 1;
    if (nextIndex >= _steps.length) return;

    setState(() => _isUpdating = true);
    // TODO: Integrasikan dengan RoomRepository.updateRoomStatus()
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _currentStatus = _steps[nextIndex].statusKey;
      _isUpdating = false;
    });

    if (_currentStatus == 'available') {
      _showRoomReadyDialog();
    }
  }

  void _showRoomReadyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hotel_rounded,
                color: AppColors.success, size: 56),
            const SizedBox(height: 16),
            Text('Kamar Siap!', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            const Text('Kamar berhasil dibersihkan dan sekarang\nberstatus Tersedia (Available).',
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStepIndex];
    final isLastStep = _currentStepIndex == _steps.length - 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Kamar ${(widget.arguments as Map?)?['roomNumber'] ?? '101'}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress stepper
            _buildStepper(),
            const SizedBox(height: 28),

            // Status saat ini
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: step.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: step.color.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(step.icon, size: 56, color: step.color),
                  const SizedBox(height: 12),
                  Text('Status Saat Ini', style: AppTextStyles.bodySmall),
                  Text(step.label,
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: step.color)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Checklist tugas pembersihan
            if (_currentStatus == 'cleaning') _buildCleaningChecklist(),
            const Spacer(),

            // Tombol update status
            if (!isLastStep)
              GoTicketButton(
                label: 'Tandai: ${_steps[_currentStepIndex + 1].label}',
                onPressed: _isUpdating ? null : _nextStep,
                isLoading: _isUpdating,
                backgroundColor: _steps[_currentStepIndex + 1].color,
                icon: Icons.arrow_forward_rounded,
              ),

            const SizedBox(height: 10),

            // Tombol laporkan kerusakan
            GoTicketOutlinedButton(
              label: 'Laporkan Kerusakan',
              onPressed: () =>
                  Navigator.pushNamed(context, HotelRouter.createTicket),
              icon: Icons.report_problem_outlined,
              borderColor: AppColors.error,
              foregroundColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: List.generate(_steps.length, (index) {
        final isActive = index <= _currentStepIndex;
        final step = _steps[index];
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive ? step.color : AppColors.grey200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isActive ? Icons.check_rounded : step.icon,
                      color: isActive ? AppColors.white : AppColors.grey400,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(step.label,
                      style: AppTextStyles.caption.copyWith(
                        color: isActive ? step.color : AppColors.grey400,
                      ),
                      textAlign: TextAlign.center),
                ],
              ),
              if (index < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < _currentStepIndex
                        ? AppColors.success
                        : AppColors.grey200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCleaningChecklist() {
    final tasks = [
      'Ganti sprei dan sarung bantal',
      'Bersihkan kamar mandi',
      'Lap debu furnitur',
      'Vacum/sapu lantai',
      'Isi ulang amenities',
      'Cek kondisi TV/AC/remot',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: tasks.asMap().entries.map((entry) {
          return CheckboxListTile(
            value: false,
            onChanged: (_) {},
            title: Text(entry.value, style: AppTextStyles.labelMedium),
            activeColor: AppColors.success,
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
      ),
    );
  }
}

class _CleaningStep {
  final String label;
  final String statusKey;
  final Color color;
  final IconData icon;

  const _CleaningStep(this.label, this.statusKey, this.color, this.icon);
}
