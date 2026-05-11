import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/gallery_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/event_card.dart';
import '../widgets/gallery_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class HomeVisitorPage extends StatelessWidget {
  const HomeVisitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    final galleryController = Get.find<GalleryController>();
    final theme = Theme.of(context);

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
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  icon: const Icon(Icons.login_rounded, color: AppColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildCreativeHero(context),
                  const SizedBox(height: 40),
                  _buildSectionHeader(
                    context,
                    title: 'Kegiatan Terdekat',
                    subtitle: 'Eksplorasi kegiatan bersama kami',
                    accentColor: AppColors.accentPink,
                    onSeeAll: () {
                      eventController.resetFilters();
                      Get.toNamed(AppRoutes.eventVisitor);
                    },
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (eventController.isLoading.value) {
                      return _buildShimmerPlaceholder();
                    }
                    if (eventController.events.isEmpty) {
                      return _buildEmptyState('Belum ada kegiatan terdekat');
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
                    title: 'Eksplorasi Divisi',
                    subtitle: 'Temukan ruang karyamu di sini',
                    accentColor: AppColors.accentPurple,
                  ),
                  const SizedBox(height: 16),
                  _buildCreativeDivisionGrid(context),
                  const SizedBox(height: 40),
                  _buildSectionHeader(
                    context,
                    title: 'Galeri Terbaru',
                    subtitle: 'Inspirasi karya anggota',
                    accentColor: AppColors.accentOrange,
                    onSeeAll: () => Get.toNamed(AppRoutes.galleryVisitor),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mulai Berkarya Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreativeHero(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative Abstract Shapes
          Positioned(
            top: -50,
            right: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: AppColors.secondary.withOpacity(0.15),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.accentPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 8),
                      Text(
                        'UKM Seni & Kreativitas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ekspresikan Dirimu di Ruang Karya',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildHeroStat('400+', 'Anggota'),
                    const SizedBox(width: 24),
                    _buildHeroStat('4', 'Divisi'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        Expanded(
          child: Column(
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
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ),
      ],
    );
  }

  Widget _buildCreativeDivisionGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.82,
      ),
      itemCount: AppConstants.divisions.length,
      itemBuilder: (_, i) {
        final division = AppConstants.divisions[i];
        final color = AppColors.getDivisionColor(division);
        return GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.divisionInfo),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withOpacity(0.24),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: color.withOpacity(0.15), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(_getDivisionIcon(division), color: color, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      division,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'LIHAT DETAIL',
                      style: TextStyle(
                        color: color.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getDivisionIcon(String division) {
    switch (division) {
      case 'Musik':
        return Icons.music_note_rounded;
      case 'Tari':
        return Icons.auto_awesome_rounded;
      case 'DKV':
        return Icons.palette_rounded;
      case 'Kreatif Event':
        return Icons.event_available_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.divider.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
