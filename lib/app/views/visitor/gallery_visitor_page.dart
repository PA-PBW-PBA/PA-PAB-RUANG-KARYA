import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/gallery_controller.dart';
import '../../models/gallery_model.dart';
import '../widgets/gallery_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/division_filter_bar.dart';
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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Get.back(),
            ),
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.3,
              title: Text(
                'Galeri Karya',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: DivisionFilterBar(
                divisions: ['Semua', ...AppConstants.divisions],
                selected: controller.selectedDivision,
                onSelected: controller.filterByDivision,
              ),
            ),
          ),

          Obx(() {
            if (controller.isLoading.value) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const LoadingSkeleton(height: 160, borderRadius: 28),
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final item = controller.filteredGallery[i];
                    return GalleryCard(
                      gallery: item,
                      onTap: () => _showEnhancedFullImage(context, item),
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

  void _showEnhancedFullImage(BuildContext context, GalleryModel item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: Colors.white,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: InteractiveViewer(
                      maxScale: 5.0,
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.getDivisionColor(item.divisionName).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.divisionName.toUpperCase(),
                            style: TextStyle(
                              color: AppColors.getDivisionColor(item.divisionName),
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.caption ?? 'Tidak ada keterangan',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            height: 1.6,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
