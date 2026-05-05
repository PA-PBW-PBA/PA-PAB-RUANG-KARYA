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
        'icon': Icons.home_outlined,
        'label': 'Beranda',
        'route': AppRoutes.dashboardAdmin,
        'requiresKas': false,
      },
      {
        'icon': Icons.people_outline,
        'label': 'Anggota',
        'route': AppRoutes.memberList,
        'requiresKas': false,
      },
      {
        'icon': Icons.event_outlined,
        'label': 'Kegiatan',
        'route': AppRoutes.eventList,
        'requiresKas': false,
      },
      {
        'icon': Icons.photo_library_outlined,
        'label': 'Galeri',
        'route': AppRoutes.galleryAdmin,
        'requiresKas': false,
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Kas',
        'route': AppRoutes.kasPage,
        'requiresKas': true,
      },
      {
        'icon': Icons.person_outline,
        'label': 'Profil',
        'route': AppRoutes.profileAdmin,
        'requiresKas': false,
      },
    ];

    // Filter: BPH tidak melihat item Kas
    final items = allItems
        .where((item) => !(item['requiresKas'] as bool) || canManageKas)
        .toList();

    // Hitung ulang index aktif berdasarkan route saat ini
    final currentRoute = Get.currentRoute;
    int activeIndex = items.indexWhere(
      (item) => item['route'] == currentRoute,
    );
    if (activeIndex < 0) activeIndex = currentIndex;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
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
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 10 : 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 20,
                    color: isActive
                        ? AppColors.textPrimary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 4),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
