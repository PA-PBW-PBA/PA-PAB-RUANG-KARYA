import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/gallery_controller.dart';
import '../../controllers/member_controller.dart';
import '../../controllers/kas_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/event_card.dart';
import '../widgets/gallery_card.dart';
import '../widgets/admin_bottom_nav.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class DashboardAdminPage extends StatelessWidget {
  const DashboardAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final eventController = Get.put(EventController());
    final galleryController = Get.put(GalleryController());
    final memberController = Get.put(MemberController());
    final kasController = Get.put(KasController());

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
                    onTap: () => Get.toNamed(AppRoutes.profileAdmin),
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
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        authController.currentUser.value?.isBendahara == true
                            ? 'Admin — Bendahara'
                            : 'Admin — BPH',
                        style: Theme.of(context).textTheme.bodySmall,
                      )),
                  const SizedBox(height: 20),

                  // Stats ringkas
                  Obx(() => Row(
                        children: [
                          _statCard(
                            context,
                            '${memberController.members.length}',
                            'Anggota',
                            Icons.people_outline,
                            AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          _statCard(
                            context,
                            '${eventController.events.length}',
                            'Kegiatan',
                            Icons.event_outlined,
                            AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          _statCard(
                            context,
                            'Rp ${_formatAmount(kasController.totalSaldo)}',
                            'Saldo Kas',
                            Icons.account_balance_wallet_outlined,
                            AppColors.accentGreen,
                          ),
                        ],
                      )),
                  const SizedBox(height: 24),

                  // Quick access manajemen
                  Text(
                    'Manajemen',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  _quickAccessGrid(context),
                  const SizedBox(height: 24),

                  // Kegiatan mendatang
                  _sectionHeader(
                    context,
                    'Kegiatan Mendatang',
                    onSeeAll: () => Get.toNamed(AppRoutes.eventList),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (eventController.events.isEmpty) {
                      return const SizedBox(height: 60);
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

                  // Anggota per divisi
                  Text(
                    'Anggota per Divisi',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final memberList = memberController.members.toList();
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: AppConstants.divisions.length,
                      itemBuilder: (_, i) {
                        final division = AppConstants.divisions[i];
                        final color = AppColors.getDivisionColor(division);
                        final count = memberList
                            .where((m) => m.divisions.contains(division))
                            .length;
                        return GestureDetector(
                          onTap: () => Get.toNamed(
                            AppRoutes.memberList,
                            arguments: division,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: color.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$count',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  division,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 24),

                  // Galeri terbaru
                  _sectionHeader(
                    context,
                    'Galeri Terbaru',
                    onSeeAll: () => Get.toNamed(AppRoutes.galleryAdmin),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => galleryController.gallery.isEmpty
                      ? const SizedBox(height: 60)
                      : GridView.builder(
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
                        )),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  Widget _statCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAccessGrid(BuildContext context) {
    final items = [
      {
        'icon': Icons.people_outline,
        'label': 'Anggota',
        'route': AppRoutes.memberList,
        'color': AppColors.primary,
      },
      {
        'icon': Icons.event_outlined,
        'label': 'Kegiatan',
        'route': AppRoutes.eventList,
        'color': AppColors.secondary,
      },
      {
        'icon': Icons.photo_library_outlined,
        'label': 'Galeri',
        'route': AppRoutes.galleryAdmin,
        'color': AppColors.accentGreen,
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Kas',
        'route': AppRoutes.kasPage,
        'color': AppColors.accentRed,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final color = item['color'] as Color;
        return GestureDetector(
          onTap: () => Get.toNamed(item['route'] as String),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['label'] as String,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return amount.toStringAsFixed(0);
  }
}
