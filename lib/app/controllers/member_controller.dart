import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class MemberController extends GetxController {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final members = <UserModel>[].obs;
  final filteredMembers = <UserModel>[].obs;
  final searchQuery = ''.obs;
  final selectedDivision = 'Semua'.obs;
  final pickedAvatarFile = Rxn<XFile>();

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
    ever(searchQuery, (_) => _applyFilter());
    ever(selectedDivision, (_) => _applyFilter());
  }

  // --- FITUR DIPERBARUI: Admin Reset Password ---
  // Sekarang mengembalikan String? (password baru) agar bisa di-copy di UI
  Future<String?> adminResetPassword(String userId, String nim) async {
    isLoading.value = true;
    errorMessage.value = '';
    const newPassword = 'Password123!';

    try {
      // Memanggil fungsi RPC di Supabase
      await _supabase.rpc('reset_user_password', params: {
        'target_user_id': userId,
        'new_password': newPassword,
      });

      // Snack bar ini opsional, bisa dihilangkan jika dialog sukses sudah cukup
      Get.snackbar('Berhasil', 'Password NIM $nim telah direset.');

      return newPassword;
    } catch (e) {
      errorMessage.value = 'Gagal mereset password.';
      Get.snackbar('Gagal', 'Terjadi kesalahan saat mereset password.');
      return null; // Return null jika gagal
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMembers() async {
    isLoading.value = true;
    try {
      final response = await _supabase
          .from('profiles')
          .select('*, member_divisions(divisions(name))')
          .eq('role', 'anggota')
          .eq('is_active', true)
          .order('full_name');

      members.value = response.map<UserModel>((json) {
        final divisions = (json['member_divisions'] as List)
            .map((e) => e['divisions']?['name'] as String?)
            .whereType<String>()
            .toList();
        final data = Map<String, dynamic>.from(json);
        data['divisions'] = divisions;
        return UserModel.fromJson(data);
      }).toList();

      _applyFilter();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data anggota';
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    var result = members.toList();

    if (selectedDivision.value != 'Semua') {
      result = result
          .where((m) => m.divisions.contains(selectedDivision.value))
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result
          .where((m) =>
              m.fullName.toLowerCase().contains(query) ||
              m.nim.toLowerCase().contains(query))
          .toList();
    }

    filteredMembers.value = result;
  }

  void filterByDivision(String division) {
    selectedDivision.value = division;
  }

  int getMemberCountByDivision(String division) {
    return members.where((m) => m.divisions.contains(division)).length;
  }

  Future<void> pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) pickedAvatarFile.value = file;
  }

  Future<void> createMember({
    required String nim,
    required String fullName,
    required String email,
    required String phone,
    required String angkatan,
    required String password,
    required List<String> divisions,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final authResponse = await _supabase.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          userMetadata: {'role': 'anggota'},
          emailConfirm: true,
        ),
      );

      final userId = authResponse.user?.id;
      if (userId == null) throw Exception('Gagal membuat akun');

      String? avatarUrl;
      if (pickedAvatarFile.value != null) {
        avatarUrl = await _uploadAvatar(userId);
      }

      await _supabase.from('profiles').insert({
        'id': userId,
        'nim': nim,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'angkatan': angkatan,
        'role': 'anggota',
        'avatar_url': avatarUrl,
        'is_active': true,
        'is_first_login': true,
      });

      await _insertDivisions(userId, divisions);

      pickedAvatarFile.value = null;
      await fetchMembers();
      Get.back();
      Get.snackbar('Berhasil', 'Anggota berhasil ditambahkan');
    } catch (e) {
      errorMessage.value = 'Gagal menambah anggota. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMember({
    required String id,
    required String fullName,
    required String email,
    required String phone,
    required String angkatan,
    required List<String> divisions,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? avatarUrl;
      if (pickedAvatarFile.value != null) {
        avatarUrl = await _uploadAvatar(id);
      }

      final updateData = {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'angkatan': angkatan,
      };
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      await _supabase.from('profiles').update(updateData).eq('id', id);

      await _supabase.from('member_divisions').delete().eq('user_id', id);
      await _insertDivisions(id, divisions);

      pickedAvatarFile.value = null;
      await fetchMembers();
      Get.back();
      Get.snackbar('Berhasil', 'Data anggota berhasil diperbarui');
    } catch (e) {
      errorMessage.value = 'Gagal memperbarui data. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMember(String id) async {
    try {
      await _supabase
          .from('profiles')
          .update({'is_active': false}).eq('id', id);
      await fetchMembers();
      Get.snackbar('Berhasil', 'Anggota berhasil dihapus');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus anggota');
    }
  }

  Future<void> toggleMemberStatus(String id, bool isActive) async {
    try {
      await _supabase
          .from('profiles')
          .update({'is_active': isActive}).eq('id', id);
      await fetchMembers();
      final status = isActive ? 'diaktifkan' : 'dinonaktifkan';
      Get.snackbar('Berhasil', 'Anggota berhasil $status');
      Get.back();
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal mengubah status anggota');
    }
  }

  Future<String?> _uploadAvatar(String userId) async {
    try {
      final file = pickedAvatarFile.value!;
      final bytes = await file.readAsBytes();
      final ext = file.path.split('.').last;
      final path = '$userId/avatar.$ext';

      await _supabase.storage
          .from(AppConstants.bucketAvatars)
          .uploadBinary(path, bytes, fileOptions: FileOptions(upsert: true));

      return _supabase.storage
          .from(AppConstants.bucketAvatars)
          .getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  Future<void> _insertDivisions(String userId, List<String> divisions) async {
    if (divisions.isEmpty) return;

    final divisionResponse = await _supabase
        .from('divisions')
        .select('id, name')
        .inFilter('name', divisions);

    final rows = divisionResponse
        .map((d) => {
              'user_id': userId,
              'division_id': d['id'],
            })
        .toList();

    await _supabase.from('member_divisions').insert(rows);
  }
}
