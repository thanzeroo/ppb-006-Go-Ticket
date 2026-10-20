import 'package:flutter/material.dart';

import '../../../../core/widgets/auth_logo_header.dart';
import '../dashboard/customer_dashboard_screen.dart';
<<<<<<< HEAD:go_ticket/lib/apps/user/screens/auth/customer_login_screen.dart
import 'terms_screen.dart';
=======
import 'terms_and_policy_screen.dart';
>>>>>>> b22167a638fe5031603dbdfed85d081a7ce2eb77:go_ticket/lib/apps/pihak_user/screens/auth/customer_login_screen.dart

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  int _tabIndex = 0;

  // Controllers untuk Login
  final _emailLoginController = TextEditingController();
  final _passwordLoginController = TextEditingController();

  // Controllers untuk Register
  final _nameController = TextEditingController();
  final _emailRegisterController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordRegisterController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Status checkbox & visibility password
  bool _rememberMe = true;
  bool _agreeTerms = false;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailLoginController.dispose();
    _passwordLoginController.dispose();
    _nameController.dispose();
    _emailRegisterController.dispose();
    _phoneController.dispose();
    _passwordRegisterController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

<<<<<<< HEAD:go_ticket/lib/apps/user/screens/auth/customer_login_screen.dart
  /// Simulasi proses login / register dan masuk ke Dashboard
  Future<void> _submit() async {
    final formKey = _tabIndex == 0 ? _loginFormKey : _registerFormKey;
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (_tabIndex == 1 && !_agreeTerms) {
      _showSnack('Anda harus menyetujui Syarat & Ketentuan terlebih dahulu');
      return;
    }

=======
  /// Masuk ke Dashboard (Login)
  Future<void> _submitLogin() async {
>>>>>>> b22167a638fe5031603dbdfed85d081a7ce2eb77:go_ticket/lib/apps/pihak_user/screens/auth/customer_login_screen.dart
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()),
      (_) => false,
    );
  }

