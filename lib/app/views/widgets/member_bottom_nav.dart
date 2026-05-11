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
        'icon': Icons.home_rounded,
        'activeIcon': Icons.home_rounded,
        'label': 'Home',
        'route': AppRoutes.homeMember,
      },
      {
        'icon': Icons.event_note_rounded,
        'activeIcon': Icons.event_note_rounded,
        'label': 'Kegiatan',
        'route': AppRoutes.eventMember,
      },
      {
        'icon': Icons.auto_awesome_motion_rounded,
        'activeIcon': Icons.auto_awesome_motion_rounded,
        'label': 'Galeri',
        'route': AppRoutes.galleryMember,
      },
      {
        'icon': Icons.person_rounded,
        'activeIcon': Icons.person_rounded,
        'label': 'Profil',
        'route': AppRoutes.profileMember,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          final isActive = i == currentIndex;

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
                horizontal: isActive ? 12 : 8,
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
                    (isActive ? item['activeIcon'] : item['icon']) as IconData,
                    size: 24,
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                  if (isActive && MediaQuery.of(context).size.width > 380) ...[
                    const SizedBox(width: 8),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
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

