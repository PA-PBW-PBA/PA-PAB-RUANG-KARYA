import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _authController = Get.find<AuthController>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  String? _newPassError;
  String? _confirmPassError;

  // Apakah ini first login (dari route langsung) atau ganti password dari profil
  bool get _isFirstLogin =>
      _authController.currentUser.value?.isFirstLogin ?? false;

  // Izinkan printable ASCII saja
  static final _validPasswordChars = RegExp(r'^[\x20-\x7E]+$');

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Password baru tidak boleh kosong';
    if (v.length < 8) return 'Password minimal 8 karakter';
    if (!_validPasswordChars.hasMatch(v)) {
      return 'Password mengandung karakter tidak valid';
    }
    return null;
  }

  String? _validateConfirmPassword(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
    if (v != _newPasswordController.text.trim()) return 'Password tidak cocok';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _isFirstLogin
          ? null
          : AppBar(
              title: const Text('Ganti Password'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Get.back(),
              ),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                _isFirstLogin ? 'Buat Password Baru' : 'Ganti Password',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _isFirstLogin
                    ? 'Ini login pertamamu. Buat password baru untuk keamanan akunmu.'
                    : 'Masukkan password lama dan password baru kamu.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 32),

              // Password lama — hanya tampil saat bukan first login
              if (!_isFirstLogin) ...[
                TextField(
                  controller: _currentPasswordController,
                  obscureText: !_showCurrentPassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: 'Password Saat Ini',
                    hintText: 'Masukkan password lama',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(
                          () => _showCurrentPassword = !_showCurrentPassword),
                      child: Icon(
                        _showCurrentPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Password baru
              TextField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (v) =>
                    setState(() => _newPassError = _validateNewPassword(v)),
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  hintText: 'Minimal 8 karakter',
                  errorText: _newPassError,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _showNewPassword = !_showNewPassword),
                    child: Icon(
                      _showNewPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Konfirmasi password baru
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (v) => setState(
                    () => _confirmPassError = _validateConfirmPassword(v)),
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  hintText: 'Ulangi password baru',
                  errorText: _confirmPassError,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword),
                    child: Icon(
                      _showConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),

              // Error dari controller
              Obx(() {
                if (_authController.errorMessage.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: colorScheme.error.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 16, color: colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _authController.errorMessage.value,
                            style: TextStyle(
                                color: colorScheme.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 32),

              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authController.isLoading.value
                          ? null
                          : _handleSubmit,
                      child: _authController.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Simpan Password'),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    final newPassErr = _validateNewPassword(_newPasswordController.text);
    final confirmErr =
        _validateConfirmPassword(_confirmPasswordController.text);

    setState(() {
      _newPassError = newPassErr;
      _confirmPassError = confirmErr;
    });

    if (newPassErr != null || confirmErr != null) return;

    // Jika bukan first login, cek password lama tidak kosong
    if (!_isFirstLogin && _currentPasswordController.text.trim().isEmpty) {
      _authController.errorMessage.value =
          'Masukkan password saat ini terlebih dahulu';
      return;
    }

    _authController.changePassword(_newPasswordController.text.trim());
  }
}
