import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/division_filter_bar.dart';
import '../widgets/member_bottom_nav.dart';
import '../../../core/theme/app_colors.dart';

class EventMemberPage extends StatefulWidget {
  const EventMemberPage({super.key});

  @override
  State<EventMemberPage> createState() => _EventMemberPageState();
}

class _EventMemberPageState extends State<EventMemberPage> {
  // FIX 1: Member bisa toggle antara tampilan kalender dan visitor-style list+filter
  bool _isVisitorView = false;
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    return _isVisitorView
        ? _buildVisitorView(context)
        : _buildCalendarView(context);
  }

  // =========================================================
  // TAMPILAN KALENDER (tampilan asli member)
  // =========================================================

  Widget _buildCalendarView(BuildContext context) {
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.back(),
            ),
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
            actions: [
              // FIX 1: Tombol switch ke tampilan visitor
              Tooltip(
                message: 'Tampilan list & filter',
                child: IconButton(
                  icon: Icon(Icons.tune_rounded, color: colorScheme.primary),
                  onPressed: () {
                    controller.resetFilters();
                    setState(() => _isVisitorView = true);
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.2,
              title: Text(
                'Jadwal Kegiatan',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
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
                        hintText: 'Cari kegiatan...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    // ignore: unused_local_variable
                    final dataTrigger = controller.events.length;

                    return Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
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
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: AppColors.accentPink,
                            shape: BoxShape.circle,
                          ),
                          outsideDaysVisible: false,
                          defaultTextStyle:
                              TextStyle(fontWeight: FontWeight.w600),
                          weekendTextStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.danger),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          leftChevronIcon: Icon(Icons.chevron_left_rounded,
                              color: colorScheme.primary),
                          rightChevronIcon: Icon(Icons.chevron_right_rounded,
                              color: colorScheme.primary),
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
                        return Text(
                          'Kegiatan: $dateStr',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        );
                      }),
                      Obx(() => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${controller.filteredEvents.length} Event',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          )),
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
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: EmptyState(
                    message: 'Tidak ada kegiatan di tanggal ini',
                    subtitle: 'Pilih tanggal lain di kalender',
                    icon: Icons.event_busy_rounded,
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
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

  // =========================================================
  // TAMPILAN VISITOR (list + filter divisi, seperti EventVisitorPage)
  // =========================================================

  Widget _buildVisitorView(BuildContext context) {
    final controller = Get.find<EventController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              // Toggle kalender dalam visitor mode
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
              // Tombol kembali ke mode kalender
              Tooltip(
                message: 'Tampilan kalender',
                child: IconButton(
                  icon: Icon(Icons.calendar_month_rounded,
                      color: colorScheme.primary),
                  onPressed: () {
                    controller.resetFilters();
                    setState(() {
                      _isVisitorView = false;
                      _showCalendar = false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 4),
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
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.textSecondary),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FIX 3: Filter divisi tampil di visitor mode
                  Obx(() => DivisionFilterBar(
                        divisions: controller.divisions.toList(),
                        selected: controller.selectedDivision,
                        onSelected: controller.filterByDivision,
                      )),
                  const SizedBox(height: 20),

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
      bottomNavigationBar: const MemberBottomNav(currentIndex: 1),
    );
  }
}
