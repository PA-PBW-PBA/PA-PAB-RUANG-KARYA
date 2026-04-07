import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/gallery_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/event_card.dart';
import '../widgets/gallery_card.dart';
import '../widgets/division_badge.dart';
import '../widgets/member_bottom_nav.dart';
import '../../../core/theme/app_colors.dart';

class HomeMemberPage extends StatelessWidget {
  const HomeMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final eventController = Get.put(EventController());
    final galleryController = Get.put(GalleryController());

    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? 'Selamat Pagi'
        : hour < 15
            ? 'Selamat Siang'
            : hour < 18
                ? 'Selamat Sore'
                : 'Selamat Malam';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Image.asset(
              'assets/images/logo_mark.png',
              height: 28,
              errorBuilder: (_, __, ___) => Icon(
                Icons.palette_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            actions: [
              Obx(() => GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.profileMember),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15),
                        child: Text(
                          authController
                                      .currentUser.value?.fullName.isNotEmpty ==
                                  true
                              ? authController.currentUser.value!.fullName[0]
                                  .toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Obx(() => Text(
                        '$greeting, ${authController.currentUser.value?.fullName.split(' ').first ?? ''}!',
                        style: Theme.of(context).textTheme.headlineLarge,
                      )),
                  const SizedBox(height: 16),

                  // Member card — full width
                  Obx(() {
                    final user = authController.currentUser.value;
                    if (user == null) return const SizedBox.shrink();
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar inisial
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.nim,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Angkatan ${user.angkatan ?? '-'}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: user.divisions
                                      .map((d) => DivisionBadge(division: d))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Quick access — 6 item, 2 baris 3 kolom
                  Text(
                    'Akses Cepat',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  _quickAccessGrid(context),
                  const SizedBox(height: 24),

                  // Kegiatan mendatang
                  _sectionHeader(
                    context,
                    'Kegiatan Mendatang',
                    onSeeAll: () => Get.toNamed(AppRoutes.eventVisitor),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (eventController.events.isEmpty) {
                      return const SizedBox(height: 80);
                    }
                    return SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: eventController.events.take(5).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => SizedBox(
                          width: 260,
                          child: EventCard(event: eventController.events[i]),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Galeri terbaru
                  _sectionHeader(
                    context,
                    'Galeri Terbaru',
                    onSeeAll: () => Get.toNamed(AppRoutes.galleryMember),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (galleryController.gallery.isEmpty) {
                      return const SizedBox(height: 80);
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: galleryController.gallery.take(4).length,
                      itemBuilder: (_, i) => GalleryCard(
                        gallery: galleryController.gallery[i],
                      ),
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MemberBottomNav(currentIndex: 0),
    );
  }

  Widget _quickAccessGrid(BuildContext context) {
    // 6 item — 2 baris × 3 kolom
    final items = [
      {
        'icon': Icons.event_outlined,
        'label': 'Kegiatan',
        'route': AppRoutes.eventVisitor, // list event + search
        'color': AppColors.primary,
      },
      {
        'icon': Icons.calendar_month_outlined,
        'label': 'Jadwalku',
        'route': AppRoutes.eventMember, // halaman kalender
        'color': AppColors.secondary,
      },
      {
        'icon': Icons.checklist_outlined,
        'label': 'Absensi',
        'route': AppRoutes.attendanceHistory,
        'color': AppColors.accentGreen,
      },
      {
        'icon': Icons.photo_library_outlined,
        'label': 'Galeri',
        'route': AppRoutes.galleryMember,
        'color': AppColors.accentRed,
      },
      {
        'icon': Icons.people_outline,
        'label': 'Anggota',
        'route': AppRoutes.memberListReadonly, // list read-only
        'color': AppColors.primary,
      },
      {
        'icon': Icons.person_outline,
        'label': 'Profil',
        'route': AppRoutes.profileMember,
        'color': AppColors.secondary,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final color = item['color'] as Color;
        return GestureDetector(
          onTap: () => Get.toNamed(item['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2), width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['label'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'Lihat Semua',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
