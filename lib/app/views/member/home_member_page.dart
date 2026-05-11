import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/gallery_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/event_card.dart';
import '../widgets/gallery_card.dart';
import '../widgets/member_bottom_nav.dart';
import '../widgets/division_badge.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class HomeMemberPage extends StatelessWidget {
  const HomeMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final eventController = Get.put(EventController());
    final galleryController = Get.put(GalleryController());
    final theme = Theme.of(context);

    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? 'Selamat Pagi'
        : hour < 15
            ? 'Selamat Siang'
            : hour < 18
                ? 'Selamat Sore'
                : 'Selamat Malam';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            floating: true,
            pinned: false,
            elevation: 0,
            backgroundColor: AppColors.background,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/images/logo_mark.png',
                    height: 28,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.palette_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Seni & Kreativitas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Obx(() => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.profileMember),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary.withOpacity(0.05),
                          child: Text(
                            authController.currentUser.value?.fullName
                                        .isNotEmpty ==
                                    true
                                ? authController.currentUser.value!.fullName[0]
                                    .toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${authController.currentUser.value?.fullName.split(' ').first ?? 'Anggota'}!',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 32),
                  _buildPremiumMemberCard(context, authController),
                  const SizedBox(height: 40),
                  _buildSectionHeader(
                    context,
                    title: 'Akses Cepat',
                    subtitle: 'Layanan UKM untuk kamu',
                    accentColor: AppColors.accentPurple,
                  ),
                  const SizedBox(height: 16),
                  _buildModernQuickAccess(context),
                  const SizedBox(height: 40),
                  _buildSectionHeader(
                    context,
                    title: 'Kegiatan Mendatang',
                    subtitle: 'Jangan lewatkan keseruannya',
                    accentColor: AppColors.accentPink,
                    onSeeAll: () {
                      eventController.resetFilters();
                      Get.toNamed(AppRoutes.eventMember);
                    },
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (eventController.events.isEmpty) {
                      return _buildEmptyState('Belum ada kegiatan mendatang');
                    }
                    return SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        physics: const BouncingScrollPhysics(),
                        itemCount: eventController.events.take(5).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 20),
                        itemBuilder: (_, i) => Container(
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.06),
                                blurRadius: 15,
                                spreadRadius: 1,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: EventCard(event: eventController.events[i]),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                  _buildSectionHeader(
                    context,
                    title: 'Galeri Karya',
                    subtitle: 'Inspirasi dari rekan-rekanmu',
                    accentColor: AppColors.accentOrange,
                    onSeeAll: () => Get.toNamed(AppRoutes.galleryMember),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (galleryController.gallery.isEmpty) {
                      return _buildEmptyState('Galeri masih kosong');
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 20),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: galleryController.gallery.take(4).length,
                      itemBuilder: (_, i) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child:
                            GalleryCard(gallery: galleryController.gallery[i]),
                      ),
                    );
                  }),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MemberBottomNav(currentIndex: 0),
    );
  }

  Widget _buildPremiumMemberCard(
      BuildContext context, AuthController authController) {
    return Obx(() {
      final user = authController.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: AppColors.secondary.withOpacity(0.1),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.accentPink.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'MEMBER DIGITAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.nim,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildCardStat('ANGKATAN', user.angkatan ?? '-'),
                      const SizedBox(width: 32),
                      Expanded(
                        child: DivisionChipRow(
                          divisions: user.divisions,
                          maxVisible: 2,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCardStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildModernQuickAccess(BuildContext context) {
    final items = [
      {
        'icon': Icons.event_available_rounded,
        'label': 'Kegiatan',
        'route': AppRoutes.eventMember,
        'color': AppColors.accentPink,
      },
      {
        'icon': Icons.assignment_turned_in_rounded,
        'label': 'Absensi',
        'route': AppRoutes.attendanceHistory,
        'color': AppColors.success,
      },
      {
        'icon': Icons.collections_rounded,
        'label': 'Galeri',
        'route': AppRoutes.galleryMember,
        'color': AppColors.accentOrange,
      },
      {
        'icon': Icons.groups_rounded,
        'label': 'Anggota',
        'route': AppRoutes.memberListReadonly,
        'color': AppColors.secondary,
      },
      {
        'icon': Icons.manage_accounts_rounded,
        'label': 'Profil',
        'route': AppRoutes.profileMember,
        'color': AppColors.accentPurple,
      },
      {
        'icon': Icons.info_outline_rounded,
        'label': 'Divisi',
        'route': AppRoutes.divisionInfo,
        'color': AppColors.accentYellow,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final color = item['color'] as Color;
        return InkWell(
          onTap: () => Get.toNamed(item['route'] as String),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.24),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: color.withOpacity(0.22), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(item['icon'] as IconData, color: color, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  item['label'] as String,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color accentColor,
    VoidCallback? onSeeAll,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 22),
              child: Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.divider.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
              color: AppColors.textSecondary, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

