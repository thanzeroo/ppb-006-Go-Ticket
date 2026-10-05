// =============================================================================
// FILE: lib/core/widgets/custom_text_field.dart
// RESPONSIBILITY: Widget TextField kustom yang konsisten dan reusable untuk
// seluruh form di aplikasi Go Ticket. Mendukung:
// - Label, hint text, dan ikon prefix/suffix
// - Mode password dengan toggle visibility
// - Validasi inline dengan error message
// - Readonly / disabled state
// - Phone number, email, dan numeric keyboard type
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

/// TextField kustom Go Ticket yang konsisten di semua halaman form.
///
/// ```dart
/// GoTicketTextField(
///   label: 'Nomor HP',
///   hint: 'Contoh: 08123456789',
///   controller: phoneController,
///   keyboardType: TextInputType.phone,
///   prefixIcon: Icons.phone_outlined,
///   validator: (val) => val!.isEmpty ? 'HP tidak boleh kosong' : null,
/// )
/// ```
class GoTicketTextField extends StatefulWidget {
  /// Label yang muncul di atas input field
  final String? label;

  /// Hint text / placeholder di dalam field
  final String? hint;

  /// Controller untuk mengontrol dan membaca nilai field
  final TextEditingController? controller;

  /// Tipe keyboard yang muncul saat field difokus
  final TextInputType keyboardType;

  /// Ikon di sebelah kiri field
  final IconData? prefixIcon;

  /// Widget suffix opsional (misalnya tombol atau ikon)
  final Widget? suffix;

  /// Apakah ini field password (teks tersembunyi dengan toggle show/hide)
  final bool isPassword;

  /// Apakah field ini read-only (tidak bisa diedit)
  final bool readOnly;

  /// Apakah field ini dinonaktifkan
  final bool enabled;

  /// Jumlah baris maksimal (untuk textarea / multi-line)
  final int maxLines;

  /// Jumlah karakter maksimal
  final int? maxLength;

  /// Input formatters (misalnya hanya digit)
  final List<TextInputFormatter>? inputFormatters;

  /// Fungsi validasi — kembalikan string error, atau null jika valid
  final FormFieldValidator<String>? validator;

  /// Callback saat nilai berubah
  final ValueChanged<String>? onChanged;

  /// Callback saat field di-tap (berguna untuk readOnly field yang buka dialog)
  final VoidCallback? onTap;

  /// Callback saat user submit (tekan enter/done)
  final VoidCallback? onSubmitted;

  /// Action button di keyboard (default: TextInputAction.next)
  final TextInputAction textInputAction;

  /// Focus node opsional untuk kontrol fokus programmatic
  final FocusNode? focusNode;

  /// Initial value tanpa menggunakan controller
  final String? initialValue;

  const GoTicketTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffix,
    this.isPassword = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.initialValue,
  });

  @override
  State<GoTicketTextField> createState() => _GoTicketTextFieldState();
}

class _GoTicketTextFieldState extends State<GoTicketTextField> {
  // Toggle visibilitas untuk field password
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label di atas field
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // TextField utama
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword && _obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onFieldSubmitted: widget.onSubmitted != null
              ? (_) => widget.onSubmitted!()
              : null,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '', // Sembunyikan counter maxLength

            // Prefix icon
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: AppColors.grey400,
                    size: 20,
                  )
                : null,

            // Suffix — password toggle atau widget kustom
            suffixIcon: _buildSuffix(),
          ),
        ),
      ],
    );
  }

  /// Membangun widget suffix berdasarkan tipe field
  Widget? _buildSuffix() {
    // Untuk field password: tampilkan ikon show/hide
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.grey400,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    // Widget suffix kustom dari luar
    if (widget.suffix != null) {
      return widget.suffix;
    }

    // Untuk readOnly field: tampilkan ikon chevron
    if (widget.readOnly && widget.onTap != null) {
      return const Icon(
        Icons.chevron_right,
        color: AppColors.grey400,
        size: 20,
      );
    }

    return null;
  }
}

// =============================================================================
// SEARCH FIELD — Khusus untuk pencarian hotel
// =============================================================================

/// TextField khusus untuk pencarian hotel di Customer Dashboard.
class GoTicketSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;

  const GoTicketSearchField({
    super.key,
    this.controller,
    this.hint = 'Cari hotel, kota, atau tujuan...',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      autofocus: autofocus,
      onChanged: onChanged,
      onTap: onTap,
      onSubmitted: onSubmitted != null ? (_) => onSubmitted!() : null,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.grey400,
          size: 22,
        ),
        suffixIcon: controller?.text.isNotEmpty == true
            ? IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.grey400),
                onPressed: () {
                  controller?.clear();
                  onChanged?.call('');
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
