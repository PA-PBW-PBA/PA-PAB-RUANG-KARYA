import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/gallery_controller.dart';
import '../../models/gallery_model.dart';
import '../widgets/gallery_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/admin_bottom_nav.dart';

class GalleryAdminPage extends StatefulWidget {
  const GalleryAdminPage({super.key});

  @override
  State<GalleryAdminPage> createState() => _GalleryAdminPageState();
}

class _GalleryAdminPageState extends State<GalleryAdminPage> {
  final controller = Get.find<GalleryController>();
  late ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isFabVisible) setState(() => _isFabVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFabVisible) setState(() => _isFabVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
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
                'Manajemen Galeri',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        'Semua',
                        ...AppConstants.divisions,
                      ].map((division) {
                        return Obx(() {
                          final isSelected =
                              controller.selectedDivision.value == division;
                          final color = division == 'Semua'
                              ? colorScheme.primary
                              : AppColors.getDivisionColor(division);
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FilterChip(
                              label: Text(division),
                              selected: isSelected,
                              onSelected: (_) =>
                                  controller.filterByDivision(division),
                              backgroundColor: color.withOpacity(0.05),
                              selectedColor: color.withOpacity(0.15),
                              checkmarkColor: color,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(
                                color: isSelected
                                    ? color.withOpacity(0.3)
                                    : Colors.transparent,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? color
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          );
                        });
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
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
                    (context, index) =>
                        const LoadingSkeleton(height: 160, borderRadius: 20),
                    childCount: 6,
                  ),
                ),
              );
            }
            if (controller.filteredGallery.isEmpty) {
              return const SliverFillRemaining(
                child: EmptyState(
                  message: 'Belum ada karya',
                  subtitle: 'Mulai upload karya terbaik organisasi',
                  icon: Icons.photo_library_outlined,
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final item = controller.filteredGallery[i];
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
                        showAdminActions: true,
                        onTap: () => _showImageDetail(context, item),
                        // BUG FIX #6: Tombol edit sekarang memanggil sheet edit
                        onEdit: () => _showEditSheet(context, controller, item),
                        onDelete: () =>
                            _confirmDelete(context, controller, item.id),
                      ),
                    );
                  },
                  childCount: controller.filteredGallery.length,
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isFabVisible ? 1.0 : 0.0,
        child: Visibility(
          visible: _isFabVisible,
          child: FloatingActionButton.extended(
            onPressed: () => _showUploadSheet(context, controller),
            backgroundColor: colorScheme.primary,
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
            label: const Text('Upload Karya',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 3),
    );
  }

  void _showImageDetail(BuildContext context, GalleryModel item) {
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: InteractiveViewer(
                      maxScale: 5.0,
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                          top: BorderSide(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.1))),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.getDivisionColor(item.divisionName)
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.divisionName.toUpperCase(),
                              style: TextStyle(
                                color: AppColors.getDivisionColor(
                                    item.divisionName),
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.caption ?? 'Tidak ada keterangan',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 18,
                  child:
                      Icon(Icons.close_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BUG FIX #6: Sheet edit caption + divisi (ganti foto opsional)
  void _showEditSheet(
      BuildContext context, GalleryController controller, GalleryModel item) {
    final captionController = TextEditingController(text: item.caption ?? '');
    String selectedDivision = item.divisionName;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Reset file pilihan sebelumnya
    controller.pickedGalleryFile.value = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            left: 24,
            right: 24,
            top: 16,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                    color: theme.dividerColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Edit Karya',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              // Preview gambar existing + opsi ganti
              Obx(() {
                final picked = controller.pickedGalleryFile.value;
                return GestureDetector(
                  onTap: () async {
                    await controller.pickGalleryImage();
                    setModalState(() {});
                  },
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                          width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // BUG FIX #5 (juga berlaku di edit):
                        // Tampilkan gambar baru jika dipilih (pakai bytes untuk Web),
                        // fallback ke gambar lama dari network.
                        picked != null
                            ? FutureBuilder<Uint8List>(
                                future: picked.readAsBytes(),
                                builder: (_, snap) {
                                  if (snap.hasData) {
                                    return Image.memory(snap.data!,
                                        fit: BoxFit.cover);
                                  }
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                              )
                            : CachedNetworkImage(
                                imageUrl: item.imageUrl, fit: BoxFit.cover),
                        // Overlay "Ganti Foto"
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: Colors.black54,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_camera_rounded,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('Tap untuk ganti foto',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              TextField(
                controller: captionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Caption Karya',
                  prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                ),
              ),
              const SizedBox(height: 20),
              Text('Divisi Pemilik Karya',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppConstants.divisions.map((division) {
                  final isSelected = selectedDivision == division;
                  final color = AppColors.getDivisionColor(division);
                  return GestureDetector(
                    onTap: () =>
                        setModalState(() => selectedDivision = division),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: isSelected ? color : color.withOpacity(0.15),
                            width: 1.5),
                      ),
                      child: Text(division,
                          style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.updateGallery(
                      id: item.id,
                      caption: captionController.text.trim(),
                      divisionName: selectedDivision,
                    );
                    Get.back();
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadSheet(BuildContext context, GalleryController controller) {
    final captionController = TextEditingController();
    String selectedDivision = AppConstants.divisions.first;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    controller.pickedGalleryFile.value = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            left: 24,
            right: 24,
            top: 16,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                    color: theme.dividerColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Upload Karya Baru',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              // BUG FIX #5: Ganti Image.file → Image.memory agar kompatibel
              // dengan Flutter Web (Image.file tidak didukung di Web).
              Obx(() {
                final picked = controller.pickedGalleryFile.value;
                return GestureDetector(
                  onTap: () async {
                    await controller.pickGalleryImage();
                    setModalState(() {});
                  },
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                          width: 2,
                          style: BorderStyle.solid),
                    ),
                    child: picked == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded,
                                  color: colorScheme.primary, size: 40),
                              const SizedBox(height: 12),
                              Text('Tap untuk pilih foto',
                                  style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: FutureBuilder<Uint8List>(
                              future: picked.readAsBytes(),
                              builder: (_, snap) {
                                if (snap.hasData) {
                                  return Image.memory(snap.data!,
                                      fit: BoxFit.cover);
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              TextField(
                controller: captionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Caption Karya',
                  prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                ),
              ),
              const SizedBox(height: 24),
              Text('Divisi Pemilik Karya',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppConstants.divisions.map((division) {
                  final isSelected = selectedDivision == division;
                  final color = AppColors.getDivisionColor(division);
                  return GestureDetector(
                    onTap: () =>
                        setModalState(() => selectedDivision = division),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: isSelected ? color : color.withOpacity(0.15),
                            width: 1.5),
                      ),
                      child: Text(division,
                          style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.pickedGalleryFile.value == null) {
                      Get.snackbar('Gagal', 'Pilih foto dulu ya!');
                      return;
                    }
                    controller.uploadGallery(
                      caption: captionController.text.trim(),
                      divisionName: selectedDivision,
                    );
                    Get.back();
                  },
                  child: const Text('Publish Karya Sekarang'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Karya?'),
        content:
            const Text('Data ini tidak bisa dikembalikan setelah dihapus.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteGallery(id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
