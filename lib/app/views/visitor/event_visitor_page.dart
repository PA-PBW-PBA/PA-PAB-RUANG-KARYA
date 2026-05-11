import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/division_filter_bar.dart';
import '../../../core/theme/app_colors.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'Kegiatan UKM',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => setState(() => _showCalendar = !_showCalendar),
                icon: Icon(
                  _showCalendar
                      ? Icons.grid_view_rounded
                      : Icons.calendar_today_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: controller.searchQuery.call,
                      decoration: InputDecoration(
                        hintText: 'Cari kegiatan seru...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chip Filter Divisi
                  Obx(() => DivisionFilterBar(
                    divisions: controller.divisions.toList(),
                    selected: controller.selectedDivision,
                    onSelected: controller.filterByDivision,
                  )),
                  const SizedBox(height: 24),

                  // Kalender / List Header
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 400),
                    crossFadeState: _showCalendar
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(color: AppColors.divider),
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
                                calendarStyle: const CalendarStyle(
                                  selectedDecoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle),
                                  todayDecoration: BoxDecoration(
                                      color: AppColors.divider,
                                      shape: BoxShape.circle),
                                  todayTextStyle:
                                      TextStyle(color: AppColors.textPrimary),
                                  markerDecoration: BoxDecoration(
                                      color: AppColors.accentPink,
                                      shape: BoxShape.circle),
                                  outsideDaysVisible: false,
                                ),
                                headerStyle: const HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              )),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                    secondChild: Obx(() {
                      final count = controller.filteredEvents.length;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.accentNeonBlue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$count kegiatan ditemukan',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: EventCard(event: events[i]),
                    ),
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
