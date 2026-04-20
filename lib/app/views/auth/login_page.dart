import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
<<<<<<< HEAD

import '../../controllers/auth_controller.dart';
import '../../controllers/app_config_controller.dart';
import '../../routes/app_routes.dart';
=======
import '../../controllers/auth_controller.dart';
import '../../controllers/app_config_controller.dart';
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
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
    if (_configController.isLoading.value) {
<<<<<<< HEAD
      Get.snackbar(
        'Mohon tunggu',
        'Sedang memuat data dari server...',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final phoneNumber = _configController.whatsappNumber.value;
    if (phoneNumber.isEmpty) {
      Get.snackbar(
        'Error',
        'Kontak admin tidak tersedia.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

=======
      Get.snackbar('Mohon tunggu', 'Sedang memuat data dari server...',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final phoneNumber = _configController.whatsappNumber.value;
    if (phoneNumber.isEmpty) {
      Get.snackbar('Error', 'Kontak admin tidak tersedia.',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
    const message =
        'Halo Admin, saya lupa password akun saya. Mohon dibantu reset password.';
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse(
<<<<<<< HEAD
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Gagal membuka WhatsApp',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
=======
        'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Gagal membuka WhatsApp',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
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
<<<<<<< HEAD

=======
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
    setState(() {
      _inputError = inputErr;
      _passwordError = passErr;
    });
<<<<<<< HEAD

    if (inputErr != null || passErr != null) return;

    _authController.login(
      _inputController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  void _goToVisitorHome() {
    Get.offAllNamed(AppRoutes.homeVisitor);
=======
    if (inputErr != null || passErr != null) return;

    _authController.login(
        _inputController.text.trim(), _passwordController.text.trim());
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final isDesktop = width >= 1024;
        final isTablet = width >= 600 && width < 1024;
        final isMobile = width < 600;

        final pagePadding = isDesktop ? 28.0 : 20.0;
        final headerHeight = isDesktop ? 205.0 : (isTablet ? 195.0 : 180.0);
        final logoSize = isDesktop ? 104.0 : (isTablet ? 96.0 : 88.0);
        final cardMaxWidth = isDesktop ? 500.0 : (isTablet ? 470.0 : 460.0);

        final logoTop = headerHeight - (logoSize / 2) - 98;
        final cardTopSpacing = 14.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: headerHeight,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFF9D423),
                                  Color(0xFF7ED957),
                                  Color(0xFF47C1E8),
                                  Color(0xFFF54291),
                                ],
                                stops: [0.0, 0.28, 0.62, 1.0],
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: HeaderWavePainter(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF6F7FB),
                      ),
                    ),
                  ],
                ),

                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: height),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: pagePadding),
                        child: Column(
                          children: [
                            SizedBox(height: logoTop),

                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: logoSize,
                                height: logoSize,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF54291)
                                          .withOpacity(0.10),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/logo_mark.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            SizedBox(height: cardTopSpacing),

                            Align(
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: cardMaxWidth,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(
                                    isMobile ? 22 : 30,
                                    isMobile ? 26 : 28,
                                    isMobile ? 22 : 30,
                                    isMobile ? 24 : 28,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.07),
                                        blurRadius: 28,
                                        offset: const Offset(0, 16),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'UKM Seni & Kreativitas',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          fontSize: isDesktop
                                              ? 26
                                              : isTablet
                                                  ? 24
                                                  : 22,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF2E3860),
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Masuk untuk melanjutkan ke Ruang Karya',
                                        textAlign: TextAlign.center,
                                        style:
                                            theme.textTheme.bodyMedium?.copyWith(
                                          fontSize: isMobile ? 14 : 15,
                                          color: AppColors.textSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 26),

                                      _buildInputField(
                                        controller: _inputController,
                                        hintText: 'NIM atau Email',
                                        icon: Icons.person_outline_rounded,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        errorText: _inputError,
                                        onChanged: (v) {
                                          if (_inputError != null) {
                                            setState(() {
                                              _inputError = _validateInput(v);
                                            });
                                          }
                                          if (_authController
                                              .errorMessage.value.isNotEmpty) {
                                            _authController.errorMessage.value =
                                                '';
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 20),

                                      _buildInputField(
                                        controller: _passwordController,
                                        hintText: 'Password',
                                        icon: Icons.lock_outline_rounded,
                                        obscureText: !_showPassword,
                                        errorText: _passwordError,
                                        onChanged: (v) {
                                          if (_passwordError != null) {
                                            setState(() {
                                              _passwordError =
                                                  _validatePassword(v);
                                            });
                                          }
                                          if (_authController
                                              .errorMessage.value.isNotEmpty) {
                                            _authController.errorMessage.value =
                                                '';
                                          }
                                        },
                                        onSubmitted: (_) => _handleLogin(),
                                        suffix: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _showPassword = !_showPassword;
                                            });
                                          },
                                          icon: Icon(
                                            _showPassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: const Color(0xFF8F96AE),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: _launchWhatsApp,
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(0, 0),
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                          child: const Text(
                                            'Lupa password?',
                                            style: TextStyle(
                                              color: Color(0xFFF54291),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      Obx(() {
                                        final err =
                                            _authController.errorMessage.value;
                                        if (err.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        IconData errIcon =
                                            Icons.error_outline_rounded;
                                        Color errColor = Theme.of(context)
                                            .colorScheme
                                            .error;

                                        if (err.contains('nonaktif') ||
                                            err.contains('Hubungi')) {
                                          errIcon = Icons.block_rounded;
                                          errColor = Colors.orange;
                                        } else if (err.contains('profil')) {
                                          errIcon =
                                              Icons.person_off_outlined;
                                          errColor = Colors.orange;
                                        }

                                        return Container(
                                          width: double.infinity,
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: errColor.withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color:
                                                  errColor.withOpacity(0.22),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(errIcon,
                                                  color: errColor, size: 20),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  err,
                                                  style: TextStyle(
                                                    color: errColor,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),

                                      Obx(
                                        () => SizedBox(
                                          width: double.infinity,
                                          height: 56,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: const Color(0xFFA195F8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFA195F8)
                                                      .withOpacity(0.28),
                                                  blurRadius: 18,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton.icon(
                                              onPressed:
                                                  _authController.isLoading.value
                                                      ? null
                                                      : _handleLogin,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor:
                                                    Colors.transparent,
                                                disabledBackgroundColor:
                                                    Colors.transparent,
                                                shape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              icon: _authController
                                                      .isLoading.value
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2.4,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.login_rounded,
                                                      color: Colors.white,
                                                    ),
                                              label: Text(
                                                _authController.isLoading.value
                                                    ? 'Loading...'
                                                    : 'Login',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: isMobile ? 24 : 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 16,
                  left: pagePadding,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.28),
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 22,
                        onPressed: _goToVisitorHome, 
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? errorText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions: !obscureText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF3D4767),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xFFF9FAFD),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFB3BAD0),
        ),
        suffixIcon: suffix,
        hintStyle: const TextStyle(
          color: Color(0xFF8D95AE),
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE1E5F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFF54291),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
=======
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
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
          ),
        ),
      ),
    );
  }
}
<<<<<<< HEAD

class HeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()
      ..color = const Color(0xFFF6F7FB)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.88);

    path.cubicTo(
      size.width * 0.20,
      size.height * 0.80,
      size.width * 0.40,
      size.height * 0.84,
      size.width * 0.58,
      size.height * 0.86,
    );

    path.cubicTo(
      size.width * 0.76,
      size.height * 0.88,
      size.width * 0.90,
      size.height * 0.84,
      size.width,
      size.height * 0.76,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
=======
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
