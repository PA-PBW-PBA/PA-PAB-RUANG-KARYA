import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/division_badge.dart';
import '../widgets/member_bottom_nav.dart';
import '../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class ProfileMemberPage extends StatelessWidget {
  const ProfileMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Obx(() {
        final user = authController.currentUser.value;
        if (user == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Avatar read-only (BUG FIX #3: tombol kamera dihapus)
              CircleAvatar(
                radius: 48,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.15),
                backgroundImage: user.avatarUrl != null
                    ? CachedNetworkImageProvider(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(user.fullName,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(user.nim, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 10),
              // Badge status aktif
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.accentRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: user.isActive
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.accentRed.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: user.isActive
                          ? AppColors.success
                          : AppColors.accentRed,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.isActive ? 'Anggota Aktif' : 'Anggota Nonaktif',
                      style: TextStyle(
                        color: user.isActive
                            ? AppColors.success
                            : AppColors.accentRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: user.divisions
                    .map((d) => DivisionBadge(division: d))
                    .toList(),
              ),
              const SizedBox(height: 24),
              _infoCard(context, Icons.school_outlined, 'Angkatan',
                  user.angkatan ?? '-'),
              const SizedBox(height: 8),
              _infoCard(
                  context, Icons.phone_outlined, 'Nomor HP', user.phone ?? '-'),
              const SizedBox(height: 24),
              // BUG FIX #3: Tombol "Edit Profil" dihapus. Hanya admin yg bisa edit.
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.changePassword),
                  icon: const Icon(Icons.lock_reset_rounded),
                  label: const Text('Ganti Password'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmLogout(context, authController),
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
      bottomNavigationBar: const MemberBottomNav(currentIndex: 3),
    );
  }

  Widget _infoCard(
      BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
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

  void _confirmLogout(BuildContext context, AuthController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}