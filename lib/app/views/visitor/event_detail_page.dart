import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/event_model.dart';
import '../widgets/division_badge.dart';
import '../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EventModel event = Get.arguments as EventModel;
    final theme = Theme.of(context);

    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    final headerColor = event.divisions.isNotEmpty
        ? AppColors.getDivisionColor(event.divisions.first)
        : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: event.imageUrls.isNotEmpty ? 300 : 220,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrls.isNotEmpty
                  ? _EventHeroImage(imageUrls: event.imageUrls)
                  : _EventHeroGradient(color: headerColor),
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
                        _StatusBadge(isPublic: event.isPublic),
                        const SizedBox(width: 12),
                        ...event.divisions.map((d) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: DivisionBadge(division: d),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    event.title,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _SectionLabel(label: 'Detail Kegiatan', color: AppColors.secondary),
                  const SizedBox(height: 16),
                  _InfoCard(event: event),
                  const SizedBox(height: 32),

                  if (event.imageUrls.length > 1) ...[
                    _SectionLabel(label: 'Dokumentasi', color: AppColors.accentPink),
                    const SizedBox(height: 16),
                    _EventPhotoGrid(imageUrls: event.imageUrls),
                    const SizedBox(height: 32),
                  ],

                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    _SectionLabel(label: 'Deskripsi', color: AppColors.accentPurple),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.divider, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        event.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          height: 1.8,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => isLoggedIn 
                  ? Get.toNamed(AppRoutes.eventMember) 
                  : Get.toNamed(AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isLoggedIn ? Icons.calendar_month_rounded : Icons.login_rounded, 
                      color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    isLoggedIn ? 'Lihat di Jadwalku' : 'Login untuk Ikuti',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventHeroImage extends StatelessWidget {
  final List<String> imageUrls;
  const _EventHeroImage({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: imageUrls.first,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.divider),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.black.withOpacity(0.4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class _EventHeroGradient extends StatelessWidget {
  final Color color;
  const _EventHeroGradient({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.edit_calendar_rounded,
          size: 80,
          color: Colors.white.withOpacity(0.15),
        ),
      ),
    );
  }
}

class _EventPhotoGrid extends StatelessWidget {
  final List<String> imageUrls;
  const _EventPhotoGrid({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    final shown = imageUrls.skip(1).take(3).toList();
    if (shown.isEmpty) return const SizedBox.shrink();

    return Row(
      children: shown.map((url) => Expanded(
        child: GestureDetector(
          onTap: () => _showFullImage(context, url),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: CachedNetworkImageProvider(url),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPublic;
  const _StatusBadge({required this.isPublic});

  @override
  Widget build(BuildContext context) {
    final color = isPublic ? AppColors.success : AppColors.accentPink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPublic ? Icons.public_rounded : Icons.lock_rounded, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            isPublic ? 'PUBLIK' : 'INTERNAL',
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final EventModel event;
  const _InfoCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.divider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(icon: Icons.calendar_today_rounded, label: 'TANGGAL', value: _formatDate(event.startTime), color: AppColors.secondary),
          const Divider(height: 1, indent: 70, color: AppColors.divider),
          _InfoRow(icon: Icons.access_time_rounded, label: 'WAKTU', value: '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)} WIB', color: AppColors.accentPink),
          if (event.location != null && event.location!.isNotEmpty) ...[
            const Divider(height: 1, indent: 70, color: AppColors.divider),
            _InfoRow(icon: Icons.location_on_rounded, label: 'LOKASI', value: event.location!, color: AppColors.accentPurple),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
