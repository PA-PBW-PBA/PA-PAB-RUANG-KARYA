import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_controller.dart';
import '../../controllers/attendance_controller.dart';
import '../../models/user_model.dart';
import '../widgets/division_badge.dart';
import '../../../core/theme/app_colors.dart';

class MemberDetailPage extends StatelessWidget {
  const MemberDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel member = Get.arguments as UserModel;
    final memberController = Get.find<MemberController>();
    final attendanceController = Get.put(AttendanceController());

    attendanceController.fetchMemberAttendances(member.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Anggota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Get.toNamed(
              '/member-form',
              arguments: member,
            ),
          ),
        ],
      ),
      body: Obx(() {
        final attendances = attendanceController.myAttendances;
        final total = attendances.length;
        final hadir = attendances.where((a) => a.isHadir).length;
        final percentage = total == 0 ? 0 : ((hadir / total) * 100).round();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.15),
                      backgroundImage: member.avatarUrl != null
                          ? CachedNetworkImageProvider(member.avatarUrl!)
                          : null,
                      child: member.avatarUrl == null
                          ? Text(
                              member.fullName.isNotEmpty
                                  ? member.fullName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      member.fullName,
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.nim,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: member.divisions
                          .map((d) => DivisionBadge(division: d))
                          .toList(),
                    ),
                    const SizedBox(height: 12),

                    // Status aktif toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: member.isActive
                                ? AppColors.accentGreen.withOpacity(0.1)
                                : AppColors.accentRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: member.isActive
                                  ? AppColors.accentGreen
                                  : AppColors.accentRed,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            member.isActive ? 'Aktif' : 'Tidak Aktif',
                            style: TextStyle(
                              color: member.isActive
                                  ? AppColors.accentGreen
                                  : AppColors.accentRed,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => _confirmToggleStatus(
                            context,
                            memberController,
                            member,
                          ),
                          child: Text(
                            member.isActive ? 'Nonaktifkan' : 'Aktifkan',
                            style: TextStyle(
                              color: member.isActive
                                  ? AppColors.accentRed
                                  : AppColors.accentGreen,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistik absensi
              Text(
                'Statistik Kehadiran',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem(context, '$total', 'Total Kegiatan'),
                    _divider(),
                    _statItem(context, '$hadir', 'Hadir'),
                    _divider(),
                    _statItem(context, '$percentage%', 'Kehadiran'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info
              Text(
                'Informasi',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              _infoCard(context, Icons.school_outlined, 'Angkatan',
                  member.angkatan ?? '-'),
              const SizedBox(height: 8),
              _infoCard(context, Icons.phone_outlined, 'Nomor HP',
                  member.phone ?? '-'),
              const SizedBox(height: 8),
              _infoCard(context, Icons.email_outlined, 'Email', member.email),
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }

  Widget _statItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _infoCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmToggleStatus(
    BuildContext context,
    MemberController controller,
    UserModel member,
  ) {
    final action = member.isActive ? 'nonaktifkan' : 'aktifkan';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${action.capitalizeFirst} Anggota'),
        content: Text('Yakin ingin $action ${member.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.toggleMemberStatus(member.id, !member.isActive);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: member.isActive
                  ? Theme.of(context).colorScheme.error
                  : AppColors.accentGreen,
            ),
            child: Text(action.capitalizeFirst!),
          ),
        ],
      ),
    );
  }
}
