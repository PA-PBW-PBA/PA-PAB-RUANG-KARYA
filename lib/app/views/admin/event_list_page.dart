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
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isFabVisible) setState(() => _isFabVisible = false);
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
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
                'Manajemen Kegiatan',
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
                        final dateStr = controller.selectedDay.value != null 
                          ? '${controller.selectedDay.value!.day}-${controller.selectedDay.value!.month}-${controller.selectedDay.value!.year}'
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            final events = controller.filteredEvents;
            if (events.isEmpty) {
              return const SliverFillRemaining(
                child: EmptyState(
                  message: 'Tidak ada kegiatan di tanggal ini',
                  subtitle: 'Tap + untuk membuat kegiatan baru',
                  icon: Icons.event_busy_rounded,
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
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
          child: FloatingActionButton.extended(
            onPressed: () => Get.toNamed(AppRoutes.eventForm),
            backgroundColor: colorScheme.primary,
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Kegiatan Baru',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
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
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Indicator Side
              Container(
                width: 60,
                color: colorScheme.primary.withOpacity(0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${event.startTime.day}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _getMonthName(event.startTime).toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!event.isPublic) ...[
                            Icon(Icons.lock_outline_rounded, size: 14, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'INTERNAL',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: event.divisions
                            .map((d) => DivisionBadge(division: d, fontSize: 9))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _actionIcon(
                      icon: Icons.checklist_rtl_rounded,
                      color: AppColors.accentGreen,
                      onTap: () => Get.toNamed(AppRoutes.attendanceInput, arguments: event),
                    ),
                    _actionIcon(
                      icon: Icons.edit_note_rounded,
                      color: colorScheme.primary,
                      onTap: () => Get.toNamed(AppRoutes.eventForm, arguments: event),
                    ),
                    _actionIcon(
                      icon: Icons.delete_sweep_rounded,
                      color: AppColors.accentRed,
                      onTap: () => _confirmDelete(context, controller, event.id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  String _getMonthName(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[date.month - 1];
  }

  void _confirmDelete(
      BuildContext context, EventController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Kegiatan'),
        content: const Text('Kegiatan akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteEvent(id);
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
