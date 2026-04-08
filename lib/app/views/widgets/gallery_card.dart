import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/gallery_model.dart';
import '../../../core/theme/app_colors.dart';

class GalleryCard extends StatelessWidget {
  final GalleryModel gallery;
  final VoidCallback? onTap;
  final bool showAdminActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GalleryCard({
    super.key,
    required this.gallery,
    this.onTap,
    this.showAdminActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: theme.cardColor,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 0.85,
                  child: CachedNetworkImage(
                    imageUrl: gallery.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: theme.dividerColor.withOpacity(0.1),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: theme.dividerColor.withOpacity(0.1),
                      child: const Icon(Icons.broken_image_rounded, color: AppColors.textSecondary),
                    ),
                  ),
                ),
                
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      gallery.caption ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.getDivisionColor(gallery.divisionName).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      gallery.divisionName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                
                if (showAdminActions)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Row(
                      children: [
                        _actionButton(
                          icon: Icons.edit_rounded,
                          color: Colors.white,
                          bgColor: Colors.blue.withOpacity(0.8),
                          onTap: onEdit,
                        ),
                        const SizedBox(width: 6),
                        _actionButton(
                          icon: Icons.delete_rounded,
                          color: Colors.white,
                          bgColor: Colors.red.withOpacity(0.8),
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Icon(icon, color: color, size: 14),
      ),
    );
  }
}
