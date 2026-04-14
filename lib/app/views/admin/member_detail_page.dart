import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_controller.dart';
import '../../controllers/attendance_controller.dart';
import '../../models/user_model.dart';
import '../widgets/division_badge.dart';
import '../../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class MemberDetailPage extends StatelessWidget {
  const MemberDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel member = Get.arguments as UserModel;
    final memberController = Get.find<MemberController>();
    final attendanceController = Get.put(AttendanceController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    attendanceController.fetchMemberAttendances(member.id);

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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.back(),
            ),
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.2,
              title: Text(
                'Detail Anggota',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_note_rounded),
                onPressed: () => Get.toNamed(
                  AppRoutes.memberForm,
                  arguments: member,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              final attendances = attendanceController.myAttendances;
              final total = attendances.length;
              final hadir = attendances.where((a) => a.isHadir).length;
              final percentage = total == 0 ? 0 : ((hadir / total) * 100).round();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Profil Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.2),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: colorScheme.primary.withOpacity(0.1),
                              backgroundImage: member.avatarUrl != null
                                  ? CachedNetworkImageProvider(member.avatarUrl!)
                                  : null,
                              child: member.avatarUrl == null
                                  ? Text(
                                      member.fullName.isNotEmpty
                                          ? member.fullName[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w800,
                                        color: colorScheme.primary,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            member.fullName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.nim,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: member.divisions
                                .map((d) => DivisionBadge(division: d))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                          _buildStatusAction(context, member, memberController),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Kehadiran Section
                    _buildSectionHeader('RINGKASAN KEHADIRAN'),
                    const SizedBox(height: 12),
                    Container(
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
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem('$total', 'Total'),
                          _statDivider(),
                          _statItem('$hadir', 'Hadir'),
                          _statDivider(),
                          _statItem('$percentage%', 'Ratio'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Profil Section
                    _buildSectionHeader('INFORMASI DETAIL'),
                    const SizedBox(height: 12),
                    _buildInfoTile(context, Icons.school_rounded, 'Angkatan', member.angkatan ?? '-'),
                    _buildInfoTile(context, Icons.phone_android_rounded, 'Nomor HP', member.phone ?? '-'),
                    _buildInfoTile(context, Icons.email_rounded, 'Alamat Email', member.email),
                    
                    const SizedBox(height: 60),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusAction(BuildContext context, UserModel member, MemberController controller) {
    final isActive = member.isActive;
    final color = isActive ? AppColors.accentRed : AppColors.accentGreen;
    
    return OutlinedButton.icon(
      onPressed: () => _confirmToggleStatus(context, controller, member),
      icon: Icon(isActive ? Icons.person_off_rounded : Icons.person_add_rounded, size: 18),
      label: Text(isActive ? 'Nonaktifkan Akun' : 'Aktifkan Akun'),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: color.withOpacity(0.02),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('${action.capitalizeFirst} Anggota'),
        content: Text('Yakin ingin $action akun ${member.fullName}?'),
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
                  ? AppColors.accentRed
                  : AppColors.accentGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(action.capitalizeFirst!),
          ),
        ],
      ),
    );
  }
}