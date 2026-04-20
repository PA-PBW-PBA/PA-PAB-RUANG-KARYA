class GalleryModel {
  final String id;
  final String divisionId;
  final String divisionName;
  final String imageUrl;
  final String? caption;
  final String uploadedBy;
  final DateTime createdAt;

  GalleryModel({
    required this.id,
    required this.divisionId,
    required this.divisionName,
    required this.imageUrl,
    this.caption,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['id'] ?? '',
      divisionId: json['division_id'] ?? '',
      divisionName: json['divisions']?['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      caption: json['caption'],
      uploadedBy: json['uploaded_by'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'division_id': divisionId,
      'image_url': imageUrl,
      'caption': caption,
      'uploaded_by': uploadedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // METHOD COPYWITH (Tambahan untuk mendukung update UI instan)
  GalleryModel copyWith({
    String? id,
    String? divisionId,
    String? divisionName,
    String? imageUrl,
    String? caption,
    String? uploadedBy,
    DateTime? createdAt,
  }) {
    return GalleryModel(
      id: id ?? this.id,
      divisionId: divisionId ?? this.divisionId,
      divisionName: divisionName ?? this.divisionName,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
