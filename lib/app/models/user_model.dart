class UserModel {
  final String id;
  final String nim;
  final String fullName;
  final String email;
  final String? phone;
  final String? angkatan;
  final String? avatarUrl;
  final String role;
  final bool isBendahara;
  final bool isActive;
  final bool isFirstLogin;
  final List<String> divisions;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.nim,
    required this.fullName,
    required this.email,
    this.phone,
    this.angkatan,
    this.avatarUrl,
    required this.role,
    this.isBendahara = false,
    this.isActive = true,
    this.isFirstLogin = true,
    this.divisions = const [],
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      nim: json['nim'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      angkatan: json['angkatan'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'anggota',
      isBendahara: json['is_bendahara'] ?? false,
      isActive: json['is_active'] ?? true,
      isFirstLogin: json['is_first_login'] ?? true,
      divisions:
          json['divisions'] != null ? List<String>.from(json['divisions']) : [],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nim': nim,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'angkatan': angkatan,
        'avatar_url': avatarUrl,
        'role': role,
        'is_bendahara': isBendahara,
        'is_active': isActive,
        'is_first_login': isFirstLogin,
        'created_at': createdAt.toIso8601String(),
      };

  // Role: 'admin' | 'bph' | 'anggota'
  bool get isAdmin => role == 'admin'; // login email, semua akses
  bool get isBph => role == 'bph'; // login NIM, akses admin minus keuangan
  bool get isAnggota => role == 'anggota';
  bool get canAccessAdmin => isAdmin || isBph; // bisa masuk halaman admin
  bool get canManageKas => isAdmin; // hanya admin penuh
}
