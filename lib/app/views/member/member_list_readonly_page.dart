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
    // Menggunakan Get.find jika controller sudah di-inject sebelumnya, 
    // atau put jika ini entry point pertama.
    final controller = Get.put(MemberController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. AppBar dengan Tombol Kembali
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
                'Anggota Organisasi',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),

          // 2. Search & Filter Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Search Bar dengan Shadow konsisten
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: controller.searchQuery.call,
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau NIM...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter Chips Divisi
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        'Semua',
                        ...AppConstants.divisions,
                      ].map((division) {
                        return Obx(() {
                          final isSelected =
                              controller.selectedDivision.value == division;
                          final color = division == 'Semua' 
                              ? colorScheme.primary 
                              : AppColors.getDivisionColor(division);

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FilterChip(
                              label: Text(division),
                              selected: isSelected,
                              onSelected: (_) =>
                                  controller.filterByDivision(division),
                              backgroundColor: color.withOpacity(0.05),
                              selectedColor: color.withOpacity(0.15),
                              checkmarkColor: color,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
                                width: 1.5,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected ? color : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          );
                        });
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 3. Member List Content
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: LoadingSkeletonList(),
                ),
              );
            }
            if (controller.filteredMembers.isEmpty) {
              return const SliverFillRemaining(
                child: EmptyState(
                  message: 'Tidak ada anggota',
                  subtitle: 'Coba ubah filter atau kata kunci pencarian',
                  icon: Icons.people_outline,
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final member = controller.filteredMembers[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MemberReadonlyCard(member: member),
                    );
                  },
                  childCount: controller.filteredMembers.length,
                ),
              ),
            );
          }),
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
    final theme = Theme.of(context);
    
    return Container(
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar dengan border halus
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              backgroundImage: member.avatarUrl != null
                  ? CachedNetworkImageProvider(member.avatarUrl!)
                  : null,
              child: member.avatarUrl == null
                  ? Text(
                      member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${member.nim} • Angkatan ${member.angkatan ?? '-'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (member.divisions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: member.divisions
                        .map((d) => DivisionBadge(division: d, fontSize: 9))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: member.isActive
                  ? AppColors.accentGreen.withOpacity(0.1)
                  : AppColors.accentRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (member.isActive ? AppColors.accentGreen : AppColors.accentRed).withOpacity(0.2),
              ),
            ),
            child: Text(
              member.isActive ? 'AKTIF' : 'NONAKTIF',
              style: TextStyle(
                color: member.isActive ? AppColors.accentGreen : AppColors.accentRed,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}