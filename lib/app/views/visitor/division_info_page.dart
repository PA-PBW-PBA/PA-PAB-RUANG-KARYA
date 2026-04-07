import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class DivisionInfoPage extends StatelessWidget {
  const DivisionInfoPage({super.key});

  static const Map<String, String> _descriptions = {
    'Musik':
        'Divisi yang fokus pada pengembangan bakat musik, vokal, dan instrumen. Aktif dalam berbagai pertunjukan dan kompetisi musik.',
    'Tari':
        'Divisi yang mengembangkan seni tari tradisional dan modern. Rutin tampil di berbagai event budaya dan pertunjukan seni.',
    'DKV':
        'Divisi Desain Komunikasi Visual yang bergerak di bidang desain grafis, ilustrasi, dan visual branding untuk UKM.',
    'Kreatif Event':
        'Divisi yang mengelola dan merancang event kreatif UKM, mulai dari konsep hingga pelaksanaan acara.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Divisi')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: AppConstants.divisions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final division = AppConstants.divisions[i];
          final color = AppColors.getDivisionColor(division);
          return _DivisionCard(
            division: division,
            color: color,
            description: _descriptions[division] ?? '',
          );
        },
      ),
    );
  }
}

class _DivisionCard extends StatefulWidget {
  final String division;
  final Color color;
  final String description;

  const _DivisionCard({
    required this.division,
    required this.color,
    required this.description,
  });

  @override
  State<_DivisionCard> createState() => _DivisionCardState();
}

class _DivisionCardState extends State<_DivisionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(_expanded ? 0 : 16),
                  bottomRight: Radius.circular(_expanded ? 0 : 16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.palette_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.division,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: widget.color,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.toNamed(
                            AppRoutes.memberList,
                            arguments: widget.division,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.color,
                            side: BorderSide(color: widget.color),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Lihat Anggota'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.toNamed(
                            AppRoutes.eventVisitor,
                            arguments: widget.division,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.color,
                            side: BorderSide(color: widget.color),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Lihat Kegiatan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
