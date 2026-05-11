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
    final divisionColor = AppColors.getDivisionColor(gallery.divisionName);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
      ),
    
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 0.8,
                  child: CachedNetworkImage(
                    imageUrl: gallery.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.divider.withOpacity(0.5),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.divider.withOpacity(0.5),
                      child: const Icon(Icons.broken_image_rounded, color: AppColors.textSecondary),
                    ),
                  ),
                ),
                
                // Overlay Gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.9),
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Caption & Division Info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: divisionColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            gallery.divisionName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          gallery.caption ?? '-',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (showAdminActions)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      children: [
                        _actionButton(
                          icon: Icons.edit_rounded,
                          color: Colors.white,
                          bgColor: Colors.blue.withOpacity(0.9),
                          onTap: onEdit,
                        ),
                        const SizedBox(width: 8),
                        _actionButton(
                          icon: Icons.delete_rounded,
                          color: Colors.white,
                          bgColor: Colors.red.withOpacity(0.9),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6),
          ],
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
