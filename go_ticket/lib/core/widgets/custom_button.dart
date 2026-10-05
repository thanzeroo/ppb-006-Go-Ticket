// =============================================================================
// FILE: lib/core/widgets/custom_button.dart
// RESPONSIBILITY: Widget tombol kustom yang konsisten digunakan di seluruh
// aplikasi Go Ticket. Menyediakan beberapa varian:
// - GoTicketButton: Tombol primer (filled/solid) — aksi utama
// - GoTicketOutlinedButton: Tombol outline — aksi sekunder
// - GoTicketTextButton: Tombol teks — aksi tersier / link
// - GoTicketIconButton: Tombol dengan ikon di kiri
// Semua tombol mendukung loading state dan disabled state.
// =============================================================================

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

// =============================================================================
// PRIMARY BUTTON — Tombol aksi utama (solid/filled)
// =============================================================================

/// Tombol primer Go Ticket dengan background solid warna brand.
///
/// ```dart
/// GoTicketButton(
///   label: 'Pesan Sekarang',
///   onPressed: () => handleBooking(),
///   isLoading: isProcessing,
/// )
/// ```
class GoTicketButton extends StatelessWidget {
  /// Teks yang ditampilkan di dalam tombol
  final String label;

  /// Callback saat tombol ditekan. Set null untuk disable tombol.
  final VoidCallback? onPressed;

  /// Menampilkan loading indicator dan menonaktifkan tombol
  final bool isLoading;

  /// Warna background tombol (default: AppColors.primary)
  final Color? backgroundColor;

  /// Warna teks tombol (default: white)
  final Color? foregroundColor;

  /// Ikon opsional di sebelah kiri label
  final IconData? icon;

  /// Lebar tombol (default: full width / double.infinity)
  final double? width;

  /// Tinggi tombol (default: 52)
  final double height;

  const GoTicketButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.width = double.infinity,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? AppColors.white,
          disabledBackgroundColor: AppColors.grey300,
          disabledForegroundColor: AppColors.grey500,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: AppTextStyles.labelLarge.copyWith(
                    color: foregroundColor ?? AppColors.white,
                  )),
                ],
              ),
      ),
    );
  }
}

// =============================================================================
// OUTLINED BUTTON — Tombol aksi sekunder (outline)
// =============================================================================

/// Tombol outline Go Ticket untuk aksi sekunder.
class GoTicketOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? borderColor;
  final Color? foregroundColor;
  final IconData? icon;
  final double? width;
  final double height;

  const GoTicketOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.borderColor,
    this.foregroundColor,
    this.icon,
    this.width = double.infinity,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final color = foregroundColor ?? AppColors.primary;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          disabledForegroundColor: AppColors.grey400,
          side: BorderSide(
            color: isDisabled
                ? AppColors.grey300
                : (borderColor ?? AppColors.primary),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: color,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: AppTextStyles.labelLarge.copyWith(color: color)),
                ],
              ),
      ),
    );
  }
}

// =============================================================================
// TEXT BUTTON — Tombol teks / link
// =============================================================================

/// Tombol teks minimalis untuk aksi tersier atau link navigasi.
class GoTicketTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;
  final bool underline;

  const GoTicketTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.icon,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.primary;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: textColor,
              decoration: underline ? TextDecoration.underline : null,
              decorationColor: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SOCIAL SIGN IN BUTTON — Untuk login Google / Social Media
// =============================================================================

/// Tombol login sosial (contoh: Google Sign In)
class GoTicketSocialButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget icon;
  final bool isLoading;

  const GoTicketSocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.grey300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
