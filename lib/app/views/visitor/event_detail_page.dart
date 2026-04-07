import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/event_model.dart';
import '../widgets/division_badge.dart';
import '../../../core/theme/app_colors.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EventModel event = Get.arguments as EventModel;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                child: Center(
                  child: Icon(
                    Icons.event,
                    size: 80,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge publik/internal + divisi
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      // Badge visibilitas
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.isPublic
                              ? AppColors.accentGreen.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: event.isPublic
                                ? AppColors.accentGreen.withOpacity(0.4)
                                : AppColors.primary.withOpacity(0.4),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              event.isPublic
                                  ? Icons.public_outlined
                                  : Icons.lock_outline,
                              size: 12,
                              color: event.isPublic
                                  ? AppColors.accentGreen
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.isPublic ? 'Publik' : 'Internal',
                              style: TextStyle(
                                color: event.isPublic
                                    ? AppColors.accentGreen
                                    : AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Division badges
                      ...event.divisions.map((d) => DivisionBadge(division: d)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          context,
                          Icons.calendar_today_outlined,
                          'Tanggal',
                          _formatDate(event.startTime),
                        ),
                        const Divider(height: 20),
                        _infoRow(
                          context,
                          Icons.access_time_outlined,
                          'Waktu',
                          '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                        ),
                        if (event.location != null) ...[
                          const Divider(height: 20),
                          _infoRow(
                            context,
                            Icons.location_on_outlined,
                            'Lokasi',
                            event.location!,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Description
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Deskripsi',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.year}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}
