import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/empty_state.dart';

class EventVisitorPage extends StatelessWidget {
  const EventVisitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();
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
                'Kegiatan UKM',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Search
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: controller.searchQuery.call,
                      decoration: InputDecoration(
                        hintText: 'Cari kegiatan publik...',
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
                  const SizedBox(height: 20),
                  
                  // kalender
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Obx(() => TableCalendar(
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
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                          },
                          eventLoader: (day) => controller.getEventsForDay(day),
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            outsideDaysVisible: false,
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            leftChevronIcon: Icon(Icons.chevron_left_rounded, color: colorScheme.primary),
                            rightChevronIcon: Icon(Icons.chevron_right_rounded, color: colorScheme.primary),
                          ),
                        )),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        final day = controller.selectedDay.value;
                        final dateStr = day != null 
                          ? '${day.day}-${day.month}-${day.year}'
                          : 'Daftar Kegiatan';
                        return Text(
                          'Kegiatan: $dateStr',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Obx(() {
            final List<EventModel> events = controller.filteredEvents;

            if (events.isEmpty) {
              return const SliverFillRemaining(
                child: EmptyState(
                  message: 'Tidak ada kegiatan publik',
                  subtitle: 'Pilih tanggal lain di kalender',
                  icon: Icons.event_busy_rounded,
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EventCard(event: events[i]),
                  ),
                  childCount: events.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
