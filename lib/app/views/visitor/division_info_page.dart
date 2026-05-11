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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Divisi Kami',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: AppConstants.divisions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (_, i) {
          final division = AppConstants.divisions[i];
          final color = AppColors.getDivisionColor(division);
          return _CreativeDivisionCard(
            division: division,
            color: color,
            description: _descriptions[division] ?? '',
          );
        },
      ),
    );
  }
}

class _CreativeDivisionCard extends StatefulWidget {
  final String division;
  final Color color;
  final String description;

  const _CreativeDivisionCard({
    required this.division,
    required this.color,
    required this.description,
  });

  @override
  State<_CreativeDivisionCard> createState() => _CreativeDivisionCardState();
}

class _CreativeDivisionCardState extends State<_CreativeDivisionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: _isExpanded ? Colors.white : widget.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        boxShadow: _isExpanded ? [
          BoxShadow(
            color: widget.color.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ] : [],
        border: Border.all(
          color: widget.color.withOpacity(_isExpanded ? 0.4 : 0.1),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Section
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isExpanded ? widget.color : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getIcon(widget.division),
                      color: _isExpanded ? Colors.white : widget.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.division,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Seni & Kreativitas',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: widget.color,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: widget.color,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 2,
                    width: 40,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.8,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionBtn(
                          context, 
                          'Anggota', 
                          Icons.people_alt_rounded,
                          () => Get.toNamed(AppRoutes.memberListReadonly, arguments: widget.division),
                        ),
                      ),
                      const SizedBox(width: 16),
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
            duration: const Duration(milliseconds: 400),
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
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.color.withOpacity(0.2), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: widget.color),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
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
