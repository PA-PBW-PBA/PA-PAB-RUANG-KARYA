import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/member_controller.dart';
import '../../models/event_model.dart';
import '../widgets/division_badge.dart';
import '../widgets/loading_skeleton.dart';
import '../../../core/theme/app_colors.dart';

class AttendanceInputPage extends StatelessWidget {
  const AttendanceInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EventModel event = Get.arguments as EventModel;
    final attendanceController = Get.find<AttendanceController>();
    final memberController = Get.find<MemberController>();

    attendanceController.loadAttendanceForEvent(event.id);

    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Column(
        children: [
          // Event info card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatDate(event.startTime)} • '
                        '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          event.location!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: event.divisions
                        .map((d) => DivisionBadge(division: d))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // Attendance counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${attendanceController.hadirCount} hadir dari '
                        '${memberController.members.length} anggota',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
          ),
          const SizedBox(height: 8),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: memberController.searchQuery.call,
              decoration: const InputDecoration(
                hintText: 'Cari nama anggota...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Member list with status toggle
          Expanded(
            child: Obx(() {
              if (memberController.isLoading.value) {
                return const LoadingSkeletonList();
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: memberController.filteredMembers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final member = memberController.filteredMembers[i];
                  return Obx(() {
                    final status = attendanceController.getStatus(member.id);
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            child: Text(
                              member.fullName.isNotEmpty
                                  ? member.fullName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  member.nim,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                                onTap: () => attendanceController.setStatus(
                                    member.id, 'hadir'),
                              ),
                              const SizedBox(width: 4),
                              _statusButton(
                                context,
                                label: 'I',
                                color: AppColors.secondary,
                                isActive: status == 'izin',
                                onTap: () => attendanceController.setStatus(
                                    member.id, 'izin'),
                              ),
                              const SizedBox(width: 4),
                              _statusButton(
                                context,
                                label: 'T',
                                color: AppColors.accentRed,
                                isActive: status == 'tidak_hadir',
                                onTap: () => attendanceController.setStatus(
                                    member.id, 'tidak_hadir'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),

      // Save button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Obx(() => ElevatedButton(
              onPressed: attendanceController.isLoading.value
                  ? null
                  : () => attendanceController.saveAttendance(event.id),
              child: attendanceController.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Simpan Absensi'),
            )),
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
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.year}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}
