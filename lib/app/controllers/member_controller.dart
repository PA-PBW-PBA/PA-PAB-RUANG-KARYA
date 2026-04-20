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

  // --- Reset Password Admin ---
  Future<String?> adminResetPassword(String userId, String nim) async {
    isLoading.value = true;
    errorMessage.value = '';
    const newPassword = 'Password123!';
    try {
      await _supabase.rpc('reset_user_password', params: {
        'target_user_id': userId,
        'new_password': newPassword,
      });
      Get.snackbar('Berhasil', 'Password NIM $nim telah direset.');
      return newPassword;
    } catch (e) {
      errorMessage.value = 'Gagal mereset password.';
      Get.snackbar('Gagal', 'Terjadi kesalahan saat mereset password.');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // --- Ambil Data Anggota ---
  Future<void> fetchMembers() async {
    isLoading.value = true;
    try {
      // Mengambil role 'anggota' DAN 'admin' agar BPH tetap muncul di list
      final response = await _supabase
          .from('profiles')
          .select('*, member_divisions(divisions(name))')
          .inFilter('role', ['anggota', 'admin'])
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

  // --- Filter & Pencarian ---
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

  // --- Pick Image ---
  Future<void> pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) pickedAvatarFile.value = file;
  }

  // --- Tambah Anggota Baru ---
  Future<void> createMember({
    required String nim,
    required String fullName,
    required String password,
    required String phone,
    required String angkatan,
    required List<String> divisions,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final effectivePassword =
        password.trim().isEmpty ? nim.trim() : password.trim();

    try {
      final response = await _supabase.functions.invoke(
        'create-member',
        body: {
          'nim': nim.trim(),
          'full_name': fullName.trim(),
          'password': effectivePassword,
          'phone': phone.trim(),
          'angkatan': angkatan.trim(),
        },
      );

      final data = response.data as Map<String, dynamic>?;
      final userId = data?['id'] as String?;

      if (userId == null) {
        errorMessage.value = 'Respons server tidak valid. Coba lagi.';
        return;
      }

      if (pickedAvatarFile.value != null) {
        final avatarUrl = await _uploadAvatar(userId);
        if (avatarUrl != null) {
          await _supabase.from('profiles').update({
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', userId);
        }
      }

      await _insertDivisions(userId, divisions);

      pickedAvatarFile.value = null;
      await fetchMembers();
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Anggota $fullName ditambahkan.\n'
            'Login: NIM $nim  |  Password: $effectivePassword',
        duration: const Duration(seconds: 5),
      );
    } on FunctionException catch (e) {
      final body = e.details;
      String msg = (body is Map && body['error'] != null)
          ? body['error'].toString()
          : e.toString();

      if (msg.contains('sudah terdaftar') || msg.contains('sudah memiliki')) {
        errorMessage.value = msg;
      } else if (msg.contains('admin')) {
        errorMessage.value =
            'Akses ditolak. Pastikan kamu login sebagai admin.';
      } else {
        errorMessage.value = 'Gagal: $msg';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan sistem. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  // --- Update Data Anggota (REVISI: Ditambahkan parameter isBph) ---
  Future<void> updateMember({
    required String id,
    required String fullName,
    required String phone,
    required String angkatan,
    required List<String> divisions,
    required bool isBph, // Tambahkan ini agar switch di UI tersimpan
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Update role via Edge Function (Wajib agar lolos check constraint)
      await _supabase.functions.invoke(
        'create-member',
        body: {
          'action': 'set_bph',
          'target_id': id,
          'is_bph': isBph,
        },
      );

      // 2. Update Avatar jika ada
      String? avatarUrl;
      if (pickedAvatarFile.value != null) {
        avatarUrl = await _uploadAvatar(id);
      }

      // 3. Update Profil
      final updateData = <String, dynamic>{
        'full_name': fullName,
        'phone': phone.isEmpty ? null : phone,
        'angkatan': angkatan.isEmpty ? null : angkatan,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      await _supabase.from('profiles').update(updateData).eq('id', id);

      // 4. Update Divisi
      await _supabase.from('member_divisions').delete().eq('user_id', id);
      await _insertDivisions(id, divisions);

      pickedAvatarFile.value = null;
      await fetchMembers();

      Get.back(); // Navigasi keluar dari page Edit
      Get.snackbar('Berhasil', 'Data anggota berhasil diperbarui');
    } catch (e) {
      errorMessage.value = 'Gagal memperbarui data. Coba lagi.';
      Get.snackbar('Gagal', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Hapus/Nonaktifkan Anggota ---
  Future<void> deleteMember(String id) async {
    try {
      await _supabase.from('profiles').update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
      await fetchMembers();
      Get.snackbar('Berhasil', 'Anggota berhasil dinonaktifkan');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menonaktifkan anggota');
    }
  }

  // --- Toggle BPH Langsung ---
  Future<void> setBph(String memberId, bool isBph) async {
    isLoading.value = true;
    try {
      final response = await _supabase.functions.invoke(
        'create-member',
        body: {
          'action': 'set_bph',
          'target_id': memberId,
          'is_bph': isBph,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data?['success'] == true) {
        await fetchMembers();
        Get.snackbar(
          'Berhasil',
          isBph ? 'Anggota dijadikan BPH' : 'Status BPH anggota dicabut',
        );
      } else {
        Get.snackbar('Gagal', data?['error'] ?? 'Terjadi kesalahan');
      }
    } on FunctionException catch (e) {
      final msg = (e.details as Map?)?['error'] ?? 'Gagal mengubah status BPH';
      Get.snackbar('Gagal', msg.toString());
    } catch (_) {
      Get.snackbar('Gagal', 'Terjadi kesalahan. Coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Toggle Status Aktif ---
  Future<void> toggleMemberStatus(String id, bool isActive) async {
    try {
      await _supabase.from('profiles').update({
        'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
      await fetchMembers();
      Get.snackbar('Berhasil',
          'Anggota berhasil ${isActive ? 'diaktifkan' : 'dinonaktifkan'}');
      Get.back();
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal mengubah status anggota');
    }
  }

  // --- Upload & Insert Division Helper ---
  Future<String?> _uploadAvatar(String userId) async {
    try {
      final file = pickedAvatarFile.value!;
      final bytes = await file.readAsBytes();
      final ext = file.path.split('.').last;
      final path = '$userId/avatar.$ext';
      await _supabase.storage.from(AppConstants.bucketAvatars).uploadBinary(
          path, bytes,
          fileOptions: const FileOptions(upsert: true));
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
    final rows = (divisionResponse as List)
        .map((d) => {'user_id': userId, 'division_id': d['id']})
        .toList();
    await _supabase.from('member_divisions').insert(rows);
  }
}
