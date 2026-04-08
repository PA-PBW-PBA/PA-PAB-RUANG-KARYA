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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: colorScheme.primary,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.event_available_rounded,
                      size: 80,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusBadge(event.isPublic),
                        const SizedBox(width: 8),
                        ...event.divisions.map((d) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: DivisionBadge(division: d),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // judul
                  Text(
                    event.title,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // jadwal kegiatan
                  Text(
                    'Jadwal Pelaksanaan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        _buildRefinedInfoItem(
                          context,
                          Icons.calendar_today_rounded,
                          'Tanggal',
                          _formatDate(event.startTime),
                          isFirst: true,
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildRefinedInfoItem(
                          context,
                          Icons.access_time_rounded,
                          'Waktu',
                          '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)} WIB',
                        ),
                        if (event.location != null) ...[
                          const Divider(height: 1, indent: 60),
                          _buildRefinedInfoItem(
                            context,
                            Icons.location_on_rounded,
                            'Lokasi',
                            event.location!,
                            isLast: true,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // deskripsi event
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    Text(
                      'Deskripsi Kegiatan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.divider.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        event.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () => Get.snackbar('Info', 'Silakan login terlebih dahulu'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Ikuti Kegiatan', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPublic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPublic ? AppColors.success.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublic ? Icons.public_rounded : Icons.lock_rounded,
            size: 14,
            color: isPublic ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            isPublic ? 'Publik' : 'Internal',
            style: TextStyle(
              color: isPublic ? AppColors.success : AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefinedInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
