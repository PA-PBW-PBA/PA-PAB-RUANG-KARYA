import 'dart:ui';
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
      {'icon': Icons.home_rounded, 'label': 'Home', 'route': AppRoutes.homeMember, 'color': AppColors.primary},
      {'icon': Icons.event_note_rounded, 'label': 'Kegiatan', 'route': AppRoutes.eventMember, 'color': AppColors.accentTeal},
      {'icon': Icons.auto_awesome_motion_rounded, 'label': 'Galeri', 'route': AppRoutes.galleryMember, 'color': AppColors.secondary},
      {'icon': Icons.person_rounded, 'label': 'Profil', 'route': AppRoutes.profileMember, 'color': AppColors.accentOrange},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                final isActive = i == currentIndex;
                final activeColor = item['color'] as Color;

                return GestureDetector(
                  onTap: () {
                    if (!isActive) Get.offAllNamed(item['route'] as String);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutExpo,
                    padding: EdgeInsets.symmetric(
                      horizontal: isActive ? 20 : 12,
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
                          size: 22,
                          color: isActive ? Colors.white : AppColors.textSecondary.withOpacity(0.5),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Text(
                            item['label'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
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
