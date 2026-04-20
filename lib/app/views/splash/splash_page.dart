import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import '../visitor/home_visitor_page.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _floatController;
  late final AnimationController _breathController;
  late final AnimationController _rotateController;

  late final Animation<double> _logoScaleIn;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _logoRotation;
  late final Animation<double> _breathScale;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb) {
        FlutterNativeSplash.remove();
      }
    });

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
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
      duration: const Duration(milliseconds: 2200),
    );

    _logoScaleIn = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );

    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.10, 0.60, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.45, 0.95, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.08, end: 0.0).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.easeOutBack,
      ),
    );

    _breathScale = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    _introController.forward();
    _rotateController.forward();

    _timer = Timer(const Duration(milliseconds: 3600), () {
      if (!mounted) return;
      Get.offAll(
        () => const HomeVisitorPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _introController,
          _floatController,
          _breathController,
          _rotateController,
        ]),
        builder: (context, child) {
          final wave = math.sin(_floatController.value * math.pi);
          final wave2 = math.cos(_floatController.value * math.pi * 2);

          final floatY = wave * 12;
          final floatX = wave2 * 7;

          return Stack(
            children: [
              Positioned(
                top: -60 + floatY,
                right: -20,
                child: _softBlob(
                  size: 230,
                  color: const Color(0xFFEDE9FE).withOpacity(0.85),
                ),
              ),
              Positioned(
                top: 120 - floatY,
                left: -45 + floatX,
                child: _softBlob(
                  size: 145,
                  color: const Color(0xFFDCE7FF).withOpacity(0.80),
                ),
              ),
              Positioned(
                bottom: -45 + floatY,
                left: -10,
                child: _softBlob(
                  size: 175,
                  color: const Color(0xFFF5E8FF).withOpacity(0.86),
                ),
              ),
              Positioned(
                bottom: 120 - floatY,
                right: -26 - floatX,
                child: _softBlob(
                  size: 118,
                  color: const Color(0xFFE9F7EF).withOpacity(0.72),
                ),
              ),

              Positioned(
                top: 170 + floatY,
                left: 70 + floatX,
                child: _sparkle(
                  icon: Icons.auto_awesome_rounded,
                  size: 18,
                  color: const Color(0xFFB7B3F6).withOpacity(0.70),
                ),
              ),
              Positioned(
                top: 250 - floatY,
                right: 88,
                child: _sparkle(
                  icon: Icons.star_rounded,
                  size: 12,
                  color: const Color(0xFFD8B4FE).withOpacity(0.65),
                ),
              ),
              Positioned(
                bottom: 210 + floatY,
                left: 96,
                child: _sparkle(
                  icon: Icons.circle,
                  size: 8,
                  color: const Color(0xFFA5B4FC).withOpacity(0.55),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(0, -floatY * 0.35),
                        child: FadeTransition(
                          opacity: _logoOpacity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              FadeTransition(
                                opacity: _glowOpacity,
                                child: Container(
                                  width: 182,
                                  height: 182,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFFB7B3F6).withOpacity(0.30),
                                        const Color(0xFFB7B3F6).withOpacity(0.02),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              ScaleTransition(
                                scale: _logoScaleIn,
                                child: ScaleTransition(
                                  scale: _breathScale,
                                  child: RotationTransition(
                                    turns: _logoRotation,
                                    child: Container(
                                      width: 136,
                                      height: 136,
                                      padding: const EdgeInsets.all(22),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFB7B3F6)
                                                .withOpacity(0.25),
                                            blurRadius: 30,
                                            offset: const Offset(0, 14),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        'assets/images/logo_mark.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeTransition(
                        opacity: _textOpacity,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              Text(
                                'Ruang Karya',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF27314D),
                                      letterSpacing: -0.6,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'UKM Seni & Kreativitas',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: const Color(0xFF7B859C),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 34),
                      FadeTransition(
                        opacity: _textOpacity,
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            color: const Color(0xFF8A7CFF),
                            backgroundColor:
                                const Color(0xFF8A7CFF).withOpacity(0.12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _softBlob({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _sparkle({
    required IconData icon,
    required double size,
    required Color color,
  }) {
    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}