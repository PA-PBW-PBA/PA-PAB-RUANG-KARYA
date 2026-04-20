import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _floatController;
  late final AnimationController _breathController;
  late final AnimationController _rotateController;
  late final AnimationController _shimmerController;

  late final Animation<double> _logoScaleIn;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _logoRotation;
  late final Animation<double> _breathScale;
  late final Animation<double> _shimmer;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb) FlutterNativeSplash.remove();
    });

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _logoScaleIn = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.10, 0.65, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.50, 1.0, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.50, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.06, end: 0.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOutBack),
    );

    _breathScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _introController.forward();
    _rotateController.forward();

    // Navigate setelah animasi selesai — data fetch dilakukan oleh binding
    // di homeVisitor, bukan di sini, sehingga UI render terlebih dahulu.
    _timer = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      Get.offAllNamed(
        AppRoutes.homeVisitor,
        // transition bawaan GetX (fadeIn)
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _introController.dispose();
    _floatController.dispose();
    _breathController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _introController,
          _floatController,
          _breathController,
          _rotateController,
          _shimmerController,
        ]),
        builder: (context, _) {
          final wave = math.sin(_floatController.value * math.pi);
          final wave2 = math.cos(_floatController.value * math.pi * 2);
          final floatY = wave * 12.0;
          final floatX = wave2 * 7.0;

          return Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0EEFF),
                  Color(0xFFF6F7FB),
                  Color(0xFFEDF4FF),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // ── Background blobs ──────────────────────────────
                Positioned(
                  top: -70 + floatY,
                  right: -30,
                  child: _blob(220, const Color(0xFFDDD8FF), 0.75),
                ),
                Positioned(
                  top: 110 - floatY,
                  left: -50 + floatX,
                  child: _blob(140, const Color(0xFFCFDFFF), 0.65),
                ),
                Positioned(
                  bottom: -50 + floatY,
                  left: -15,
                  child: _blob(170, const Color(0xFFEEDFFF), 0.72),
                ),
                Positioned(
                  bottom: 110 - floatY,
                  right: -30 - floatX,
                  child: _blob(110, const Color(0xFFD4F0E8), 0.60),
                ),

                // ── Decorative dots ───────────────────────────────
                Positioned(
                  top: 180 + floatY,
                  left: 60 + floatX,
                  child: _dot(Icons.auto_awesome_rounded, 20,
                      const Color(0xFFADA6F5), 0.65),
                ),
                Positioned(
                  top: 260 - floatY,
                  right: 80,
                  child: _dot(Icons.star_rounded, 13,
                      const Color(0xFFCFB4FE), 0.60),
                ),
                Positioned(
                  bottom: 220 + floatY,
                  left: 90,
                  child: _dot(Icons.circle, 9,
                      const Color(0xFF93C5FD), 0.50),
                ),
                Positioned(
                  bottom: 160 - floatY,
                  right: 55 + floatX,
                  child: _dot(Icons.lens_rounded, 6,
                      const Color(0xFFA7F3D0), 0.45),
                ),

                // ── Center content ────────────────────────────────
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Transform.translate(
                          offset: Offset(0, -floatY * 0.4),
                          child: FadeTransition(
                            opacity: _logoOpacity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow ring
                                FadeTransition(
                                  opacity: _glowOpacity,
                                  child: Container(
                                    width: 196,
                                    height: 196,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFF8A7CFF)
                                              .withOpacity(0.22),
                                          const Color(0xFF8A7CFF)
                                              .withOpacity(0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Inner pulse ring
                                ScaleTransition(
                                  scale: _breathScale,
                                  child: Container(
                                    width: 158,
                                    height: 158,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF8A7CFF)
                                            .withOpacity(0.15),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                // Logo card
                                ScaleTransition(
                                  scale: _logoScaleIn,
                                  child: ScaleTransition(
                                    scale: _breathScale,
                                    child: RotationTransition(
                                      turns: _logoRotation,
                                      child: _logoCard(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Text block
                        FadeTransition(
                          opacity: _textOpacity,
                          child: SlideTransition(
                            position: _textSlide,
                            child: Column(
                              children: [
                                // Title with shimmer
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: const [
                                      Color(0xFF27314D),
                                      Color(0xFF8A7CFF),
                                      Color(0xFF27314D),
                                    ],
                                    stops: [
                                      (_shimmer.value - 0.6)
                                          .clamp(0.0, 1.0),
                                      _shimmer.value.clamp(0.0, 1.0),
                                      (_shimmer.value + 0.6)
                                          .clamp(0.0, 1.0),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    'Ruang Karya',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.8,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8A7CFF)
                                        .withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF8A7CFF)
                                          .withOpacity(0.20),
                                    ),
                                  ),
                                  child: Text(
                                    'UKM Seni & Kreativitas',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: const Color(0xFF6B5FE4),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Loading indicator
                        FadeTransition(
                          opacity: _textOpacity,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: const Color(0xFF8A7CFF),
                                  backgroundColor:
                                      const Color(0xFF8A7CFF).withOpacity(0.12),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Memuat...',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF8A7CFF)
                                          .withOpacity(0.70),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _logoCard() {
    return Container(
      width: 130,
      height: 130,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A7CFF).withOpacity(0.28),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo_mark.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _dot(IconData icon, double size, Color color, double opacity) {
    return Icon(icon, size: size, color: color.withOpacity(opacity));
  }
}
