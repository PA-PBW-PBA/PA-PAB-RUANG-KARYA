import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  final _attendanceStats = <Map<String, dynamic>>[].obs;
  final _loadingStats = false.obs;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceStats();
  }

  Future<void> _fetchAttendanceStats() async {
    _loadingStats.value = true;
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('attendances')
          .select('event_id, status, events(title)')
          .order('created_at', ascending: false)
          .limit(200);

      final Map<String, Map<String, dynamic>> grouped = {};
      for (final row in response) {
        final eventId = row['event_id'] as String;
        final title = row['events']?['title'] as String? ?? eventId;
        final status = row['status'] as String;

        grouped.putIfAbsent(
            eventId,
            () => {
                  'title': title,
                  'hadir': 0,
                  'izin': 0,
                  'tidakHadir': 0,
                  'total': 0,
                });
        grouped[eventId]!['total'] = (grouped[eventId]!['total'] as int) + 1;
        if (status == 'hadir') {
          grouped[eventId]!['hadir'] = (grouped[eventId]!['hadir'] as int) + 1;
        } else if (status == 'izin') {
          grouped[eventId]!['izin'] = (grouped[eventId]!['izin'] as int) + 1;
        } else {
          grouped[eventId]!['tidakHadir'] =
              (grouped[eventId]!['tidakHadir'] as int) + 1;
        }
      }

      _attendanceStats.value = grouped.values.take(5).toList();
    } catch (_) {
    } finally {
      _loadingStats.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final eventController = Get.put(EventController());
    final galleryController = Get.put(GalleryController());
    final memberController = Get.put(MemberController());
    final kasController = Get.put(KasController());
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
                      'Admin Panel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w900,
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
                      onTap: () => Get.toNamed(AppRoutes.profileAdmin),
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
                            '${authController.currentUser.value?.fullName.split(' ').first ?? 'Admin'}!',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              authController.currentUser.value?.isBendahara ==
                                      true
                                  ? 'Administrator — Bendahara Utama'
                                  : 'Administrator — Badan Pengurus Harian',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 32),
                  _buildPremiumAdminCard(
                      context, memberController, kasController, authController),
                  const SizedBox(height: 40),
                  _buildSectionHeader(
                    context,
                    title: 'Manajemen Inti',
                    subtitle: 'Kelola data UKM kamu',
                    accentColor: AppColors.accentPurple,
                  ),
                  const SizedBox(height: 16),
                  _buildModernManagementGrid(context, authController),
                  const SizedBox(height: 40),
                  _buildSectionHeader(
                    context,
                    title: 'Kegiatan Terdekat',
                    subtitle: 'Pantau agenda mendatang',
                    accentColor: AppColors.accentPink,
                    onSeeAll: () => Get.toNamed(AppRoutes.eventList),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (eventController.events.isEmpty) {
                      return _buildEmptyState('Belum ada kegiatan terjadwal');
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
                    title: 'Anggota per Divisi',
                    subtitle: 'Distribusi sumber daya manusia',
                    accentColor: AppColors.secondary,
                  ),
                  const SizedBox(height: 16),
                  _buildModernDivisionGrid(context, memberController),
                  const SizedBox(height: 40),
                  _buildSectionHeader(
                    context,
                    title: 'Statistik Absensi',
                    subtitle: 'Rekap kehadiran anggota',
                    accentColor: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  _buildAttendanceStats(context),
                  const SizedBox(height: 40),
                  _buildSectionHeader(
                    context,
                    title: 'Galeri Terbaru',
                    subtitle: 'Dokumentasi karya anggota',
                    accentColor: AppColors.accentOrange,
                    onSeeAll: () => Get.toNamed(AppRoutes.galleryAdmin),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (galleryController.gallery.isEmpty) {
                      return _buildEmptyState('Galeri admin masih kosong');
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
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  Widget _buildAttendanceStats(BuildContext context) {
    return Obx(() {
      if (_loadingStats.value) {
        return Container(
          height: 100,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      }
      if (_attendanceStats.isEmpty) {
        return _buildEmptyState('Belum ada data absensi');
      }

      return Column(
        children: _attendanceStats.map((stat) {
          final total = stat['total'] as int;
          final hadir = stat['hadir'] as int;
          final izin = stat['izin'] as int;
          final tidakHadir = stat['tidakHadir'] as int;
          final pct = total == 0 ? 0.0 : hadir / total;
          final statusColor = pct >= 0.75
              ? AppColors.success
              : pct >= 0.5
                  ? AppColors.warning
                  : AppColors.accentRed;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        stat['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(pct * 100).round()}% HADIR',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _statPill('Hadir', hadir, AppColors.success),
                    const SizedBox(width: 8),
                    _statPill('Izin', izin, AppColors.warning),
                    const SizedBox(width: 8),
                    _statPill('Absen', tidakHadir, AppColors.accentRed),
                    const Spacer(),
                    Text(
                      '$total Peserta',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _statPill(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$count $label',
          style: TextStyle(
            color: AppColors.textPrimary.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumAdminCard(
      BuildContext context,
      MemberController memberController,
      KasController kasController,
      AuthController authController) {
    final canManageKas =
        authController.currentUser.value?.canManageKas ?? false;
    return Obx(() => Container(
          width: double.infinity,
          height: 200,
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
                top: -30,
                right: -30,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OVERVIEW SISTEM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildStatItem(
                          'Anggota',
                          '${memberController.members.length}',
                          Icons.people_alt_rounded,
                          AppColors.secondary,
                        ),
                        if (canManageKas) ...[
                          Container(
                            height: 40,
                            width: 1.5,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          _buildStatItem(
                            'Saldo Kas',
                            kasController.formatCompactCurrency(kasController.totalSaldo),
                            Icons.account_balance_wallet_rounded,
                            AppColors.accentYellow,
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 3,
                            backgroundColor: AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SISTEM AKTIF',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildModernManagementGrid(
      BuildContext context, AuthController authController) {
    final canManageKas =
        authController.currentUser.value?.canManageKas ?? false;

    final allItems = [
      {
        'icon': Icons.group_add_rounded,
        'label': 'Anggota',
        'route': AppRoutes.memberList,
        'color': AppColors.secondary,
        'requiresKas': false,
      },
      {
        'icon': Icons.event_note_rounded,
        'label': 'Kegiatan',
        'route': AppRoutes.eventList,
        'color': AppColors.accentPink,
        'requiresKas': false,
      },
      {
        'icon': Icons.add_photo_alternate_rounded,
        'label': 'Galeri',
        'route': AppRoutes.galleryAdmin,
        'color': AppColors.accentOrange,
        'requiresKas': false,
      },
      {
        'icon': Icons.payments_rounded,
        'label': 'Kas',
        'route': AppRoutes.kasPage,
        'color': AppColors.success,
        'requiresKas': true,
      },
    ];

    final items = allItems
        .where((item) => !(item['requiresKas'] as bool) || canManageKas)
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final color = item['color'] as Color;
        return InkWell(
          onTap: () => Get.toNamed(item['route'] as String),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withOpacity(0.12), width: 1.5),
                ),
                child: Icon(item['icon'] as IconData, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                item['label'] as String,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
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
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.82,
        ),
        itemCount: AppConstants.divisions.length,
        itemBuilder: (_, i) {
          final division = AppConstants.divisions[i];
          final color = AppColors.getDivisionColor(division);
          final count =
              memberList.where((m) => m.divisions.contains(division)).length;
          final totalMembers = memberList.length;
          final pct = totalMembers == 0 ? 0.0 : count / totalMembers;

          return InkWell(
            onTap: () => Get.toNamed(AppRoutes.memberList, arguments: division),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.24),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: color.withOpacity(0.15), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_getDivisionIcon(division),
                            color: color, size: 20),
                      ),
                      Text(
                        '$count',
                        style: TextStyle(
                          color: color,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
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
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 4,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation(color),
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

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}Rb';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }
}

