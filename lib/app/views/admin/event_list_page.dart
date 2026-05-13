import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../routes/app_routes.dart';
import '../widgets/empty_state.dart';
import '../widgets/division_badge.dart';
import '../widgets/division_filter_bar.dart';
import '../widgets/event_card.dart';
import '../widgets/admin_bottom_nav.dart';
import '../../../core/theme/app_colors.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final controller = Get.find<EventController>();
  late ScrollController _scrollController;
  bool _isFabVisible = true;

  // FIX 1: Toggle tampilan admin vs visitor
  bool _isVisitorView = false;

  // Toggle sub-view di visitor mode (list vs kalender)
  bool _showCalendar = false;

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
    return _isVisitorView
        ? _buildVisitorView(context)
        : _buildAdminView(context);
  }

  // =========================================================
  // ADMIN VIEW (tampilan asli dengan kalender + tombol aksi)
  // =========================================================

  Widget _buildAdminView(BuildContext context) {
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
              onPressed: () => Get.back(),
            ),
            backgroundColor: AppColors.background,
            actions: [
              // FIX 1: tombol switch ke tampilan visitor
              Tooltip(
                message: 'Tampilan pengunjung',
                child: IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined,
                      color: AppColors.primary),
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
                'Agenda Kegiatan',
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
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
                        hintText: 'Cari kegiatan...',
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
                  const SizedBox(height: 24),
                  Obx(() {
                    // ignore: unused_local_variable
                    final dataTrigger = controller.events.length;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColors.divider,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.04),
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
                            fontWeight: FontWeight.w900,
                          ),
                          leftChevronIcon: const Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.primary),
                          rightChevronIcon: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.primary),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        final dateStr = controller.selectedDay.value != null
                            ? '${controller.selectedDay.value!.day} ${_getMonthName(controller.selectedDay.value!)} ${controller.selectedDay.value!.year}'
                            : 'Daftar Kegiatan';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agenda',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              dateStr,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        );
                      }),
                      Obx(() => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${controller.filteredEvents.length} EVENT',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Obx(() {
            final events = controller.filteredEvents;
            if (events.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: EmptyState(
                    message: 'Tidak ada kegiatan di tanggal ini',
                    subtitle: 'Tap + untuk membuat kegiatan baru',
                    icon: Icons.event_busy_rounded,
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final event = events[i];
                    return _buildAdminEventCard(context, event);
                  },
                  childCount: events.length,
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
              // FIX 2: pakai navigateToEventForm agar tidak bisa double-tap
              onPressed: () => controller.navigateToEventForm(),
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'KEGIATAN BARU',
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
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }

  // =========================================================
  // VISITOR VIEW (tampilan seperti EventVisitorPage, tapi ada
  // tombol kembali ke mode admin di pojok kanan)
  // =========================================================

  Widget _buildVisitorView(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: CustomScrollView(
        controller: _scrollController,
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
              // Toggle kalender / list (sama seperti visitor asli)
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
              // FIX 1: Tombol kembali ke mode admin
              Tooltip(
                message: 'Mode admin',
                child: IconButton(
                  icon: const Icon(Icons.admin_panel_settings_outlined,
                      color: AppColors.primary),
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

                  // Filter Divisi (sama seperti visitor)
                  Obx(() => DivisionFilterBar(
                        divisions: controller.divisions.toList(),
                        selected: controller.selectedDivision,
                        onSelected: controller.filterByDivision,
                      )),
                  const SizedBox(height: 20),

                  // Kalender / Header
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

          // List kegiatan (pakai EventCard sama seperti visitor)
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
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
      // FAB tetap muncul di visitor view agar admin bisa tambah kegiatan
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isFabVisible ? 1.0 : 0.0,
        child: Visibility(
          visible: _isFabVisible,
          child: FloatingActionButton(
            onPressed: () => controller.navigateToEventForm(),
            backgroundColor: AppColors.primary,
            elevation: 0,
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }

  Widget _buildAdminEventCard(BuildContext context, EventModel event) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.divider,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Row(
          children: [
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: AppColors.primary.withOpacity(0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${event.startTime.day}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _getMonthName(event.startTime).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!event.isPublic) ...[
                          const Icon(Icons.lock_rounded,
                              size: 12, color: AppColors.primary),
                          const SizedBox(width: 6),
                          const Text(
                            'INTERNAL',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    DivisionChipRow(
                      divisions: event.divisions,
                      maxVisible: 2,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionIcon(
                    icon: Icons.checklist_rtl_rounded,
                    color: AppColors.success,
                    onTap: () => Get.toNamed(AppRoutes.attendanceInput,
                        arguments: event),
                  ),
                  _actionIcon(
                    icon: Icons.edit_note_rounded,
                    color: AppColors.secondary,
                    // FIX 2: pakai navigateToEventForm
                    onTap: () =>
                        controller.navigateToEventForm(editEvent: event),
                  ),
                  _actionIcon(
                    icon: Icons.delete_rounded,
                    color: AppColors.danger,
                    onTap: () => _confirmDelete(context, controller, event.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  static String _getMonthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[date.month - 1];
  }

  void _confirmDelete(
      BuildContext context, EventController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text('Hapus Kegiatan',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Kegiatan akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('BATAL',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteEvent(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('HAPUS',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
