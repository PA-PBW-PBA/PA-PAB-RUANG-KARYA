import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class DivisionInfoPage extends StatelessWidget {
  const DivisionInfoPage({super.key});

  static const Map<String, String> _descriptions = {
    'Musik': 'Wadah bagi mahasiswa untuk mengeksplorasi bakat di bidang musik, vokal, dan instrumen. Kami rutin mengadakan latihan bersama dan pertunjukan musik berkala.',
    'Tari': 'Melestarikan budaya melalui seni tari tradisional maupun modern. Fokus pada harmoni gerakan dan ekspresi estetika dalam setiap pertunjukan.',
    'DKV': 'Mengasah kemampuan visual dan desain. Kami mengelola identitas visual UKM serta mempelajari desain grafis, ilustrasi, dan media kreatif lainnya.',
    'Kreatif Event': 'Jantung dari setiap acara UKM. Kami merancang konsep, mengelola teknis lapangan, dan memastikan setiap event memberikan pengalaman tak terlupakan.',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Divisi Kami',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: AppConstants.divisions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (_, i) {
          final division = AppConstants.divisions[i];
          final color = AppColors.getDivisionColor(division);
          return _ModernDivisionCard(
            division: division,
            color: color,
            description: _descriptions[division] ?? '',
          );
        },
      ),
    );
  }
}

class _ModernDivisionCard extends StatefulWidget {
  final String division;
  final Color color;
  final String description;

  const _ModernDivisionCard({
    required this.division,
    required this.color,
    required this.description,
  });

  @override
  State<_ModernDivisionCard> createState() => _ModernDivisionCardState();
}

class _ModernDivisionCardState extends State<_ModernDivisionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: widget.color.withOpacity(_isExpanded ? 0.3 : 0.1),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Main Header Section
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getIcon(widget.division),
                      color: widget.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.division,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Divisi Seni UKM',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(
                    widget.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionBtn(
                          context, 
                          'Anggota', 
                          Icons.people_alt_rounded,
                          () => Get.toNamed(AppRoutes.memberList, arguments: widget.division),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionBtn(
                          context, 
                          'Kegiatan', 
                          Icons.event_note_rounded,
                          () => Get.toNamed(AppRoutes.eventVisitor, arguments: widget.division),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: widget.color.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: widget.color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String division) {
    switch (division) {
      case 'Musik': return Icons.music_note_rounded;
      case 'Tari': return Icons.auto_awesome_rounded;
      case 'DKV': return Icons.palette_rounded;
      case 'Kreatif Event': return Icons.event_available_rounded;
      default: return Icons.category_rounded;
    }
  }
}
