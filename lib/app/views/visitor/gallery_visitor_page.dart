import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/gallery_controller.dart';
import '../../models/gallery_model.dart';
import '../widgets/gallery_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../../../core/constants/app_constants.dart';

class GalleryVisitorPage extends StatelessWidget {
  const GalleryVisitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GalleryController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Galeri')),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  'Semua',
                  ...AppConstants.divisions,
                ].map((division) {
                  return Obx(() {
                    final isSelected =
                        controller.selectedDivision.value == division;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(division),
                        selected: isSelected,
                        onSelected: (_) =>
                            controller.filterByDivision(division),
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, __) => const LoadingSkeleton(
                    height: 160,
                    borderRadius: 12,
                  ),
                );
              }
              if (controller.filteredGallery.isEmpty) {
                return const EmptyState(
                  message: 'Belum ada foto',
                  subtitle: 'Foto kegiatan akan muncul di sini',
                  icon: Icons.photo_library_outlined,
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: controller.filteredGallery.length,
                itemBuilder: (_, i) {
                  final item = controller.filteredGallery[i];
                  return GalleryCard(
                    gallery: item,
                    onTap: () => _showFullImage(context, item),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, GalleryModel item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            if (item.caption != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.caption!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
