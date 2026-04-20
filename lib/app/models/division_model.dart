class DivisionModel {
  final String id;
  final String name;
  final String? description;
  final String colorHex;

  DivisionModel({
    required this.id,
    required this.name,
    this.description,
    required this.colorHex,
  });

  factory DivisionModel.fromJson(Map<String, dynamic> json) {
    return DivisionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      colorHex: json['color_hex'] ?? '#3B82F6',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color_hex': colorHex,
    };
  }
}
