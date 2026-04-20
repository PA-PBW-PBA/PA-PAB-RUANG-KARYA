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

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final session = _supabase.auth.currentSession;
    if (session != null) await _loadCurrentUser(session.user.id);
  }

  /// Input '@' → email asli (admin)
  /// Input tanpa '@' → NIM → NIM@ruangkarya.id (bph / anggota)
  String _resolveEmail(String input) {
    if (input.contains('@')) return input.trim();
    return '${input.trim()}${AppConstants.supabaseEmailDomain}';
  }

  Future<void> login(String input, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: _resolveEmail(input),
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

      if (!user.isActive) {
        errorMessage.value = 'Akun dinonaktifkan. Hubungi admin.';
        await _supabase.auth.signOut();
        currentUser.value = null;
        return;
      }

      if (user.isFirstLogin) {
        Get.offAllNamed(AppRoutes.changePassword);
        return;
      }

      _redirect(user);
    } on AuthException {
      errorMessage.value = 'NIM/email atau password salah.';
    } catch (_) {
      errorMessage.value = 'Terjadi kesalahan. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  void _redirect(UserModel user) {
    if (user.canAccessAdmin) {
      Get.offAllNamed(AppRoutes.dashboardAdmin);
    } else {
      Get.offAllNamed(AppRoutes.homeMember);
    }
  }

  Future<void> changePassword(String newPassword) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      await _supabase.from('profiles').update({'is_first_login': false}).eq(
          'id', _supabase.auth.currentUser!.id);
      await _loadCurrentUser(_supabase.auth.currentUser!.id);
      final user = currentUser.value;
      if (user == null) return;
      Get.snackbar('Berhasil', 'Password berhasil diperbarui');
      _redirect(user);
    } catch (_) {
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
      final divisions = (response['member_divisions'] as List? ?? [])
          .map((e) => e['divisions']?['name'] as String?)
          .whereType<String>()
          .toList();
      final data = Map<String, dynamic>.from(response);
      data['divisions'] = divisions;
      currentUser.value = UserModel.fromJson(data);
    } catch (_) {
      currentUser.value = null;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.homeVisitor);
  }
}
