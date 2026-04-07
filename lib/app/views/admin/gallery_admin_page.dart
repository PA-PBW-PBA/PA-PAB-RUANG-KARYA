import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/gallery_controller.dart';
import '../widgets/gallery_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/admin_bottom_nav.dart';

class GalleryAdminPage extends StatelessWidget {
  const GalleryAdminPage({super.key});

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
                  itemBuilder: (_, __) =>
                      const LoadingSkeleton(height: 160, borderRadius: 12),
                );
              }
              if (controller.filteredGallery.isEmpty) {
                return const EmptyState(
                  message: 'Belum ada foto',
                  subtitle: 'Tap + untuk upload foto',
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
                    showAdminActions: true,
                    onDelete: () =>
                        _confirmDelete(context, controller, item.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadSheet(context, controller),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: AdminBottomNav(currentIndex: 3),
    );
  }

  void _showUploadSheet(BuildContext context, GalleryController controller) {
    final captionController = TextEditingController();
    String selectedDivision = AppConstants.divisions.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 16,
            right: 16,
            top: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).dividerColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Upload Foto',
                  style: Theme.of(ctx).textTheme.headlineMedium),
              const SizedBox(height: 16),

              // Image picker
              Obx(() => GestureDetector(
                    onTap: controller.pickGalleryImage,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(ctx).dividerColor,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: controller.pickedGalleryFile.value == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Theme.of(ctx).colorScheme.primary,
                                  size: 36,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap untuk pilih foto',
                                  style: Theme.of(ctx).textTheme.bodySmall,
                                ),
                              ],
                            )
                          : const Center(
                              child: Text('Foto dipilih'),
                            ),
                    ),
                  )),
              const SizedBox(height: 16),

              TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  hintText: 'Tulis caption foto...',
                ),
              ),
              const SizedBox(height: 16),

              // Division selector
              Text('Divisi', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.divisions.map((division) {
                  final isSelected = selectedDivision == division;
                  final color = AppColors.getDivisionColor(division);
                  return GestureDetector(
                    onTap: () => setState(() => selectedDivision = division),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: color,
                          width: isSelected ? 0 : 0.5,
                        ),
                      ),
                      child: Text(
                        division,
                        style: TextStyle(
                          color: isSelected ? Colors.white : color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.uploadGallery(
                      caption: captionController.text.trim(),
                      divisionName: selectedDivision,
                    );
                    Get.back();
                  },
                  child: const Text('Upload'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, GalleryController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Foto'),
        content: const Text('Foto akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteGallery(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
