import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../../controllers/member_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/member_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/admin_bottom_nav.dart';
import '../widgets/division_filter_bar.dart';
import '../../models/user_model.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  final controller = Get.find<MemberController>();
  late ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isFabVisible) setState(() => _isFabVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFabVisible) setState(() => _isFabVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.offNamed(AppRoutes.dashboardAdmin),
            ),
            backgroundColor: AppColors.background,
                  flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.2,
              title: Text(
                'Daftar Anggota',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: controller.searchQuery.call,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau NIM...',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.primary),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(
                            color: AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(
                            color: AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DivisionFilterBar(
                    divisions: ['Semua', ...AppConstants.divisions],
                    selected: controller.selectedDivision,
                    onSelected: controller.filterByDivision,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                child: LoadingSkeletonList(),
              );
            }
            if (controller.filteredMembers.isEmpty) {
              return const SliverFillRemaining(
                child: EmptyState(
                  message: 'Tidak ada anggota ditemukan',
                  subtitle: 'Coba ubah kata kunci atau filter divisi',
                  icon: Icons.people_outline,
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final member = controller.filteredMembers[i];
                    return MemberCard(
                      showStatusBadge: true,
                      member: member,
                      onTap: () => Get.toNamed(
                        AppRoutes.memberDetail,
                        arguments: member,
                      ),
                      onEdit: () => Get.toNamed(
                        AppRoutes.memberForm,
                        arguments: member,
                      ),
                      onDelete: () =>
                          _confirmDelete(context, controller, member),
                    );
                  },
                  childCount: controller.filteredMembers.length,
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isFabVisible ? 1.0 : 0.0,
        child: Visibility(
          visible: _isFabVisible,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => Get.toNamed(AppRoutes.memberForm),
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'TAMBAH ANGGOTA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }

  void _confirmDelete(
      BuildContext context, MemberController controller, UserModel member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text(member.isActive ? 'Nonaktifkan' : 'Aktifkan',
            style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(
            'Konfirmasi status untuk ${member.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('BATAL',
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.toggleMemberStatus(member.id, !member.isActive);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: member.isActive ? AppColors.danger : AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(member.isActive ? 'NONAKTIFKAN' : 'AKTIFKAN',
                style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

