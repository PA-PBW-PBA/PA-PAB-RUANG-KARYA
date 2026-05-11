import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../routes/app_routes.dart';
import '../widgets/empty_state.dart';
import '../widgets/division_badge.dart';
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
                    // Trigger rebuild saat list events berubah
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
                          titleTextStyle:
                              theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                          leftChevronIcon: const Icon(Icons.chevron_left_rounded,
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
              onPressed: () => Get.toNamed(AppRoutes.eventForm),
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
                    onTap: () =>
                        Get.toNamed(AppRoutes.eventForm, arguments: event),
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
      {required IconData icon, required Color color, required VoidCallback onTap}) {
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
                    fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
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