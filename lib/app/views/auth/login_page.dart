import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/app_config_controller.dart';
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

  Future<void> _launchWhatsApp() async {
    // 1. Cek apakah masih loading
    if (_configController.isLoading.value) {
      Get.snackbar('Mohon tunggu', 'Sedang memuat data dari server...',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // 2. Ambil nomor dari controller
    final phoneNumber = _configController.whatsappNumber.value;

    // 3. Validasi apakah nomor tersedia
    if (phoneNumber.isEmpty) {
      Get.snackbar('Error',
          'Kontak admin tidak tersedia. Pastikan koneksi internet stabil.',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    // 4. Siapkan pesan dan URL
    const message =
        'Halo Admin, saya lupa password akun saya. Nama: ,NIM: , DIVISI: .';
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse(
        'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');

    // 5. Coba buka WhatsApp
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

  String? _validateInput(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'NIM atau Email tidak boleh kosong';
    if (v.length < 3) return 'Masukkan NIM atau Email yang valid';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.palette_rounded,
                    color: colorScheme.primary, size: 32),
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
              TextField(
                controller: _inputController,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) {
                  if (_inputError != null) {
                    setState(() => _inputError = _validateInput(v));
                  }
                  if (_authController.errorMessage.value.isNotEmpty) {
                    _authController.errorMessage.value = '';
                  }
                },
                decoration: InputDecoration(
                  labelText: 'NIM atau Email',
                  hintText: 'Contoh: 2409116001 atau admin@ukm.id',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  errorText: _inputError,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (v) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = _validatePassword(v));
                  }
                  if (_authController.errorMessage.value.isNotEmpty) {
                    _authController.errorMessage.value = '';
                  }
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
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
              Obx(() {
                final err = _authController.errorMessage.value;
                if (err.isEmpty) return const SizedBox.shrink();

                IconData errIcon = Icons.error_outline_rounded;
                Color errColor = colorScheme.error;

                if (err.contains('nonaktif') || err.contains('Hubungi')) {
                  errIcon = Icons.block_rounded;
                  errColor = Colors.orange;
                } else if (err.contains('profil')) {
                  errIcon = Icons.person_off_outlined;
                  errColor = Colors.orange;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: errColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: errColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(errIcon, color: errColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(err,
                            style: TextStyle(
                                color: errColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          _authController.isLoading.value ? null : _handleLogin,
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
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('Masuk',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
