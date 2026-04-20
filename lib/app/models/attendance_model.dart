class AttendanceModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String userId;
  final String userName;
  final String status;
  final String createdBy;
  final DateTime createdAt;

  AttendanceModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.userId,
    required this.userName,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isHadir => status == 'hadir';
  bool get isTidakHadir => status == 'tidak_hadir';
  bool get isIzin => status == 'izin';

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      eventId: json['event_id'] ?? '',
      eventTitle: json['events']?['title'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['profiles']?['full_name'] ?? '',
      status: json['status'] ?? 'tidak_hadir',
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
