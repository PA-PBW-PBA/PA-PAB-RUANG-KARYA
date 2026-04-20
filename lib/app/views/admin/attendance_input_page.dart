import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/member_controller.dart';
import '../../models/event_model.dart';
import '../widgets/division_badge.dart';
import '../widgets/loading_skeleton.dart';
import '../../../core/theme/app_colors.dart';

class AttendanceInputPage extends StatefulWidget {
  const AttendanceInputPage({super.key});

  @override
  State<AttendanceInputPage> createState() => _AttendanceInputPageState();
}

class _AttendanceInputPageState extends State<AttendanceInputPage> {
  late EventModel event;
  late AttendanceController attendanceController;
  late MemberController memberController;

  @override
  void initState() {
    super.initState();
    event = Get.arguments as EventModel;
    attendanceController = Get.find<AttendanceController>();
    memberController = Get.find<MemberController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      attendanceController.loadAttendanceForEvent(event.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Presensi Kegiatan',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Event info card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        _buildEventMeta(context, Icons.calendar_today_rounded, 
                          '${_formatDate(event.startTime)} • ${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}'),
                        if (event.location != null) ...[
                          const SizedBox(height: 8),
                          _buildEventMeta(context, Icons.location_on_rounded, event.location!),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: event.divisions
                              .map((d) => DivisionBadge(division: d, fontSize: 10))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Attendance counter
                  Obx(() => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colorScheme.primary.withOpacity(0.12), width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.people_alt_rounded,
                                  color: colorScheme.primary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${attendanceController.hadirCount} Hadir dari ${memberController.members.length} Anggota',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),

                  // Search
                  TextField(
                    onChanged: memberController.searchQuery.call,
                    decoration: InputDecoration(
                      hintText: 'Cari nama anggota...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Member list
          Obx(() {
            if (memberController.isLoading.value) {
              return const SliverFillRemaining(child: LoadingSkeletonList());
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final member = memberController.filteredMembers[i];
                    return Obx(() {
                      final status = attendanceController.getStatus(member.id);
                      return _buildMemberAttendanceTile(context, member, status);
                    });
                  },
                  childCount: memberController.filteredMembers.length,
                ),
              ),
            );
          }),
        ],
      ),

      // Save button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(() => ElevatedButton(
              onPressed: attendanceController.isLoading.value
                  ? null
                  : () => attendanceController.saveAttendance(event.id),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: attendanceController.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Simpan Presensi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            )),
      ),
    );
  }

  Widget _buildEventMeta(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberAttendanceTile(BuildContext context, dynamic member, String status) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Text(
              member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  member.nim,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // 3-state toggle
          Row(
            children: [
              _statusButton(
                context,
                label: 'H',
                color: AppColors.accentGreen,
                isActive: status == 'hadir',
                onTap: () => attendanceController.setStatus(member.id, 'hadir'),
              ),
              const SizedBox(width: 4),
              _statusButton(
                context,
                label: 'I',
                color: AppColors.secondary,
                isActive: status == 'izin',
                onTap: () => attendanceController.setStatus(member.id, 'izin'),
              ),
              const SizedBox(width: 4),
              _statusButton(
                context,
                label: 'T',
                color: AppColors.accentRed,
                isActive: status == 'tidak_hadir',
                onTap: () => attendanceController.setStatus(member.id, 'tidak_hadir'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(
    BuildContext context, {
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.year}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}
