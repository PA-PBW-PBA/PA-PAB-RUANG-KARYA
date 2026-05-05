import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/app_config_controller.dart';
import '../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

// ======================================================
// LOGIN PAGE — UI terpisah dari logic
// ======================================================
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

  // ======================================================
  // VALIDASI — per fungsi
  // ======================================================

  /// Validasi field NIM/Email: tidak boleh kosong, minimal 3 karakter
  String? _validateEmpty(String value) {
    if (value.trim().isEmpty) return 'NIM atau Email tidak boleh kosong';
    return null;
  }

  String? _validateMinLength(String value) {
    if (value.trim().length < 3) return 'Masukkan NIM atau Email yang valid';
    return null;
  }

  String? _validateInput(String value) {
    return _validateEmpty(value) ?? _validateMinLength(value);
  }

  /// Validasi password: tidak boleh kosong, minimal 6 karakter
  String? _validatePasswordEmpty(String value) {
    if (value.isEmpty) return 'Password tidak boleh kosong';
    return null;
  }

  String? _validatePasswordLength(String value) {
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  String? _validatePassword(String value) {
    return _validatePasswordEmpty(value) ?? _validatePasswordLength(value);
  }

  // ======================================================
  // AKSI
  // ======================================================

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
      Get.snackbar('Mohon tunggu', 'Sedang memuat data dari server...',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final phoneNumber = _configController.whatsappNumber.value;

    if (phoneNumber.isEmpty) {
      Get.snackbar(
          'Error',
          'Kontak admin tidak tersedia. Pastikan koneksi internet stabil.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
      return;
    }

    const message =
        'Halo Admin, saya lupa password akun saya. Nama: ,NIM: , DIVISI: .';
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse(
        'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat membuka aplikasi WhatsApp';
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka WhatsApp: $e',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    }
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Dekorasi lingkaran pastel di sudut
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.18),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentLime.withOpacity(0.15),
                ),
              ),
            ),
            // Konten utama
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // — Tombol Back (selalu tampil — kembali ke beranda visitor)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
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
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: AppColors.textPrimary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // — Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.25),
                          AppColors.secondary.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.palette_rounded,
                        color: AppColors.secondary, size: 32),
                  ),
                  const SizedBox(height: 28),

                  Text('Selamat Datang',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      )),
                  const SizedBox(height: 6),
                  Text('Masuk dengan NIM atau Email kamu',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      )),
                  const SizedBox(height: 36),

                  // — Field NIM/Email
                  TextField(
                    controller: _inputController,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) {
                      if (_inputError != null) {
                        setState(() => _inputError = _validateInput(v));
                      }
                      _clearServerError();
                    },
                    decoration: InputDecoration(
                      labelText: 'NIM atau Email',
                      hintText: 'Contoh: 2409116001 atau admin@ukm.id',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      errorText: _inputError,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // — Field Password
                  TextField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: (v) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = _validatePassword(v));
                      }
                      _clearServerError();
                    },
                    onSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Masukkan password kamu',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      errorText: _passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _launchWhatsApp,
                      child: Text('Lupa password?',
                          style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),

                  // — Error dari server
                  Obx(() {
                    final err = _authController.errorMessage.value;
                    if (err.isEmpty) return const SizedBox.shrink();
                    return _LoginErrorBanner(message: err);
                  }),

                  const SizedBox(height: 8),

                  // — Tombol Masuk
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _authController.isLoading.value
                              ? null
                              : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: _authController.isLoading.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white),
                                )
                              : const Text('Masuk',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                        ),
                      )),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// WIDGET BANNER ERROR LOGIN
// ======================================================
class _LoginErrorBanner extends StatelessWidget {
  final String message;
  const _LoginErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData icon = Icons.error_outline_rounded;
    Color color = colorScheme.error;

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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
