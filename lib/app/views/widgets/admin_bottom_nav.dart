import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    final canManageKas = user?.canManageKas ?? false;

    // Bottom bar hanya 3 item utama; Anggota, Galeri & Kas ada di Quick Access dashboard
    final allItems = [
      {'icon': Icons.dashboard_rounded, 'label': 'Beranda', 'route': AppRoutes.dashboardAdmin, 'requiresKas': false, 'color': AppColors.primary},
      {'icon': Icons.event_note_rounded, 'label': 'Kegiatan', 'route': AppRoutes.eventList, 'requiresKas': false, 'color': AppColors.accentTeal},
      {'icon': Icons.person_rounded, 'label': 'Profil', 'route': AppRoutes.profileAdmin, 'requiresKas': false, 'color': AppColors.accentOrange},
    ];

    final items = allItems
        .where((item) => !(item['requiresKas'] as bool) || canManageKas)
        .toList();

    final currentRoute = Get.currentRoute;
    int activeIndex = items.indexWhere((item) => item['route'] == currentRoute);
    if (activeIndex < 0) activeIndex = currentIndex;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: Colors.white.withOpacity(0.55), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isActive = i == activeIndex;
                final activeColor = item['color'] as Color;

                return GestureDetector(
                  onTap: () {
                    if (!isActive) Get.offAllNamed(item['route'] as String);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutExpo,
                    padding: EdgeInsets.symmetric(
                      horizontal: isActive ? 14 : 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? activeColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: activeColor.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 20,
                          color: isActive ? Colors.white : AppColors.textSecondary.withOpacity(0.5),
                        ),
                        if (isActive && MediaQuery.of(context).size.width > 380) ...[
                          const SizedBox(width: 6),
                          Text(
                            item['label'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
