import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import '../../core/constants/app_constants.dart';

class AuthController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final currentUser = Rxn<UserModel>();
  final errorMessage = ''.obs;

  // Auto deteksi apakah input email atau NIM
  String _resolveEmail(String input) {
    if (input.contains('@')) {
      // Input adalah email langsung (admin)
      return input.trim();
    } else {
      // Input adalah NIM (anggota) — konversi ke format email
      return '${input.trim()}${AppConstants.supabaseEmailDomain}';
    }
  }

  Future<void> login(String input, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final email = _resolveEmail(input);

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password.trim(),
      );

      if (response.user == null) {
        errorMessage.value = 'NIM/email atau password salah.';
        return;
      }

      await _loadCurrentUser(response.user!.id);

      final user = currentUser.value;
      if (user == null) {
        errorMessage.value = 'Profil tidak ditemukan. Hubungi admin.';
        await _supabase.auth.signOut();
        return;
      }

      if (user.isFirstLogin) {
        Get.offAllNamed(AppRoutes.changePassword);
        return;
      }

      if (user.isAdmin) {
        Get.offAllNamed(AppRoutes.dashboardAdmin);
      } else {
        Get.offAllNamed(AppRoutes.homeMember);
      }
    } on AuthException {
      errorMessage.value = 'NIM/email atau password salah.';
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String newPassword) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      await _supabase.from('profiles').update({'is_first_login': false}).eq(
          'id', _supabase.auth.currentUser!.id);

      await _loadCurrentUser(_supabase.auth.currentUser!.id);

      final user = currentUser.value;
      if (user == null) return;

      Get.snackbar('Berhasil', 'Password berhasil diperbarui');

      if (user.isAdmin) {
        Get.offAllNamed(AppRoutes.dashboardAdmin);
      } else {
        Get.offAllNamed(AppRoutes.homeMember);
      }
    } catch (e) {
      errorMessage.value = 'Gagal mengubah password. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCurrentUser(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*, member_divisions(divisions(name))')
          .eq('id', userId)
          .single();

      final rawDivisions = response['member_divisions'] as List? ?? [];
      final divisions = rawDivisions
          .map((e) {
            final divData = e['divisions'];
            if (divData == null) return null;
            return divData['name'] as String?;
          })
          .whereType<String>()
          .toList();

      final userData = Map<String, dynamic>.from(response);
      userData['divisions'] = divisions;

      currentUser.value = UserModel.fromJson(userData);
    } catch (e) {
      currentUser.value = null;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.homeVisitor);
  }
}
