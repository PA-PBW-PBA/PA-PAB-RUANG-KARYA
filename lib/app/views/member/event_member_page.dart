import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/member_bottom_nav.dart';

class EventMemberPage extends StatelessWidget {
  const EventMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Kegiatan')),
      body: Column(
        children: [
          // Tab switcher
          Obx(() => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _tabButton(
                      context,
                      'Kalender',
                      controller.activeTab.value == 0,
                      () => controller.activeTab.value = 0,
                    ),
                    const SizedBox(width: 8),
                    _tabButton(
                      context,
                      'Absensi Saya',
                      controller.activeTab.value == 1,
                      () => Get.toNamed('/attendance-history'),
                    ),
                  ],
                ),
              )),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: controller.searchQuery.call,
              decoration: const InputDecoration(
                hintText: 'Cari kegiatan...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Calendar
          Obx(() => TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: controller.focusedDay.value,
                selectedDayPredicate: (day) =>
                    isSameDay(controller.selectedDay.value, day),
                onDaySelected: (selected, focused) {
                  controller.selectedDay.value = selected;
                  controller.focusedDay.value = focused;
                },
                calendarFormat: CalendarFormat.month,
                eventLoader: (day) => controller.getEventsForDay(day),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: Theme.of(context).textTheme.titleMedium!,
                ),
              )),

          const Divider(height: 1),

          // Events list — kalau ada tanggal dipilih tampil event hari itu,
          // kalau belum pilih tampil semua event mendatang
          Expanded(
            child: Obx(() {
              final List<EventModel> events;
              final bool isFiltered = controller.selectedDay.value != null;

              if (isFiltered) {
                events =
                    controller.getEventsForDay(controller.selectedDay.value!);
              } else {
                // Semua event mendatang, diurutkan dari yang paling dekat
                final now = DateTime.now();
                events = controller.events
                    .where((e) => e.startTime.isAfter(
                          now.subtract(const Duration(days: 1)),
                        ))
                    .toList()
                  ..sort((a, b) => a.startTime.compareTo(b.startTime));
              }

              if (events.isEmpty) {
                return EmptyState(
                  message: isFiltered
                      ? 'Tidak ada kegiatan'
                      : 'Belum ada kegiatan mendatang',
                  subtitle: isFiltered
                      ? 'Pilih tanggal lain untuk melihat kegiatan'
                      : 'Kegiatan baru akan muncul di sini',
                  icon: Icons.event_busy_outlined,
                );
              }

              return ListView.separated(
                // Padding bawah tambahan supaya tidak tertutup BottomNav
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => EventCard(event: events[i]),
              );
            }),
          ),
        ],
      ),
      // Padding bawah di Scaffold agar konten tidak terpotong BottomNav
      bottomNavigationBar: const MemberBottomNav(currentIndex: 1),
    );
  }

  Widget _tabButton(
    BuildContext context,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
