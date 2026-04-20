import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
<<<<<<< HEAD

import '../../controllers/gallery_controller.dart';
import '../../models/gallery_model.dart';
=======
import '../../controllers/gallery_controller.dart';
import '../../models/gallery_model.dart';
import '../widgets/gallery_card.dart';
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class GalleryVisitorPage extends StatelessWidget {
  const GalleryVisitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GalleryController>();
    final theme = Theme.of(context);

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFFF7F8FC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFF7F8FC),
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Get.back(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEDE9FE),
                      Color(0xFFDDE7FF),
                      Color(0xFFFCE7F3),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -10,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 24,
                      left: 24,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.60),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Image.asset(
                                'assets/images/logo_mark.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Galeri Karya',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF27314D),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Temukan karya terbaik dari setiap divisi UKM',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF6E7891),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Divisi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF27314D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih kategori karya yang ingin kamu lihat',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF7B859C),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: SizedBox(
                height: 46,
=======
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. SliverAppBar dengan Back Button (Konsisten dengan Admin)
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.back(),
            ),
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.2,
              title: Text(
                'Galeri Karya',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),

          // 2. Filter Divisi Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                height: 40,
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFilterChip(context, 'Semua', controller),
                    ...AppConstants.divisions
                        .map((d) => _buildFilterChip(context, d, controller)),
                  ],
                ),
              ),
            ),
          ),

<<<<<<< HEAD
          Obx(() {
            if (controller.isLoading.value) {
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const LoadingSkeleton(
                      height: 220,
                      borderRadius: 24,
                    ),
=======
          // 3. Grid List Gallery
          Obx(() {
            if (controller.isLoading.value) {
              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, __) =>
                        const LoadingSkeleton(height: 160, borderRadius: 20),
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
                    childCount: 6,
                  ),
                ),
              );
            }

            if (controller.filteredGallery.isEmpty) {
              return const SliverFillRemaining(
                child: EmptyState(
                  message: 'Galeri masih kosong',
                  subtitle: 'Belum ada karya untuk divisi ini',
                  icon: Icons.auto_awesome_motion_rounded,
                ),
              );
            }

            return SliverPadding(
<<<<<<< HEAD
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.78,
=======
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final item = controller.filteredGallery[i];
<<<<<<< HEAD
                    return _ModernGalleryCard(
                      item: item,
                      onTap: () => _showEnhancedFullImage(context, item),
=======
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: GalleryCard(
                        gallery: item,
                        onTap: () => _showEnhancedFullImage(context, item),
                      ),
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
                    );
                  },
                  childCount: controller.filteredGallery.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
<<<<<<< HEAD
    BuildContext context,
    String label,
    GalleryController controller,
  ) {
=======
      BuildContext context, String label, GalleryController controller) {
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
    return Obx(() {
      final isSelected = controller.selectedDivision.value == label;
      final color = label == 'Semua'
          ? Theme.of(context).colorScheme.primary
          : AppColors.getDivisionColor(label);

      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: GestureDetector(
          onTap: () => controller.filterByDivision(label),
          child: AnimatedContainer(
<<<<<<< HEAD
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.18),
                width: 1.3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
=======
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.12),
                width: 1.5,
              ),
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
<<<<<<< HEAD
                fontWeight: FontWeight.w700,
=======
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    });
  }

<<<<<<< HEAD
=======
  // FIXED: Mengatasi Pixel Overflowed dengan Flexible dan ScrollView (Mirip Versi Admin)
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
  void _showEnhancedFullImage(BuildContext context, GalleryModel item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Theme.of(context).cardColor,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
<<<<<<< HEAD
                mainAxisSize: MainAxisSize.min,
                children: [
=======
                mainAxisSize:
                    MainAxisSize.min, // Agar dialog mengikuti tinggi konten
                children: [
                  // Gambar dibuat Flexible agar tidak overflow jika layar pendek
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
                  Flexible(
                    child: InteractiveViewer(
                      maxScale: 5.0,
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
<<<<<<< HEAD
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.broken_image_rounded),
                      ),
                    ),
                  ),
=======
                        errorWidget: (_, __, ___) => const Icon(Icons.error),
                      ),
                    ),
                  ),

                  // Container Informasi Karya (Caption)
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
<<<<<<< HEAD
                        top: BorderSide(
                          color: Theme.of(context)
                              .dividerColor
                              .withOpacity(0.08),
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
=======
                          top: BorderSide(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.1))),
                    ),
                    child: SingleChildScrollView(
                      // Mencegah overflow pada teks panjang
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
<<<<<<< HEAD
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getDivisionColor(item.divisionName)
                                  .withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10),
=======
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.getDivisionColor(item.divisionName)
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
                            ),
                            child: Text(
                              item.divisionName.toUpperCase(),
                              style: TextStyle(
<<<<<<< HEAD
                                color:
                                    AppColors.getDivisionColor(item.divisionName),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
=======
                                color: AppColors.getDivisionColor(
                                    item.divisionName),
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.caption ?? 'Tidak ada keterangan',
<<<<<<< HEAD
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
=======
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                  letterSpacing: 0.2,
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
<<<<<<< HEAD
=======

            // Tombol Close
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 18,
<<<<<<< HEAD
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
=======
                  child:
                      Icon(Icons.close_rounded, color: Colors.white, size: 20),
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
<<<<<<< HEAD

class _ModernGalleryCard extends StatelessWidget {
  final GalleryModel item;
  final VoidCallback onTap;

  const _ModernGalleryCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final divisionColor = AppColors.getDivisionColor(item.divisionName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: divisionColor.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: const Color(0xFFF2F4FA),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFFF2F4FA),
                    child: const Icon(Icons.broken_image_rounded),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.transparent,
                        Colors.black.withOpacity(0.55),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.collections_rounded,
                    size: 18,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: divisionColor.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.divisionName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (item.caption?.trim().isNotEmpty ?? false)
                            ? item.caption!.trim()
                            : 'Karya tanpa judul',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(
                            Icons.open_in_full_rounded,
                            size: 14,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Lihat detail',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
=======
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
