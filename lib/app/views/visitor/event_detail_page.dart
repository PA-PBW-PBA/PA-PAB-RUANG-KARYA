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
    final colorScheme = theme.colorScheme;

    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    // Tentukan warna header dari divisi pertama
    final headerColor = event.divisions.isNotEmpty
        ? AppColors.getDivisionColor(event.divisions.first)
        : colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar dengan foto atau gradient pastel ───────────────
          SliverAppBar(
            expandedHeight: event.imageUrls.isNotEmpty ? 280 : 220,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: headerColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
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
                  // — Badge status + divisi
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatusBadge(isPublic: event.isPublic),
                        const SizedBox(width: 8),
                        ...event.divisions.map((d) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: DivisionBadge(division: d),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // — Judul
                  Text(
                    event.title,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // — Info jadwal
                  _SectionLabel(label: 'Jadwal Pelaksanaan'),
                  const SizedBox(height: 16),
                  _InfoCard(event: event),
                  const SizedBox(height: 32),

                  // — Foto Kegiatan (jika ada lebih dari 1 foto, tampilkan grid)
                  if (event.imageUrls.length > 1) ...[
                    _SectionLabel(label: 'Foto Kegiatan'),
                    const SizedBox(height: 12),
                    _EventPhotoGrid(imageUrls: event.imageUrls),
                    const SizedBox(height: 32),
                  ],

                  // — Deskripsi
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    _SectionLabel(label: 'Deskripsi Kegiatan'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceYellow,
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
          child: isLoggedIn
              ? ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.eventMember),
                  icon: const Icon(Icons.calendar_month_rounded,
                      color: Colors.white),
                  label: const Text('Lihat di Jadwalku',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  icon: const Icon(Icons.login_rounded, color: Colors.white),
                  label: const Text('Login untuk Ikuti Kegiatan',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
        ),
      ),
    );
  }
}

// ======================================================
// HERO IMAGE — foto pertama sebagai hero (bila ada)
// ======================================================
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
          errorWidget: (_, __, ___) => _EventHeroGradient(
              color: Theme.of(context).colorScheme.primary),
        ),
        // Gradient overlay supaya teks di AppBar tetap terbaca
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
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
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, AppColors.secondary],
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
    );
  }
}

// ======================================================
// GRID FOTO KEGIATAN
// ======================================================
class _EventPhotoGrid extends StatelessWidget {
  final List<String> imageUrls;
  const _EventPhotoGrid({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    // Tampilkan maks 6 foto
    final shown = imageUrls.skip(1).take(5).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: shown.length,
      itemBuilder: (context, i) {
        return GestureDetector(
          onTap: () => _showFullImage(context, shown[i]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: shown[i],
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.divider),
            ),
          ),
        );
      },
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveViewer(
                maxScale: 5.0,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 18,
                  child: Icon(Icons.close_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// REUSABLE WIDGETS DALAM FILE INI
// ======================================================

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPublic;
  const _StatusBadge({required this.isPublic});

  @override
  Widget build(BuildContext context) {
    final color = isPublic ? AppColors.success : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublic ? Icons.public_rounded : Icons.lock_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isPublic ? 'Publik' : 'Internal',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _InfoRow(
            context: context,
            icon: Icons.calendar_today_rounded,
            label: 'Tanggal',
            value: _formatDate(event.startTime),
            color: colorScheme.primary,
          ),
          Divider(height: 1, indent: 60, color: AppColors.divider),
          _InfoRow(
            context: context,
            icon: Icons.access_time_rounded,
            label: 'Waktu',
            value:
                '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)} WIB',
            color: colorScheme.primary,
          ),
          if (event.location != null && event.location!.isNotEmpty) ...[
            Divider(height: 1, indent: 60, color: AppColors.divider),
            _InfoRow(
              context: context,
              icon: Icons.location_on_rounded,
              label: 'Lokasi',
              value: event.location!,
              color: colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _InfoRow extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.context,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
