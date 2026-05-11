import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/app_config_controller.dart';
import '../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authController = Get.find<AuthController>();
  final _configController = Get.find<AppConfigController>();

  final _inputController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  String? _inputError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _authController.errorMessage.value = '';
  }

  @override
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateInput(String value) {
    if (value.trim().isEmpty) return 'NIM atau Email tidak boleh kosong';
    if (value.trim().length < 3) return 'Masukkan NIM atau Email yang valid';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  void _clearServerError() {
    if (_authController.errorMessage.value.isNotEmpty) {
      _authController.errorMessage.value = '';
    }
  }

  void _handleLogin() {
    _authController.errorMessage.value = '';
    final inputErr = _validateInput(_inputController.text);
    final passErr = _validatePassword(_passwordController.text);
    setState(() {
      _inputError = inputErr;
      _passwordError = passErr;
    });
    if (inputErr != null || passErr != null) return;
    _authController.login(
        _inputController.text.trim(), _passwordController.text.trim());
  }

  Future<void> _launchWhatsApp() async {
    if (_configController.isLoading.value) {
      Get.snackbar('Mohon tunggu', 'Sedang memuat data...',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final phoneNumber = _configController.whatsappNumber.value;
    if (phoneNumber.isEmpty) {
      Get.snackbar('Error', 'Kontak admin tidak tersedia.',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }
    const message = 'Halo Admin, saya lupa password akun saya. Nama: ,NIM: , DIVISI: .';
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat membuka WhatsApp';
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka WhatsApp: $e',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // === COLORFUL BLOBS ===
          // Blob 1: Violet (kiri atas)
          Positioned(
            top: -70,
            left: -50,
            child: _Blob(size: size.width * 0.68, color: AppColors.bgBlob1),
          ),
          // Blob 2: Sky blue (kanan atas)
          Positioned(
            top: -20,
            right: -60,
            child: _Blob(size: size.width * 0.50, color: AppColors.bgBlob4),
          ),
          // Blob 3: Mint green (tengah kiri)
          Positioned(
            top: size.height * 0.38,
            left: -70,
            child: _Blob(size: size.width * 0.45, color: AppColors.bgBlob3),
          ),
          // Blob 4: Coral/Rose (bawah kanan)
          Positioned(
            bottom: size.height * 0.10,
            right: -50,
            child: _Blob(size: size.width * 0.52, color: AppColors.bgBlob2),
          ),
          // Blob 5: Yellow (bawah kiri kecil)
          Positioned(
            bottom: -30,
            left: size.width * 0.25,
            child: _Blob(size: size.width * 0.32, color: AppColors.bgBlob5),
          ),

          // === KONTEN ===
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Get.back();
                      } else {
                        Get.offAllNamed(AppRoutes.homeVisitor);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppColors.textPrimary),
                    ),
                  ),

                  const SizedBox(height: 52),

                  // Title
                  Text(
                    'Selamat\nDatang Kembali',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -1,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk dengan NIM atau Email kamu',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Email field
                  _ColorfulTextField(
                    controller: _inputController,
                    hint: 'Email / NIM',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _inputError,
                    onChanged: (v) {
                      if (_inputError != null) setState(() => _inputError = _validateInput(v));
                      _clearServerError();
                    },
                  ),

                  const SizedBox(height: 14),

                  // Password field
                  _ColorfulTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: !_showPassword,
                    errorText: _passwordError,
                    onChanged: (v) {
                      if (_passwordError != null) setState(() => _passwordError = _validatePassword(v));
                      _clearServerError();
                    },
                    onSubmitted: (_) => _handleLogin(),
                    suffix: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),

                  // Forgot password
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: _launchWhatsApp,
                      child: Text(
                        'Forgot Password ?',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // Error banner
                  Obx(() {
                    final err = _authController.errorMessage.value;
                    if (err.isEmpty) return const SizedBox.shrink();
                    return _LoginErrorBanner(message: err);
                  }),

                  const SizedBox(height: 8),

                  // Log In button — gradient colorful
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,      // violet
                                AppColors.secondary,    // pink
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _authController.isLoading.value ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: _authController.isLoading.value
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                  )
                                : const Text(
                                    'Log In',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                  ),
                          ),
                        ),
                      )),

                  const SizedBox(height: 32),

                  Center(
                    child: Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === BLOB WIDGET ===
class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.55),
      ),
    );
  }
}

// === COLORFUL TEXT FIELD ===
class _ColorfulTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  const _ColorfulTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            autocorrect: false,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 14),
              prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
              suffixIcon: suffix,
              filled: false,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ],
    );
  }
}

// === ERROR BANNER ===
class _LoginErrorBanner extends StatelessWidget {
  final String message;
  const _LoginErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.error_outline_rounded;
    Color color = AppColors.danger;
    if (message.contains('nonaktif') || message.contains('Hubungi')) {
      icon = Icons.block_rounded;
      color = Colors.orange;
    } else if (message.contains('profil')) {
      icon = Icons.person_off_outlined;
      color = Colors.orange;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