<<<<<<< HEAD:go_ticket/lib/apps/user/screens/auth/customer_login_screen.dart
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openTerms() async {
    final agreed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const TermsScreen()),
    );
    if (agreed == true && mounted) setState(() => _agreeTerms = true);
  }

  void _showForgotPassword() {
    final ctrl = TextEditingController(text: _emailLoginController.text);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lupa Kata Sandi', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan email atau nomor WhatsApp terdaftar. Kami akan '
              'mengirim tautan untuk mengatur ulang kata sandi.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                hintText: 'nama@email.com / 0812xxxx',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final v = ctrl.text.trim();
              Navigator.pop(ctx);
              if (v.isEmpty) {
                _showSnack('Email / nomor WhatsApp tidak boleh kosong');
              } else {
                _showSnack('Tautan reset kata sandi dikirim ke $v');
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }

  // ---------------------------------------------------------------------------
  // VALIDATOR
  // ---------------------------------------------------------------------------

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phoneRe = RegExp(r'^(\+62|62|0)8[0-9]{8,12}$');

  String? _vRequired(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label tidak boleh kosong' : null;

  String? _vEmailOrPhone(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Email / nomor WhatsApp tidak boleh kosong';
    if (!_emailRe.hasMatch(t) && !_phoneRe.hasMatch(t)) {
      return 'Format email atau nomor WhatsApp tidak valid';
    }
    return null;
  }

  String? _vEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Email tidak boleh kosong';
    if (!_emailRe.hasMatch(t)) return 'Format email tidak valid';
    return null;
  }

  String? _vPhone(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Nomor telepon tidak boleh kosong';
    if (!_phoneRe.hasMatch(t)) return 'Nomor telepon tidak valid (contoh 0812xxxx)';
    return null;
  }

  String? _vPassword(String? v) {
    final t = v ?? '';
    if (t.isEmpty) return 'Kata sandi tidak boleh kosong';
    if (t.length < 8) return 'Kata sandi minimal 8 karakter';
    return null;
  }

  String? _vConfirm(String? v) {
    if ((v ?? '').isEmpty) return 'Konfirmasi kata sandi tidak boleh kosong';
    if (v != _passwordRegisterController.text) return 'Kata sandi tidak sama';
    return null;
=======
  /// Ketika klik "Buat Akun" di form register:
  /// Langsung mengarah ke Terms and Policy. Jika diklik (selesai/balik),
  /// kembali ke login utama (tab Masuk).
  void _submitRegister() {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const TermsAndPolicyScreen()),
    ).then((agreed) {
      if (!mounted) return;
      // Balik lagi ke login utama (tab Masuk)
      setState(() {
        _tabIndex = 0;
      });
    });
>>>>>>> b22167a638fe5031603dbdfed85d081a7ce2eb77:go_ticket/lib/apps/pihak_user/screens/auth/customer_login_screen.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: Navigator.canPop(context)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF1E293B),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Pilih Portal',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo dengan glowing effect
              const AuthLogoHeader(imagePath: 'assets/logo.png'),
              const SizedBox(height: 18),

              // Judul Utama: "Selamat Datang di Go Ticket"
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Selamat Datang di ',
                      style: TextStyle(color: Color(0xFF0F172A)),
                    ),
                    TextSpan(
                      text: 'Go\n',
                      style: TextStyle(color: Color(0xFF00758F)),
                    ),
                    TextSpan(
                      text: 'Ticket',
                      style: TextStyle(color: Color(0xFF00758F)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Akses kemudahan reservasi hotel & penginapan\nterbaik impianmu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),

              // Switcher Tab: [ Masuk ] [ Daftar Akun ]
              _buildTabSwitcher(),
              const SizedBox(height: 22),

              // Form sesuai tab yang dipilih
              _tabIndex == 0 ? _buildLoginForm() : _buildRegisterForm(),
              const SizedBox(height: 22),

              // Badge Keamanan Enkripsi
              _buildSecurityBadge(),
              const SizedBox(height: 14),

              // Banner Keuntungan Khusus Member
              _buildMemberBenefitCard(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGETS
  // ---------------------------------------------------------------------------

  /// Tab switcher rounded pill: [ Masuk ] / [ Daftar Akun ]
  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0FE),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Masuk',
              icon: Icons.login_rounded,
              isSelected: _tabIndex == 0,
              onTap: () => setState(() => _tabIndex = 0),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: 'Daftar Akun',
              icon: Icons.person_add_alt_outlined,
              isSelected: _tabIndex == 1,
              onTap: () => setState(() => _tabIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Form untuk Tab MASUK
  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Email atau No. WhatsApp'),
        _buildTextField(
          controller: _emailLoginController,
          hintText: 'nama@email.com / 0812xxxx',
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: _vEmailOrPhone,
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInputLabel('Kata Sandi'),
            GestureDetector(
<<<<<<< HEAD:go_ticket/lib/apps/user/screens/auth/customer_login_screen.dart
              onTap: _showForgotPassword,
=======
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur reset kata sandi dikirim ke WhatsApp/Email Anda.'),
                    backgroundColor: Color(0xFF00758F),
                  ),
                );
              },
>>>>>>> b22167a638fe5031603dbdfed85d081a7ce2eb77:go_ticket/lib/apps/pihak_user/screens/auth/customer_login_screen.dart
              child: const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0086A8),
                ),
              ),
            ),
          ],
        ),
        _buildTextField(
          controller: _passwordLoginController,
          hintText: 'Masukkan kata sandi',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureLoginPassword,
          validator: (v) => _vRequired(v, 'Kata sandi'),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureLoginPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 19,
              color: const Color(0xFF94A3B8),
            ),
            onPressed: () =>
                setState(() => _obscureLoginPassword = !_obscureLoginPassword),
          ),
        ),
        const SizedBox(height: 12),

        // Checkbox Ingat Saya
        _buildRememberMeCheckbox(),
        const SizedBox(height: 18),

        // Tombol Masuk ke Akun
        _buildPrimaryButton(title: 'Masuk ke Akun', onTap: _submitLogin),
        const SizedBox(height: 22),

        // Divider: ATAU LANJUTKAN DENGAN
        _buildOrDivider(),
        const SizedBox(height: 16),

        // Tombol Google & Apple
        Row(
          children: [
            Expanded(
<<<<<<< HEAD:go_ticket/lib/apps/user/screens/auth/customer_login_screen.dart
              child: _buildSocialButton(
                title: 'Google',
                onTap: () => _showSnack('Masuk dengan Google segera hadir'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocialButton(
                title: 'Apple',
                onTap: () => _showSnack('Masuk dengan Apple segera hadir'),
              ),
=======
              child: _buildGoogleButton(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAppleButton(),
>>>>>>> b22167a638fe5031603dbdfed85d081a7ce2eb77:go_ticket/lib/apps/pihak_user/screens/auth/customer_login_screen.dart
            ),
          ],
        ),
      ],
      ),
    );
  }

  /// Form untuk Tab DAFTAR AKUN
  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Nama Lengkap'),
        _buildTextField(
          controller: _nameController,
          hintText: 'Masukkan nama lengkap anda',
          prefixIcon: Icons.person_outline_rounded,
          validator: (v) => _vRequired(v, 'Nama lengkap'),
        ),
        const SizedBox(height: 14),

        _buildInputLabel('Email'),
        _buildTextField(
          controller: _emailRegisterController,
          hintText: 'nama@email.com',
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: _vEmail,
        ),
        const SizedBox(height: 14),

        _buildInputLabel('Nomor Telepon'),
        _buildTextField(
          controller: _phoneController,
          hintText: 'Contoh: 08123456789',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: _vPhone,
        ),
        const SizedBox(height: 14),

        _buildInputLabel('Kata Sandi'),
        _buildTextField(
          controller: _passwordRegisterController,
          hintText: 'Minimal 8 karakter',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureRegisterPassword,
          validator: _vPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureRegisterPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 19,
              color: const Color(0xFF94A3B8),
            ),
            onPressed: () => setState(
                () => _obscureRegisterPassword = !_obscureRegisterPassword),
          ),
        ),
        const SizedBox(height: 14),

        _buildInputLabel('Konfirmasi Kata Sandi'),
        _buildTextField(
          controller: _confirmPasswordController,
          hintText: 'Ulangi kata sandi',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          validator: _vConfirm,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 19,
              color: const Color(0xFF94A3B8),
            ),
            onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
          ),
        ),
        const SizedBox(height: 14),

        _buildTermsCheckbox(),
        const SizedBox(height: 18),

        // Tombol Buat Akun -> mengarah ke Terms and Policy
        _buildPrimaryButton(
          title: 'Buat Akun',
          onTap: _submitRegister,
        ),
      ],
      ),
    );
  }

  /// Checkbox persetujuan Syarat & Ketentuan (wajib saat daftar)
  Widget _buildTermsCheckbox() {
    const base = TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4);
    const link = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF00A8E8),
      height: 1.4,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _agreeTerms,
            activeColor: const Color(0xFF00C7F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: Color(0xFF00C7F2), width: 1.5),
            onChanged: (val) => setState(() => _agreeTerms = val ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: _openTerms,
            child: RichText(
              text: const TextSpan(
                style: base,
                children: [
                  TextSpan(text: 'Saya menyetujui '),
                  TextSpan(text: 'Syarat & Ketentuan', style: link),
                  TextSpan(text: ' serta '),
                  TextSpan(text: 'Kebijakan Privasi', style: link),
                  TextSpan(text: ' Go Ticket'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF0096B4),
            size: 19,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          errorStyle: const TextStyle(fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _rememberMe,
            activeColor: const Color(0xFF00C2FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: Color(0xFF00C2FF), width: 1.6),
            onChanged: (val) => setState(() => _rememberMe = val ?? false),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Ingat saya di perangkat ini',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C2FF),
          elevation: 0,
          shadowColor: const Color(0xFF00C2FF).withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'ATAU LANJUTKAN DENGAN',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
      ],
    );
  }

  /// Tombol Google dengan Google Multi-color G
  Widget _buildGoogleButton() {
    return InkWell(
      onTap: _submitLogin,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FD),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGoogleGLogo(),
            const SizedBox(width: 8),
            const Text(
              'Google',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tombol Apple
  Widget _buildAppleButton() {
    return InkWell(
      onTap: _submitLogin,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FD),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.apple, color: Colors.black, size: 20),
            SizedBox(width: 8),
            Text(
              'Apple',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleGLogo() {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(
        painter: _GoogleGPainter(),
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.verified_user_rounded, color: Color(0xFF00758F), size: 14),
        SizedBox(width: 6),
        Text(
          'TERPROTEKSI ENKRIPSI 256-BIT KELAS PERBANKAN',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// Banner Keuntungan Khusus Member di bagian bawah
  Widget _buildMemberBenefitCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F4FE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Color(0xFF008AA8),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Keuntungan Khusus Member',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Dapatkan poin cashback & konfirmasi instan',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF036982),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter untuk Google Multi-color Logo
class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final paintBlue = Paint()..color = const Color(0xFF4285F4);
    final paintRed = Paint()..color = const Color(0xFFEA4335);
    final paintYellow = Paint()..color = const Color(0xFFFBBC05);
    final paintGreen = Paint()..color = const Color(0xFF34A853);

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Top arc (Red)
    canvas.drawArc(rect, -2.4, 1.6, true, paintRed);
    // Left arc (Yellow)
    canvas.drawArc(rect, -4.0, 1.6, true, paintYellow);
    // Bottom arc (Green)
    canvas.drawArc(rect, 0.8, 1.6, true, paintGreen);
    // Right arc (Blue)
    canvas.drawArc(rect, -0.8, 1.6, true, paintBlue);

    // Inner cutout
    final innerPaint = Paint()..color = const Color(0xFFF1F4FD);
    canvas.drawCircle(center, radius * 0.58, innerPaint);

    // Horizontal bar of G
    final barRect = Rect.fromLTRB(w * 0.44, h * 0.38, w * 0.98, h * 0.62);
    canvas.drawRect(barRect, paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
