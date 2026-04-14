import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_controller.dart';
import '../../models/user_model.dart';
import '../widgets/division_badge.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/member_bottom_nav.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class MemberListReadonlyPage extends StatelessWidget {
  const MemberListReadonlyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberController());

    return Scaffold(
      appBar: AppBar(title: const Text('Anggota')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                // Search
                TextField(
                  onChanged: controller.searchQuery.call,
                  decoration: const InputDecoration(
                    hintText: 'Cari nama atau NIM...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter chips divisi
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      'Semua',
                      ...AppConstants.divisions,
                    ].map((division) {
                      return Obx(() {
                        final isSelected =
                            controller.selectedDivision.value == division;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(division),
                            selected: isSelected,
                            onSelected: (_) =>
                                controller.filterByDivision(division),
                            selectedColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.15),
                            checkmarkColor:
                                Theme.of(context).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingSkeletonList();
              }
              if (controller.filteredMembers.isEmpty) {
                return const EmptyState(
                  message: 'Tidak ada anggota',
                  subtitle: 'Coba ubah filter atau kata kunci pencarian',
                  icon: Icons.people_outline,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: controller.filteredMembers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final member = controller.filteredMembers[i];
                  return _MemberReadonlyCard(member: member);
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const MemberBottomNav(currentIndex: 0),
    );
  }
}

class _MemberReadonlyCard extends StatelessWidget {
  final UserModel member;

  const _MemberReadonlyCard({required this.member});

  @override
  Widget build(BuildContext context) {
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
            radius: 24,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.12),
            backgroundImage: member.avatarUrl != null
                ? CachedNetworkImageProvider(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? Text(
                    member.fullName.isNotEmpty
                        ? member.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${member.nim} • Angkatan ${member.angkatan ?? '-'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (member.divisions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: member.divisions
                        .map((d) => DivisionBadge(division: d))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status aktif
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: member.isActive
                  ? AppColors.accentGreen.withOpacity(0.1)
                  : AppColors.accentRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              member.isActive ? 'Aktif' : 'Non-aktif',
              style: TextStyle(
                color: member.isActive
                    ? AppColors.accentGreen
                    : AppColors.accentRed,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
