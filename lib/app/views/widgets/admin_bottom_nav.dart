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

    final allItems = [
      {
        'icon': Icons.dashboard_rounded,
        'label': 'Beranda',
        'route': AppRoutes.dashboardAdmin,
        'requiresKas': false,
      },
      {
        'icon': Icons.groups_rounded,
        'label': 'Anggota',
        'route': AppRoutes.memberList,
        'requiresKas': false,
      },
      {
        'icon': Icons.event_note_rounded,
        'label': 'Kegiatan',
        'route': AppRoutes.eventList,
        'requiresKas': false,
      },
      {
        'icon': Icons.auto_awesome_motion_rounded,
        'label': 'Galeri',
        'route': AppRoutes.galleryAdmin,
        'requiresKas': false,
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': 'Kas',
        'route': AppRoutes.kasPage,
        'requiresKas': true,
      },
      {
        'icon': Icons.person_rounded,
        'label': 'Profil',
        'route': AppRoutes.profileAdmin,
        'requiresKas': false,
      },
    ];

    final items = allItems
        .where((item) => !(item['requiresKas'] as bool) || canManageKas)
        .toList();

    final currentRoute = Get.currentRoute;
    int activeIndex = items.indexWhere((item) => item['route'] == currentRoute);
    if (activeIndex < 0) activeIndex = currentIndex;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isActive = i == activeIndex;

          return GestureDetector(
            onTap: () {
              if (!isActive) {
                Get.offAllNamed(item['route'] as String);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutExpo,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 10 : 8,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 20,
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                  if (isActive && MediaQuery.of(context).size.width > 380) ...[
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

