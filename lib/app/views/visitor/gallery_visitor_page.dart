import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../../controllers/gallery_controller.dart';
import '../../models/gallery_model.dart';
import '../widgets/gallery_card.dart';
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Galeri Karya',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter 
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterChip(context, 'Semua', controller),
                  ...AppConstants.divisions.map((d) => _buildFilterChip(context, d, controller)),
                ],
              ),
            ),
          ),

          // Galeri
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, __) => const LoadingSkeleton(
                    height: 160,
                    borderRadius: 20,
                  ),
                );
              }
              if (controller.filteredGallery.isEmpty) {
                return const EmptyState(
                  message: 'Galeri masih kosong',
                  subtitle: 'Belum ada karya untuk divisi ini',
                  icon: Icons.auto_awesome_motion_rounded,
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: controller.filteredGallery.length,
                itemBuilder: (_, i) {
                  final item = controller.filteredGallery[i];
                  return Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: GalleryCard(
                      gallery: item,
                      onTap: () => _showEnhancedFullImage(context, item),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, GalleryController controller) {
    return Obx(() {
      final isSelected = controller.selectedDivision.value == label;
      final colorScheme = Theme.of(context).colorScheme;
      
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: GestureDetector(
          onTap: () => controller.filterByDivision(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showEnhancedFullImage(BuildContext context, GalleryModel item) {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.8),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Get.back(),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: InteractiveViewer(
                      clipBehavior: Clip.none,
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        errorWidget: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                  ),
                  if (item.caption != null && item.caption!.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        item.caption!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      useSafeArea: false,
    );
  }
}
