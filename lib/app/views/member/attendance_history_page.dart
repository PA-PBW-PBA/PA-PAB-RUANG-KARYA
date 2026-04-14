import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../../../core/theme/app_colors.dart';

class AttendanceHistoryPage extends StatelessWidget {
  const AttendanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. App Bar
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
                'Absensi Saya',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),

          // 2. Stat Card Section
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('${controller.totalEvents}', 'Total'),
                      _statDivider(),
                      _statItem('${controller.totalHadir}', 'Hadir'),
                      _statDivider(),
                      _statItem('${controller.attendancePercentage}%', 'Ratio'),
                    ],
                  ),
                ),
              );
            }),
          ),

          // 3. Header List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'RIWAYAT KEHADIRAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          // 4. Content (List Riwayat)
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: LoadingSkeletonList(),
                ),
              );
            }

            if (controller.myAttendances.isEmpty) {
              return const SliverFillRemaining(
                child: EmptyState(
                  message: 'Belum ada data absensi',
                  subtitle: 'Riwayat kehadiranmu akan muncul di sini',
                  icon: Icons.checklist_outlined,
                ),
              );
            }

            // PERBAIKAN UTAMA: Menggunakan SliverList agar lazy loading dan tidak ANR
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final item = controller.myAttendances[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _getStatusColor(item.status).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getStatusIcon(item.status),
                                size: 20,
                                color: _getStatusColor(item.status),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.eventTitle,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(item.createdAt),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _statusBadge(item.status),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: controller.myAttendances.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _statDivider() {
    return Container(height: 30, width: 1, color: Colors.white.withOpacity(0.2));
  }

  Color _getStatusColor(String status) {
    if (status == 'hadir') return AppColors.accentGreen;
    if (status == 'izin') return AppColors.secondary;
    return AppColors.accentRed;
  }

  IconData _getStatusIcon(String status) {
    if (status == 'hadir') return Icons.check_circle_rounded;
    if (status == 'izin') return Icons.info_rounded;
    return Icons.cancel_rounded;
  }

  Widget _statusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }

  String _formatDate(DateTime date) => 
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}