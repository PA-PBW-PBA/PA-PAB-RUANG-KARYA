import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/member_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/admin_bottom_nav.dart';

class MemberListPage extends StatelessWidget {
  const MemberListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MemberController>();

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
                // Filter chips
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
                  message: 'Belum ada anggota',
                  subtitle: 'Tap + untuk tambah anggota baru',
                  icon: Icons.people_outline,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredMembers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final member = controller.filteredMembers[i];
                  return MemberCard(
                    member: member,
                    onTap: () => Get.toNamed(
                      AppRoutes.memberForm,
                      arguments: member,
                    ),
                    onEdit: () => Get.toNamed(
                      AppRoutes.memberForm,
                      arguments: member,
                    ),
                    onDelete: () =>
                        _confirmDelete(context, controller, member.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.memberForm),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: AdminBottomNav(currentIndex: 1),
    );
  }

  void _confirmDelete(
      BuildContext context, MemberController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Anggota'),
        content: const Text('Data anggota akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteMember(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
