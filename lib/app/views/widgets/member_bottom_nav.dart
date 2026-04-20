import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class MemberBottomNav extends StatelessWidget {
  final int currentIndex;

  const MemberBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.home_outlined,
        'label': 'Home',
        'route': AppRoutes.homeMember,
      },
      {
        'icon': Icons.event_outlined,
        'label': 'Kegiatan',
        'route': AppRoutes.eventMember,
      },
      {
        'icon': Icons.photo_library_outlined,
        'label': 'Galeri',
        'route': AppRoutes.galleryMember,
      },
      {
        'icon': Icons.person_outline,
        'label': 'Profil',
        'route': AppRoutes.profileMember,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
          final isActive = i == currentIndex;

          return GestureDetector(
            onTap: () {
              if (!isActive) {
                Get.offAllNamed(item['route'] as String);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 16 : 12,
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
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
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
