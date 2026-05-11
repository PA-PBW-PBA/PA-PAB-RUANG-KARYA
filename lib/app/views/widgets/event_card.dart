import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/event_model.dart';
import 'division_badge.dart';
import '../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = event.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.eventDetail, arguments: event),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail — foto jika ada, icon kalau tidak
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 80,
                height: 80,
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: event.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.primary.withOpacity(0.05),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => _DefaultEventIcon(),
                      )
                    : _DefaultEventIcon(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (!event.isPublic) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_rounded,
                                  size: 10, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'Internal',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          _formatDate(event.startTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Badge jumlah foto
                      if (hasImage)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentNeonBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_rounded,
                                  size: 10, color: AppColors.accentNeonBlue),
                              const SizedBox(width: 3),
                              Text(
                                '${event.imageUrls.length}',
                                style: const TextStyle(
                                  color: AppColors.accentNeonBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location ?? 'Online / TBA',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.divider),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _DefaultEventIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.05),
      child: const Center(
        child: Icon(
          Icons.event_rounded,
          color: AppColors.primary,
          size: 32,
        ),
      ),
    );
  }
}
