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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? 'Selamat Pagi'
        : hour < 15
            ? 'Selamat Siang'
            : hour < 18
                ? 'Selamat Sore'
                : 'Selamat Malam';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // SliverAppBar
          SliverAppBar(
            expandedHeight: 80,
            floating: true,
            pinned: false,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
            title: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Image.asset(
                'assets/images/logo_mark.png',
                height: 32,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.palette_rounded,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
            ),
            actions: [
              Obx(() => Padding(
                    padding: const EdgeInsets.only(right: 20, top: 8),
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.profileAdmin),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: colorScheme.primary.withOpacity(0.3),
                              width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            authController.currentUser.value?.fullName
                                        .isNotEmpty ==
                                    true
                                ? authController.currentUser.value!.fullName[0]
                                    .toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Warm Greeting
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${authController.currentUser.value?.fullName.split(' ').first ?? 'Admin'}!',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authController.currentUser.value?.isBendahara ==
                                    true
                                ? 'Administrator — Bendahara Utama'
                                : 'Administrator — Badan Pengurus Harian',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )),

                  const SizedBox(height: 24),

                  _buildPremiumAdminCard(
                      context, memberController, kasController),

                  const SizedBox(height: 32),

                  _buildSectionHeader(context, title: 'Manajemen Inti'),
                  const SizedBox(height: 16),
                  _buildModernManagementGrid(context),

                  const SizedBox(height: 32),

                  _buildSectionHeader(
                    context,
                    title: 'Kegiatan Terdekat',
                    onSeeAll: () => Get.toNamed(AppRoutes.eventList),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (eventController.events.isEmpty) {
                      return _buildEmptyState('Belum ada kegiatan terjadwal');
                    }
                    return SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: eventController.events.take(5).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, i) => Container(
                          width: 280,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: EventCard(event: eventController.events[i]),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  _buildSectionHeader(context, title: 'Distribusi Anggota'),
                  const SizedBox(height: 16),
                  _buildModernDivisionGrid(context, memberController),

                  const SizedBox(height: 32),

                  _buildSectionHeader(
                    context,
                    title: 'Galeri Terbaru',
                    onSeeAll: () => Get.toNamed(AppRoutes.galleryAdmin),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (galleryController.gallery.isEmpty) {
                      return _buildEmptyState('Galeri admin masih kosong');
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: galleryController.gallery.take(4).length,
                      itemBuilder: (_, i) => Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
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
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  Widget _buildPremiumAdminCard(BuildContext context,
      MemberController memberController, KasController kasController) {
    return Obx(() => Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Decorative Graphic
              Positioned(
                top: -20,
                right: -20,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(0.03),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -10,
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 150,
                  color: Colors.white.withOpacity(0.02),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        _buildStatItem(
                          context,
                          'Total Anggota',
                          '${memberController.members.length}',
                          Icons.people_alt_rounded,
                          AppColors.primaryLight,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.white12,
                        ),
                        _buildStatItem(
                          context,
                          'Saldo Kas Aktif',
                          'Rp ${_formatAmount(kasController.totalSaldo)}',
                          Icons.account_balance_wallet_rounded,
                          AppColors.secondaryLight,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: Colors.white.withOpacity(0.5), size: 14),
                          const SizedBox(width: 8),
                          Text(
                            'Status Sistem: Berjalan Normal',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const CircleAvatar(
                            radius: 3,
                            backgroundColor: AppColors.accentGreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color.withOpacity(0.8), size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildModernManagementGrid(BuildContext context) {
    final items = [
      {
        'icon': Icons.group_add_rounded,
        'label': 'Anggota',
        'route': AppRoutes.memberList,
        'color': AppColors.primary
      },
      {
        'icon': Icons.event_note_rounded,
        'label': 'Kegiatan',
        'route': AppRoutes.eventList,
        'color': AppColors.secondary
      },
      {
        'icon': Icons.add_photo_alternate_rounded,
        'label': 'Galeri',
        'route': AppRoutes.galleryAdmin,
        'color': AppColors.accentGreen
      },
      {
        'icon': Icons.payments_rounded,
        'label': 'Kas',
        'route': AppRoutes.kasPage,
        'color': AppColors.accentRed
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final color = item['color'] as Color;
        return InkWell(
          onTap: () => Get.toNamed(item['route'] as String),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.15), width: 1.5),
                ),
                child: Icon(item['icon'] as IconData, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                item['label'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernDivisionGrid(
      BuildContext context, MemberController memberController) {
    return Obx(() {
      final memberList = memberController.members.toList();
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
        ),
        itemCount: AppConstants.divisions.length,
        itemBuilder: (_, i) {
          final division = AppConstants.divisions[i];
          final color = AppColors.getDivisionColor(division);
          final count = memberList
              .where((m) => m.divisions.contains(division))
              .length;

          return InkWell(
            onTap: () => Get.toNamed(AppRoutes.memberList, arguments: division),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withOpacity(0.12), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getDivisionIcon(division),
                            color: color, size: 16),
                      ),
                      Text(
                        '$count',
                        style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        division,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Total Anggota',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
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
    });
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

  Widget _buildSectionHeader(BuildContext context,
      {required String title, VoidCallback? onSeeAll}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Row(
              children: [
                Text(
                  'Lihat Semua',
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: theme.colorScheme.primary),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.divider.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
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
