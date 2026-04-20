import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/empty_state.dart';

class EventVisitorPage extends StatefulWidget {
  const EventVisitorPage({super.key});

  @override
  State<EventVisitorPage> createState() => _EventVisitorPageState();
}

class _EventVisitorPageState extends State<EventVisitorPage> {
  bool _showCalendar = false;

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
          // 1. APPBAR - Disederhanakan agar tidak menutupi filter (Hit Test)
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.back(), // Tombol kembali
            ),
            title: Text(
              'Kegiatan UKM',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => setState(() => _showCalendar = !_showCalendar),
                icon: Icon(
                  _showCalendar
                      ? Icons.view_list_rounded
                      : Icons.calendar_month_rounded,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),

          // 2. SEARCH & FILTER SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    onChanged: controller.searchQuery.call,
                    decoration: InputDecoration(
                      hintText: 'Cari kegiatan...',
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
                  const SizedBox(height: 16),

                  // Chip Filter Divisi - Dinamis dari Controller
                  SizedBox(
                    height: 40,
                    child: Obx(() => ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.divisions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final division = controller.divisions[index];
                            return Obx(() {
                              final isSelected =
                                  controller.selectedDivision.value == division;
                              return ChoiceChip(
                                label: Text(division),
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) {
                                    controller.filterByDivision(division);
                                  }
                                },
                                selectedColor:
                                    colorScheme.primary.withOpacity(0.2),
                                backgroundColor: theme.cardColor,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.grey.shade600,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              );
                            });
                          },
                        )),
                  ),
                  const SizedBox(height: 16),

                  // Kalender / List Header
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _showCalendar
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: [
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                                color: theme.dividerColor.withOpacity(0.1)),
                          ),
                          child: Obx(() => TableCalendar(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: controller.focusedDay.value,
                                selectedDayPredicate: (day) => isSameDay(
                                    controller.selectedDay.value, day),
                                eventLoader: controller.getEventsForDay,
                                calendarFormat: CalendarFormat.month,
                                startingDayOfWeek: StartingDayOfWeek.monday,
                                onDaySelected: (selectedDay, focusedDay) {
                                  controller.selectedDay.value = selectedDay;
                                  controller.focusedDay.value = focusedDay;
                                },
                                calendarStyle: CalendarStyle(
                                  selectedDecoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle),
                                  todayDecoration: BoxDecoration(
                                      color:
                                          colorScheme.primary.withOpacity(0.2),
                                      shape: BoxShape.circle),
                                  todayTextStyle:
                                      TextStyle(color: colorScheme.primary),
                                  markerDecoration: BoxDecoration(
                                      color: colorScheme.secondary,
                                      shape: BoxShape.circle),
                                ),
                                headerStyle: const HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                ),
                              )),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    secondChild: Obx(() {
                      final count = controller.filteredEvents.length;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '$count kegiatan ditemukan',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // 3. LIST KEGIATAN
          Obx(() {
            final List<EventModel> events = controller.filteredEvents;

            if (events.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  message: _showCalendar
                      ? 'Tidak ada kegiatan di tanggal ini'
                      : 'Tidak ada kegiatan ditemukan',
                  subtitle: 'Coba pilih divisi atau tanggal yang berbeda',
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
