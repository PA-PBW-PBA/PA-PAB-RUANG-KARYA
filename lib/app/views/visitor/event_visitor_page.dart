import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/event_controller.dart';
import '../widgets/event_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../../../core/constants/app_constants.dart';

class EventVisitorPage extends StatelessWidget {
  const EventVisitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventController());

    return Scaffold(
      appBar: AppBar(title: const Text('Kegiatan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: controller.searchQuery.call,
                  decoration: const InputDecoration(
                    hintText: 'Cari kegiatan...',
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
              if (controller.filteredEvents.isEmpty) {
                return const EmptyState(
                  message: 'Belum ada kegiatan',
                  subtitle: 'Kegiatan akan muncul di sini',
                  icon: Icons.event_outlined,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredEvents.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) =>
                    EventCard(event: controller.filteredEvents[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}
