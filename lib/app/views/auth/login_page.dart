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
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi untuk buka WhatsApp
  Future<void> _launchWhatsApp() async {
    if (_configController.isLoading.value) {
      Get.snackbar("Mohon tunggu", "Sedang memuat data dari server...",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final phoneNumber = _configController.whatsappNumber.value;

    if (phoneNumber.isEmpty) {
      Get.snackbar("Error", "Kontak admin tidak tersedia.",
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    final message =
        "Halo Admin, saya lupa password akun saya. Mohon dibantu reset password.";
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse(
        "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Gagal membuka WhatsApp",
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    }
  }

  void _handleLogin() {
    // Sederhana: Panggil fungsi login di AuthController Anda
    _authController.login(
        _inputController.text.trim(), _passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Text('Selamat Datang',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              // Input Fields
              TextField(
                controller: _inputController,
                decoration: const InputDecoration(
                    labelText: 'NIM atau Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),

              // Lupa Password Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _launchWhatsApp,
                  child: const Text('Lupa password?'),
                ),
              ),

              const SizedBox(height: 20),

              // Login Button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _authController.isLoading.value ? null : _handleLogin,
                      child: _authController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Masuk'),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
