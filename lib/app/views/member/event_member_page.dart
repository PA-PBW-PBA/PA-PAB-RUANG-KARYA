import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/member_bottom_nav.dart';
import '../../routes/app_routes.dart';

class EventMemberPage extends StatelessWidget {
  const EventMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFF7F8FC),
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Get.offAllNamed(AppRoutes.homeMember),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEDE9FE),
                      Color(0xFFDCE7FF),
                      Color(0xFFF5E8FF),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -10,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.60),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.calendar_month_rounded,
                                color: colorScheme.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jadwal Kegiatan',
                                    style:
                                        theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF27314D),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cek agenda dan kegiatan terbaru anggota',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF6F7890),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: controller.searchQuery.call,
                      decoration: InputDecoration(
                        hintText: 'Cari kegiatan...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF98A2B3),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  Obx(() {
                    final _ = controller.events.length;

                    return Container(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFE9ECF5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TableCalendar(
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
                        rowHeight: 46,
                        daysOfWeekHeight: 30,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle:
                              theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF27314D),
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left_rounded,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                          headerPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                          weekendStyle: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          defaultTextStyle: const TextStyle(
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                          weekendTextStyle: const TextStyle(
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                          todayDecoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.28),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          selectedTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 3,
                          markerMargin: const EdgeInsets.symmetric(
                            horizontal: 1.2,
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        final day = controller.selectedDay.value;
                        final dateStr = day != null
                            ? '${day.day}-${day.month}-${day.year}'
                            : 'Daftar Kegiatan';

                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kegiatan',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF8A94A6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateStr,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  color: const Color(0xFF27314D),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(width: 12),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${controller.filteredEvents.length} Event',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
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
                hasScrollBody: false,
                child: EmptyState(
                  message: 'Tidak ada kegiatan di tanggal ini',
                  subtitle: 'Pilih tanggal lain di kalender',
                  icon: Icons.event_busy_rounded,
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
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
      bottomNavigationBar: const MemberBottomNav(currentIndex: 1),
    );
  }
}