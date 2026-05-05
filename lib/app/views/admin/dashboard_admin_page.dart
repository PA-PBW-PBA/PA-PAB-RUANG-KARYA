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
  // Statistik absensi: eventTitle → {hadir, izin, tidakHadir}
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
      // Ambil 5 kegiatan terakhir yang sudah punya data absensi
      final response = await supabase
          .from('attendances')
          .select('event_id, status, events(title)')
          .order('created_at', ascending: false)
          .limit(200);

      // Group by event
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

      // Ambil 5 event terbaru saja
      _attendanceStats.value = grouped.values.take(5).toList();
    } catch (_) {
      // silent fail — stats bersifat tambahan
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
                      context, memberController, kasController, authController),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, title: 'Manajemen Inti'),
                  const SizedBox(height: 12),
                  _buildModernManagementGrid(context, authController),
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    context,
                    title: 'Kegiatan Terdekat',
                    onSeeAll: () => Get.toNamed(AppRoutes.eventList),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (eventController.events.isEmpty) {
                      return _buildEmptyState('Belum ada kegiatan terjadwal');
                    }
                    return SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: eventController.events.take(5).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, i) => Container(
                          width: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                spreadRadius: 1,
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

                  // ── Distribusi Anggota per Divisi ──────────────────────────
                  _buildSectionHeader(context, title: 'Anggota per Divisi'),
                  const SizedBox(height: 12),
                  _buildModernDivisionGrid(context, memberController),
                  const SizedBox(height: 32),

                  // ── Statistik Absensi ──────────────────────────────────────
                  _buildSectionHeader(context, title: 'Statistik Absensi'),
                  const SizedBox(height: 4),
                  Text(
                    '5 kegiatan terakhir yang sudah direkap',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAttendanceStats(context),
                  const SizedBox(height: 32),

                  // ── Galeri Terbaru ─────────────────────────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Galeri Terbaru',
                    onSeeAll: () => Get.toNamed(AppRoutes.galleryAdmin),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (galleryController.gallery.isEmpty) {
                      return _buildEmptyState('Galeri admin masih kosong');
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
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

  // ── Statistik Absensi Widget ──────────────────────────────────────────────
  Widget _buildAttendanceStats(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      if (_loadingStats.value) {
        return Container(
          height: 80,
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

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stat['title'] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(pct * 100).round()}% hadir',
                      style: TextStyle(
                        color: pct >= 0.75
                            ? AppColors.success
                            : pct >= 0.5
                                ? AppColors.warning
                                : AppColors.accentRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Progress bar kehadiran
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppColors.divider.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation(
                      pct >= 0.75
                          ? AppColors.success
                          : pct >= 0.5
                              ? AppColors.warning
                              : AppColors.accentRed,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Legenda angka
                Row(
                  children: [
                    _statPill('Hadir', hadir, AppColors.success),
                    const SizedBox(width: 8),
                    _statPill('Izin', izin, AppColors.warning),
                    const SizedBox(width: 8),
                    _statPill('Absen', tidakHadir, AppColors.accentRed),
                    const Spacer(),
                    Text(
                      '$total peserta',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label $count',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Existing widgets (unchanged) ──────────────────────────────────────────

  Widget _buildPremiumAdminCard(
      BuildContext context,
      MemberController memberController,
      KasController kasController,
      AuthController authController) {
    final canManageKas = authController.currentUser.value?.canManageKas ?? false;
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
                color: Colors.black.withOpacity(0.3),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
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
                        if (canManageKas) ...[
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
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

  Widget _buildModernManagementGrid(
      BuildContext context, AuthController authController) {
    final canManageKas =
        authController.currentUser.value?.canManageKas ?? false;

    final allItems = [
      {
        'icon': Icons.group_add_rounded,
        'label': 'Anggota',
        'route': AppRoutes.memberList,
        'color': AppColors.primary,
        'requiresKas': false,
      },
      {
        'icon': Icons.event_note_rounded,
        'label': 'Kegiatan',
        'route': AppRoutes.eventList,
        'color': AppColors.secondary,
        'requiresKas': false,
      },
      {
        'icon': Icons.add_photo_alternate_rounded,
        'label': 'Galeri',
        'route': AppRoutes.galleryAdmin,
        'color': AppColors.accentGreen,
        'requiresKas': false,
      },
      {
        'icon': Icons.payments_rounded,
        'label': 'Kas',
        'route': AppRoutes.kasPage,
        'color': AppColors.accentRed,
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
                  border:
                      Border.all(color: color.withOpacity(0.15), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
        padding: EdgeInsets.zero,
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
          final count =
              memberList.where((m) => m.divisions.contains(division)).length;
          final totalMembers = memberList.length;
          final pct = totalMembers == 0 ? 0.0 : count / totalMembers;

          return InkWell(
            onTap: () => Get.toNamed(AppRoutes.memberList, arguments: division),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withOpacity(0.12), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Mini progress bar proporsi anggota
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 4,
                          backgroundColor: color.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(pct * 100).round()}% dari total',
                        style: const TextStyle(
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
