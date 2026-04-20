import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/admin_bottom_nav.dart';
import '../../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class ProfileAdminPage extends StatelessWidget {
  const ProfileAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Profil Saya',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              final user = authController.currentUser.value;
              if (user == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        backgroundImage: user.avatarUrl != null
                            ? CachedNetworkImageProvider(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(
                                user.fullName.isNotEmpty
                                    ? user.fullName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      user.fullName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.isBendahara
                            ? 'Administrator — Bendahara'
                            : 'Administrator — BPH',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    _buildSectionHeader('INFORMASI AKUN'),
                    const SizedBox(height: 16),
                    _buildInfoTile(context, Icons.badge_rounded,
                        'NIM / ID Pengguna', user.nim),
                    _buildInfoTile(context, Icons.email_rounded, 'Alamat Email',
                        user.email),
                    if (user.phone != null)
                      _buildInfoTile(context, Icons.phone_android_rounded,
                          'Nomor WhatsApp', user.phone!),

                    const SizedBox(height: 32),
                    _buildSectionHeader('PENGATURAN'),
                    const SizedBox(height: 16),

                    // Ganti Password
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Get.toNamed(AppRoutes.changePassword),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: colorScheme.primary.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.lock_reset_rounded,
                                    color: colorScheme.primary, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Ganti Password',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.chevron_right_rounded,
                                  color: colorScheme.primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Logout
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _confirmLogout(context, authController),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.accentRed.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.accentRed.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accentRed.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.logout_rounded,
                                    color: AppColors.accentRed, size: 20),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Keluar dari Aplikasi',
                                style: TextStyle(
                                  color: AppColors.accentRed,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.accentRed, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 5),
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

  Widget _buildInfoTile(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Konfirmasi Keluar'),
        content: const Text(
            'Apakah Anda yakin ingin mengakhiri sesi admin saat ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
