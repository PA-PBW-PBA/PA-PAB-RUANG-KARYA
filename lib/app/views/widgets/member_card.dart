import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import 'division_badge.dart';

class MemberCard extends StatelessWidget {
  final UserModel member;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Jika true, tampilkan badge Aktif/Nonaktif (berguna di halaman admin)
  final bool showStatusBadge;

  const MemberCard({
    super.key,
    required this.member,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showStatusBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.divider,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.08),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary.withOpacity(0.05),
                          backgroundImage: member.avatarUrl != null
                              ? CachedNetworkImageProvider(member.avatarUrl!)
                              : null,
                          child: member.avatarUrl == null
                              ? Text(
                                  member.fullName.isNotEmpty
                                      ? member.fullName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (showStatusBadge)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: member.isActive
                                  ? AppColors.success
                                  : AppColors.danger,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 18),

                  // Info Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                member.fullName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (showStatusBadge)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: member.isActive
                                      ? AppColors.success.withOpacity(0.1)
                                      : AppColors.danger.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  member.isActive ? 'AKTIF' : 'NONAKTIF',
                                  style: TextStyle(
                                    color: member.isActive
                                        ? AppColors.success
                                        : AppColors.danger,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                member.nim,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.divider,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Angkatan ${member.angkatan ?? '-'}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DivisionChipRow(
                          divisions: member.divisions,
                          maxVisible: 3,
                          size: 26,
                        ),
                      ],
                    ),
                  ),

                  // Action Menu
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.2),
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded,
                                  size: 20, color: AppColors.secondary),
                              const SizedBox(width: 12),
                              const Text(
                                'Edit Profil',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.person_off_rounded,
                                  size: 20, color: AppColors.danger),
                              const SizedBox(width: 12),
                              Text(
                                member.isActive ? 'Nonaktifkan' : 'Aktifkan',
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

